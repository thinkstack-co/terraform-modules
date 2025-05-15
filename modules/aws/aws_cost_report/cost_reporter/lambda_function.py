import datetime
import os
import tempfile

import boto3
from fpdf import FPDF

# ENV VARS
REPORT_BUCKET = os.environ["REPORT_BUCKET"]
REPORT_TAG_KEY = os.environ.get("REPORT_TAG_KEY", "Name")
REPORT_TIME_PERIOD_START = os.environ.get("REPORT_TIME_PERIOD_START")
REPORT_TIME_PERIOD_END = os.environ.get("REPORT_TIME_PERIOD_END")
CUSTOMER_IDENTIFIER = os.environ.get("CUSTOMER_IDENTIFIER", "")
# minimum cost threshold (e.g. "0.003" or "0.0000005")
MIN_ITEM_COST = float(os.environ.get("MIN_ITEM_COST", "0.01"))

ce = boto3.client("ce")
s3 = boto3.client("s3")
sts = boto3.client("sts")


def get_time_period():
    if REPORT_TIME_PERIOD_START and REPORT_TIME_PERIOD_END:
        return REPORT_TIME_PERIOD_START, REPORT_TIME_PERIOD_END
    today = datetime.date.today()
    first_this = today.replace(day=1)
    last_prev = first_this - datetime.timedelta(days=1)
    first_prev = last_prev.replace(day=1)
    return str(first_prev), str(last_prev)


def fetch_detailed_costs(start, end):
    """
    Returns:
      {
        tag_value: {
          usage_type: total_cost,
          ...
        },
        ...
      }
    Skips any entries with no tag.
    """
    group_by = [
        {"Type": "TAG", "Key": REPORT_TAG_KEY},
        {"Type": "DIMENSION", "Key": "USAGE_TYPE"},
    ]

    results = {}
    next_token = None

    while True:
        params = {
            "TimePeriod": {"Start": start, "End": end},
            "Granularity": "MONTHLY",
            "Metrics": ["UnblendedCost"],
            "GroupBy": group_by,
        }
        if next_token:
            params["NextPageToken"] = next_token

        resp = ce.get_cost_and_usage(**params)
        for g in resp["ResultsByTime"][0]["Groups"]:
            raw_tag, usage = g["Keys"]
            if not raw_tag or not raw_tag.strip():
                continue
            tag = raw_tag.split("$")[-1]
            cost = float(g["Metrics"]["UnblendedCost"]["Amount"])
            results.setdefault(tag, {})
            results[tag][usage] = results[tag].get(usage, 0.0) + cost

        next_token = resp.get("NextPageToken")
        if not next_token:
            break

    return results


# Usage-type → resource-type mapping
USAGE_TYPE_TO_RESOURCE_TYPE = {
    "EBS:SnapshotUsage": "EBS Volume",
    "EBS:VolumeUsage": "EBS Volume",
    "VolumeUsage": "EBS Volume",
    "SnapshotUsage": "EBS Volume",
    "EC2": "EC2 Instance",
    "DataTransfer": "VPC / Data Transfer",
    "NatGateway": "VPC / NAT Gateway",
    "VpcPeering": "VPC Peering",
    "PublicIPv4": "Elastic IP",
    "CW:": "CloudWatch",
    "Log-Bytes": "CloudWatch Logs",
    "SecretsManager": "Secrets Manager",
    "APIRequest": "API Gateway",
    "BoxUsage": "EC2 Instance",
    "CreateImage": "EC2 AMI",
    # add more mappings here as needed
}


def get_resource_type(usage_type):
    for prefix, resource in USAGE_TYPE_TO_RESOURCE_TYPE.items():
        if usage_type.startswith(prefix) or prefix in usage_type:
            return resource
    return "Other"


def generate_pdf(cost_data, start, end, outfile):
    pdf = FPDF()
    # patch missing attribute
    pdf.unifontsubset = False
    pdf.add_page()

    # Header
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Customer: {CUSTOMER_IDENTIFIER}", ln=1, align="C")
    try:
        acct = sts.get_caller_identity()["Account"]
    except Exception:
        acct = "Unknown"
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 8, f"AWS Account ID: {acct}", ln=1, align="C")

    pdf.set_font("Arial", "B", 14)
    pdf.cell(0, 8, "Granular Cost Report by Tag - Usage Type", ln=1, align="C")
    pdf.set_font("Arial", size=10, style="I")
    pdf.cell(0, 6, f"Tag: {REPORT_TAG_KEY} | Period: {start} to {end}", ln=1, align="C")
    pdf.ln(6)

    # For each tag
    # Sort Name tags alphabetically (case-insensitive)
    for tag_val in sorted(cost_data, key=lambda x: str(x).lower()):
        tag = tag_val
        if not tag.strip():
            continue
        usages = cost_data[tag_val]

        # Tag header
        pdf.set_font("Arial", "B", 14)
        pdf.set_fill_color(230, 230, 250)
        pdf.cell(0, 8, f"{REPORT_TAG_KEY}: {tag}", ln=1, fill=True)
        pdf.ln(1)

        # Resource type(s) for this tag
        resource_types = set()
        for usage_type, amount in usages.items():
            amt = float(amount)
            if amt < MIN_ITEM_COST:
                continue
            resource_types.add(get_resource_type(usage_type))
        types_str = ", ".join(sorted(resource_types)) if resource_types else "Unknown"

        pdf.set_font("Arial", "B", 12)
        pdf.set_text_color(80, 80, 80)
        pdf.cell(0, 7, f"Resource Type: {types_str}", ln=1)
        pdf.set_text_color(0, 0, 0)
        pdf.ln(2)

        # Table header
        col1, col2 = 140, 40
        h = 7
        pdf.set_font("Arial", "B", 11)
        pdf.set_fill_color(200, 200, 200)
        pdf.cell(col1, h, "Usage Type", border=1, fill=True)
        pdf.cell(col2, h, "Cost ($)", border=1, fill=True, align="R")
        pdf.ln(h)

        # Rows (skip below MIN_ITEM_COST)
        pdf.set_font("Arial", size=10)
        tag_total = 0.0
        for usage_type, amount in sorted(usages.items()):
            amt = float(amount)
            if amt < MIN_ITEM_COST:
                continue
            tag_total += amt
            pdf.cell(col1, h, usage_type[:60], border=1)
            fmt = f"{amt:,.6f}" if amt < 1 else f"{amt:,.2f}"
            pdf.cell(col2, h, fmt, border=1, align="R")
            pdf.ln(h)

        # Total row
        pdf.set_font("Arial", "B", 12)
        pdf.cell(col1, h, "Total", border=1)
        pdf.cell(col2, h, f"{tag_total:,.2f}", border=1, align="R")
        pdf.ln(h + 6)

        # Page‐break guard
        if pdf.get_y() > 250:
            pdf.add_page()

    pdf.output(outfile)


def lambda_handler(event, context):
    start, end = get_time_period()
    detailed_costs = fetch_detailed_costs(start, end)

    # Parse year and month from the start date
    start_dt = datetime.datetime.strptime(start, "%Y-%m-%d")
    year = start_dt.year
    month = f"{start_dt.month:02d}"
    # Sanitize customer name for S3 key
    safe_customer = (
        CUSTOMER_IDENTIFIER.lower()
        .replace(" ", "-")
        .replace("_", "-")
        .replace(".", "")
        .replace("/", "")
        .replace("\\", "")
    )
    key = f"{year}/{month}/{safe_customer}-cost-report-{year}-{month}.pdf"

    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        generate_pdf(detailed_costs, start, end, tmp.name)
        s3.upload_file(tmp.name, REPORT_BUCKET, key)

    return {"status": "ok", "s3_key": key}
