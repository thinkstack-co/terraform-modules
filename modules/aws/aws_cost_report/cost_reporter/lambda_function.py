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

def fetch_costs(service, tag_key, start, end):
    # Returns: {tag_value: {"total": float, "details": [(desc, cost), ...]}}
    group_by = [{"Type": "TAG", "Key": tag_key}]
    if service == 'EC2':
        group_by.append({"Type": "DIMENSION", "Key": "USAGE_TYPE"})
        service_filter = {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Compute Cloud - Compute"]}}
    elif service == 'EBS':
        group_by.append({"Type": "DIMENSION", "Key": "USAGE_TYPE"})
        service_filter = {"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Elastic Block Store"]}}
    elif service == 'DataTransfer':
        group_by.append({"Type": "DIMENSION", "Key": "USAGE_TYPE"})
        service_filter = {"Dimensions": {"Key": "SERVICE", "Values": ["AWS Data Transfer"]}}
    elif service == 'Backup':
        group_by.append({"Type": "DIMENSION", "Key": "USAGE_TYPE"})
        service_filter = {"Dimensions": {"Key": "SERVICE", "Values": ["AWS Backup"]}}
    else:
        return {}
    results = {}
    paginator = ce.get_paginator('get_cost_and_usage')
    for page in paginator.paginate(
        TimePeriod={'Start': start, 'End': end},
        Granularity='MONTHLY',
        Metrics=['UnblendedCost'],
        GroupBy=group_by,
        Filter=service_filter
    ):
        for group in page['ResultsByTime'][0]['Groups']:
            keys = group['Keys']
            tag_val = keys[0].split('$')[-1] if '$' in keys[0] else keys[0]
            usage_type = keys[1] if len(keys) > 1 else ''
            cost = float(group['Metrics']['UnblendedCost']['Amount'])
            if tag_val not in results:
                results[tag_val] = {"total": 0.0, "details": []}
            results[tag_val]["total"] += cost
            results[tag_val]["details"].append((usage_type, cost))
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
    pdf.cell(200, 10, txt=f"AWS Monthly Cost Report by '{REPORT_TAG_KEY}'", ln=1, align="C")
    pdf.set_font("Arial", size=10)
    pdf.cell(200, 10, txt=f"Period: {start} to {end}", ln=2, align="C")
    pdf.ln(10)
    
    # Collect all unique server names
    servers = set()
    for section_data in cost_data.values():
        servers.update(section_data.keys())
    servers = sorted([s for s in servers if s and s.lower() != 'no tag'])
    
    for server in servers:
        ec2 = cost_data.get('EC2 Instance Cost', {}).get(server, {"total": 0.0, "details": []})
        ebs = cost_data.get('EBS Storage Cost', {}).get(server, {"total": 0.0, "details": []})
        data = cost_data.get('Data Transfer Cost', {}).get(server, {"total": 0.0, "details": []})
        backup = cost_data.get('AWS Backup Cost', {}).get(server, {"total": 0.0, "details": []})
        total = ec2['total'] + ebs['total'] + data['total'] + backup['total']
        pdf.set_font("Arial", 'B', 12)
        pdf.cell(0, 10, txt=f"Server: {server}", ln=1)
        pdf.set_font("Arial", size=10)
        pdf.cell(0, 8, txt=f" - EC2 instance cost: ${ec2['total']:.2f}", ln=1)
        pdf.cell(0, 8, txt=f" - EBS volume cost: ${ebs['total']:.2f}", ln=1)
        pdf.cell(0, 8, txt=f" - Data costs: ${data['total']:.2f}", ln=1)
        pdf.cell(0, 8, txt=f" - Backup costs: ${backup['total']:.2f}", ln=1)
        pdf.set_font("Arial", 'B', 11)
        pdf.cell(0, 10, txt=f"Total cost: ${total:.2f}", ln=1)
        pdf.ln(5)
    pdf.output(outfile)

def lambda_handler(event, context):
    start, end = get_time_period()
    cost_data = {}
    for service, label in [('EC2', 'EC2 Instance Cost'),
                           ('EBS', 'EBS Storage Cost'),
                           ('DataTransfer', 'Data Transfer Cost'),
                           ('Backup', 'AWS Backup Cost')]:
        cost_data[label] = fetch_costs(service, REPORT_TAG_KEY, start, end)
    with tempfile.NamedTemporaryFile(suffix='.pdf') as tmp:
        generate_pdf(cost_data, start, end, tmp.name)
        s3_key = f"cost-report-{start}-to-{end}.pdf"
        s3.upload_file(tmp.name, REPORT_BUCKET, s3_key)
    return {"status": "ok", "s3_key": s3_key}
