import os
import boto3
import datetime
from fpdf import FPDF
import tempfile

# ENV VARS
REPORT_BUCKET = os.environ.get('REPORT_BUCKET')
REPORT_TAG_KEY = os.environ.get('REPORT_TAG_KEY', 'Name')
REPORT_TIME_PERIOD_START = os.environ.get('REPORT_TIME_PERIOD_START')
REPORT_TIME_PERIOD_END = os.environ.get('REPORT_TIME_PERIOD_END')
CUSTOMER_IDENTIFIER = os.environ.get('CUSTOMER_IDENTIFIER', '')

ce = boto3.client('ce')
s3 = boto3.client('s3')
sts = boto3.client('sts')

def get_time_period():
    if REPORT_TIME_PERIOD_START and REPORT_TIME_PERIOD_END:
        return REPORT_TIME_PERIOD_START, REPORT_TIME_PERIOD_END
    # Default: previous month
    today = datetime.date.today()
    first_day_this_month = today.replace(day=1)
    last_day_prev_month = first_day_this_month - datetime.timedelta(days=1)
    first_day_prev_month = last_day_prev_month.replace(day=1)
    return str(first_day_prev_month), str(last_day_prev_month)

def fetch_costs(start, end):
    # Returns: {resource_name: {category: {"total": float, "details": [(desc, cost), ...]}}}
    service_map = {
        'EC2': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Compute Cloud - Compute"]}},
            'label': 'EC2 Instance Cost'
        },
        'EBS': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Block Store"]}},
            'label': 'EBS Storage Cost'
        },
        'DataTransfer': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["AWS Data Transfer"]}},
            'label': 'Data Transfer Cost'
        },
        'Backup': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["AWS Backup"]}},
            'label': 'AWS Backup Cost'
        },
        'EBS_Snapshot': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Block Store"]}},
            'label': 'EBS Snapshot Cost',  # Now its own category
            'usage_types': ["EBS:SnapshotUsage", "EBS:FastSnapshotRestore", "EBS:SnapshotTimedStorage"],
        },
        'AMI': {
            'service_filter': {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Compute Cloud - Compute"]}},
            'label': 'AMI Creation Cost',  # Now its own category
            'usage_types': ["EC2:CreateImage", "EC2:ExportImage", "EC2:Snapshot"],
        }
    }
    results = {}
    for service, meta in service_map.items():
        group_by = [
            {"Type": "TAG", "Key": REPORT_TAG_KEY}
        ]
        next_token = None
        while True:
            params = {
                'TimePeriod': {'Start': start, 'End': end},
                'Granularity': 'MONTHLY',
                'Metrics': ['UnblendedCost'],
                'GroupBy': group_by,
                'Filter': meta['service_filter']
            }
            if next_token:
                params['NextPageToken'] = next_token
            page = ce.get_cost_and_usage(**params)
            for group in page['ResultsByTime'][0]['Groups']:
                keys = group['Keys']
                resource_name = keys[0].split('$')[-1] if '$' in keys[0] else keys[0]
                usage_type = keys[1] if len(keys) > 1 else ''
                cost = float(group['Metrics']['UnblendedCost']['Amount'])
                # For EBS_Snapshot and AMI, filter to backup-related usage types
                if service in ['EBS_Snapshot', 'AMI']:
                    if usage_type not in meta['usage_types']:
                        continue
                if resource_name not in results:
                    results[resource_name] = {}
                label = meta.get('label', service)
                if label not in results[resource_name]:
                    results[resource_name][label] = {"total": 0.0, "details": []}
                results[resource_name][label]["total"] += cost
                results[resource_name][label]["details"].append((service, cost))
            next_token = page.get('NextPageToken')
            if not next_token:
                break
    return results


def generate_pdf(cost_data, start, end, outfile):
    pdf = FPDF()
    pdf.add_page()
    # Customer Name (bold, large)
    pdf.set_font("Arial", 'B', 16)
    pdf.cell(200, 12, txt=f"Customer: {CUSTOMER_IDENTIFIER}", ln=1, align="C")
    # AWS Account Number (regular)
    try:
        account_id = sts.get_caller_identity()["Account"]
    except Exception:
        account_id = "Unknown"
    pdf.set_font("Arial", size=12)
    pdf.cell(200, 10, txt=f"AWS Account ID: {account_id}", ln=1, align="C")
    # Report Title
    pdf.set_font("Arial", size=14)
    pdf.cell(200, 10, txt=f"AWS Monthly Cost Report grouped by '{REPORT_TAG_KEY}'", ln=1, align="C")
    pdf.set_font("Arial", size=10)
    pdf.cell(200, 10, txt=f"Period: {start} to {end}", ln=2, align="C")
    pdf.ln(6)
    pdf.set_font("Arial", size=10, style='I')
    pdf.cell(200, 8, txt=f"Each section below is grouped by the tag: '{REPORT_TAG_KEY}'", ln=2, align="C")
    pdf.ln(4)

    # Each group is a server/resource group by tag
    for cost_alloc in sorted(cost_data.keys()):
        # Server header
        pdf.set_font("Arial", 'B', 16)
        pdf.cell(0, 14, txt=f"{REPORT_TAG_KEY}: {cost_alloc}", ln=1)
        pdf.ln(2)
        # Table header
        col1_width = 70
        col2_width = 40
        row_height = 10
        pdf.set_font("Arial", 'B', 13)
        pdf.set_fill_color(220, 220, 220)
        pdf.cell(col1_width, row_height, "Cost Category", border=1, align="C", fill=True)
        pdf.cell(col2_width, row_height, "Cost ($)", border=1, align="C", fill=True)
        pdf.ln(row_height)
        # Table rows
        pdf.set_font("Arial", '', 12)
        categories = [
            ('EC2 Instance Cost', 'EC2 Instance'),
            ('EBS Storage Cost', 'EBS Volume'),
            ('Data Transfer Cost', 'Data Transfer'),
            ('AWS Backup Cost', 'Backup'),
            ('EBS Snapshot Cost', 'EBS Snapshot'),
            ('AMI Creation Cost', 'AMI Creation'),
        ]
        total = 0.0
        for key, label in categories:
            amount = cost_data[cost_alloc].get(key, {}).get('total', 0.0)
            total += amount
            pdf.cell(col1_width, row_height, label, border=1)
            pdf.cell(col2_width, row_height, f"${amount:.2f}", border=1, align="R")
            pdf.ln(row_height)
        # Total row
        pdf.set_font("Arial", 'B', 13)
        pdf.cell(col1_width, row_height, "Total", border=1)
        pdf.cell(col2_width, row_height, f"${total:.2f}", border=1, align="R")
        pdf.ln(row_height + 3)
        pdf.ln(4)
        # Draw another horizontal line after each group for separation
        pdf.set_draw_color(220, 220, 220)
        pdf.set_line_width(0.2)
        pdf.line(pdf.l_margin, pdf.get_y(), pdf.w - pdf.r_margin, pdf.get_y())
        pdf.ln(6)

    pdf.output(outfile)





def lambda_handler(event, context):
    start, end = get_time_period()
    cost_data = fetch_costs(start, end)
    with tempfile.NamedTemporaryFile(suffix='.pdf') as tmp:
        generate_pdf(cost_data, start, end, tmp.name)
        s3_key = f"cost-report-{start}-to-{end}.pdf"
        s3.upload_file(tmp.name, REPORT_BUCKET, s3_key)
    return {"status": "ok", "s3_key": s3_key}

