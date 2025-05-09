import os
import boto3
import datetime
from fpdf import FPDF
import tempfile

# ENV VARS
REPORT_BUCKET            = os.environ['REPORT_BUCKET']
REPORT_TAG_KEY           = os.environ.get('REPORT_TAG_KEY', 'Name')
REPORT_TIME_PERIOD_START = os.environ.get('REPORT_TIME_PERIOD_START')
REPORT_TIME_PERIOD_END   = os.environ.get('REPORT_TIME_PERIOD_END')
CUSTOMER_IDENTIFIER      = os.environ.get('CUSTOMER_IDENTIFIER', '')

ce  = boto3.client('ce')
s3  = boto3.client('s3')
sts = boto3.client('sts')


def get_time_period():
    if REPORT_TIME_PERIOD_START and REPORT_TIME_PERIOD_END:
        return REPORT_TIME_PERIOD_START, REPORT_TIME_PERIOD_END
    today = datetime.date.today()
    first_this_month = today.replace(day=1)
    last_prev_month   = first_this_month - datetime.timedelta(days=1)
    first_prev_month  = last_prev_month.replace(day=1)
    return str(first_prev_month), str(last_prev_month)


def fetch_all_costs(start, end):
    """
    Returns nested dict:
      {
        tag_value: {
          service_name: total_cost,
          ...
        },
        ...
      }
    """
    # Only two group-by dimensions allowed: Tag and Service
    group_by = [
        {"Type": "TAG",       "Key": REPORT_TAG_KEY},
        {"Type": "DIMENSION", "Key": "SERVICE"},
    ]

    results   = {}
    next_token = None

    while True:
        params = {
            "TimePeriod": {"Start": start, "End": end},
            "Granularity": "MONTHLY",
            "Metrics": ["UnblendedCost"],
            "GroupBy": group_by
        }
        if next_token:
            params["NextPageToken"] = next_token

        resp = ce.get_cost_and_usage(**params)
        for group in resp["ResultsByTime"][0]["Groups"]:
            raw_tag, service = group["Keys"]
            tag_val = raw_tag.split("$")[-1]
            cost    = float(group["Metrics"]["UnblendedCost"]["Amount"])

            # accumulate service-level cost
            results.setdefault(tag_val, {})
            results[tag_val][service] = results[tag_val].get(service, 0.0) + cost

        next_token = resp.get("NextPageToken")
        if not next_token:
            break

    return results


def generate_pdf(cost_data, start, end, outfile):
    pdf = FPDF()
    pdf.add_page()
    # … your header code …

    # Define your category ordering
    categories = [
        ('EC2 Instance Cost', 'EC2 Instance'),
        ('EBS Storage Cost',    'EBS Volume'),
        ('Data Transfer Cost',  'Data Transfer'),
        ('AWS Backup Cost',     'Backup'),
        ('EBS Snapshot Cost',   'EBS Snapshot'),
        ('AMI Creation Cost',   'AMI Creation'),
    ]

    for tag_val in sorted(cost_data):
        # … tag header …

        # Table header
        col1_width = 70
        col2_width = 40
        row_height = 10
        # … header styling …

        total = 0.0
        for key, label in categories:
            amount = cost_data[tag_val].get(key, {}).get('total', 0.0)
            total += amount
            pdf.cell(col1_width, row_height, label, border=1)
            pdf.cell(col2_width, row_height, f"${amount:.2f}", border=1, align="R")
            pdf.ln(row_height)

        # Total row
        pdf.set_font("Arial", 'B', 13)
        pdf.cell(col1_width, row_height, "Total", border=1)
        pdf.cell(col2_width, row_height, f"${total:.2f}", border=1, align="R")
        pdf.ln(row_height + 3)
        # … separator …

    pdf.output(outfile)


def lambda_handler(event, context):
    start, end   = get_time_period()
    all_costs    = fetch_all_costs(start, end)

    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        generate_pdf(all_costs, start, end, tmp.name)
        key = f"cost-report-{start}-to-{end}.pdf"
        s3.upload_file(tmp.name, REPORT_BUCKET, key)

    return {"status": "ok", "s3_key": key}
