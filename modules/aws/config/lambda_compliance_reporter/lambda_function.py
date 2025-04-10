import boto3
import os
import io
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib import colors
from reportlab.lib.units import inch

S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
REPORT_S3_PREFIX = os.environ.get('REPORT_S3_PREFIX', 'compliance-reports/')

config_client = boto3.client('config')
sts_client = boto3.client('sts')
s3_client = boto3.client('s3')

def get_account_id():
    """Fetches the current AWS Account ID."""
    try:
        caller_identity = sts_client.get_caller_identity()
        return caller_identity['Account']
    except Exception as e:
        print(f"Error fetching account ID: {e}")
        return "UNKNOWN_ACCOUNT"

def get_compliance_summary():
    """Gets compliance summary for all AWS Config rules."""
    paginator = config_client.get_paginator('describe_compliance_by_config_rule')
    compliant_count = 0
    non_compliant_count = 0
    rules_summary = []
    non_compliant_details = {}

    try:
        for page in paginator.paginate():
            for rule in page.get('ComplianceByConfigRules', []):
                rule_name = rule.get('ConfigRuleName')
                compliance_status = rule.get('Compliance', {}).get('ComplianceType')
                rules_summary.append({'name': rule_name, 'status': compliance_status})

                if compliance_status == 'COMPLIANT':
                    compliant_count += 1
                elif compliance_status == 'NON_COMPLIANT':
                    non_compliant_count += 1
                    # Get details for non-compliant rules
                    details = get_non_compliant_resources(rule_name)
                    if details:
                        non_compliant_details[rule_name] = details
                # Other statuses like INSUFFICIENT_DATA are implicitly ignored in counts

    except Exception as e:
        print(f"Error describing compliance: {e}")
        raise

    return compliant_count, non_compliant_count, rules_summary, non_compliant_details

def get_non_compliant_resources(rule_name):
    """Gets details of non-compliant resources for a specific rule."""
    try:
        eval_results = config_client.get_compliance_details_by_config_rule(
            ConfigRuleName=rule_name,
            ComplianceTypes=['NON_COMPLIANT'],
            Limit=100 # Limit results per rule in the report for brevity
        )
        evaluations = eval_results.get('EvaluationResults', [])
        
        if evaluations:
            resource_data = [['Resource Type', 'Resource ID']]
            for eval_item in evaluations:
                res_id = eval_item.get('EvaluationResultIdentifier', {}).get('EvaluationResultQualifier', {})
                resource_data.append([
                    res_id.get('ResourceType', 'N/A'),
                    res_id.get('ResourceId', 'N/A')
                ])
            
            return resource_data
        else:
            return None

    except Exception as e:
        print(f"Error fetching resources for {rule_name}: {e}")
        return None

def generate_pdf_report(account_id, compliant_count, non_compliant_count, rules_summary, non_compliant_details):
    """Generates the PDF report content."""
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter,
                            leftMargin=72, rightMargin=72,
                            topMargin=72, bottomMargin=72)
    styles = getSampleStyleSheet()
    story = []

    # Title
    title = "AWS Config Compliance Report"
    story.append(Paragraph(title, styles['h1']))
    story.append(Spacer(1, 0.2*inch))

    # Report Metadata
    report_time = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    story.append(Paragraph(f"Account ID: {account_id}", styles['Normal']))
    story.append(Paragraph(f"Generated On: {report_time}", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))

    # Overall Summary
    story.append(Paragraph("Overall Compliance Summary", styles['h2']))
    summary_data = [
        ['Status', 'Count'],
        ['Compliant Rules', str(compliant_count)],
        ['Non-Compliant Rules', str(non_compliant_count)]
    ]
    summary_table = Table(summary_data)
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    story.append(summary_table)
    story.append(Spacer(1, 0.3*inch))

    # Rule Compliance Status Section
    story.append(Paragraph("Rule Compliance Status", styles['h2']))
    if rules_summary:
        rule_data = [['Rule Name', 'Status']]
        rules_summary.sort(key=lambda x: x['name']) # Sort alphabetically
        for rule in rules_summary:
            rule_data.append([Paragraph(rule['name'], styles['Normal']), rule['status']])

        rule_table = Table(rule_data, colWidths=[4*inch, 1.5*inch])
        rule_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.darkblue),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'), # Header alignment
            ('ALIGN', (1, 1), (1, -1), 'CENTER'), # Status column alignment
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
            ('BACKGROUND', (0, 1), (-1, -1), colors.lightgrey),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ]))
        story.append(rule_table)
    else:
        story.append(Paragraph("No Config rules found or compliance data available.", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))

    # Non-Compliant Details Section
    story.append(Paragraph("Non-Compliant Rule Details", styles['h2']))
    if non_compliant_details:
        for rule_name, resource_data in non_compliant_details.items():
            story.append(Paragraph(f"<b>Rule:</b> {rule_name}", styles['h3']))
            resource_table = Table(resource_data, colWidths=[200, 250])
            resource_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
                ('BACKGROUND', (0, 1), (-1, -1), colors.whitesmoke),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey)
            ]))
            story.append(resource_table)
            story.append(Spacer(1, 12))
    else:
        story.append(Paragraph("No Non-Compliant Rules Found", styles['h2']))

    doc.build(story)
    return buffer.getvalue()

def upload_to_s3(pdf_data, bucket_name, report_prefix):
    """Uploads the generated PDF to S3."""
    now = datetime.utcnow()
    report_key = f"{report_prefix.strip('/')}/{now.strftime('%Y/%m/%d')}/aws-config-compliance-report-{now.strftime('%Y%m%d_%H%M%S')}.pdf"
    try:
        s3_client.put_object(
            Bucket=bucket_name,
            Key=report_key,
            Body=pdf_data,
            ContentType='application/pdf'
        )
        print(f"Successfully uploaded report to s3://{bucket_name}/{report_key}")
        return f"s3://{bucket_name}/{report_key}"
    except Exception as e:
        print(f"Error uploading report to S3: {e}")
        return None

def lambda_handler(event, context):
    """Lambda function entry point."""
    print("Starting compliance report generation...")
    
    if not S3_BUCKET_NAME:
        print("Error: S3_BUCKET_NAME environment variable not set.")
        return {'statusCode': 500, 'body': 'S3 bucket name not configured.'}

    account_id = get_account_id()
    print(f"Account ID: {account_id}")

    print("Fetching compliance summary and rule details...")
    compliant_count, non_compliant_count, rules_summary, non_compliant_details = get_compliance_summary()
    total_rules = len(rules_summary)
    print(f"Summary: Total Rules={total_rules}, Compliant={compliant_count}, Non-Compliant={non_compliant_count}")

    print("Generating PDF report...")
    pdf_data = generate_pdf_report(account_id, compliant_count, non_compliant_count, rules_summary, non_compliant_details)

    print(f"Uploading report to S3 bucket: {S3_BUCKET_NAME}, Prefix: {REPORT_S3_PREFIX}")
    report_location = upload_to_s3(pdf_data, S3_BUCKET_NAME, REPORT_S3_PREFIX)

    if report_location:
        print("Report generation and upload complete.")
        return {
            'statusCode': 200,
            'body': f'Compliance report successfully generated and uploaded to {report_location}'
        }
    else:
        print("Report generation failed during upload.")
        return {
            'statusCode': 500,
            'body': 'Failed to upload compliance report to S3.'
        }

# For local testing (optional)
# if __name__ == '__main__':
#     # Mock environment variables for local testing
#     os.environ['S3_BUCKET_NAME'] = 'your-test-bucket-name'
#     os.environ['REPORT_S3_PREFIX'] = 'test-compliance-reports/'
#     lambda_handler(None, None)
