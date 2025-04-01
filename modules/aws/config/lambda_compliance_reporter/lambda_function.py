import boto3
import os
import io
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib import colors

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

def get_compliance_details():
    """Fetches compliance details for all Config rules."""
    rules_compliance = []
    paginator = config_client.get_paginator('describe_compliance_by_config_rule')
    try:
        for page in paginator.paginate():
            rules_compliance.extend(page.get('ComplianceByConfigRules', []))
    except Exception as e:
        print(f"Error fetching compliance details: {e}")
    return rules_compliance

def generate_pdf_report(account_id, compliance_details):
    """Generates a PDF report summarizing compliance status."""
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter,
                            leftMargin=72, rightMargin=72,
                            topMargin=72, bottomMargin=72)
    styles = getSampleStyleSheet()
    story = []

    # --- Title --- 
    title_style = styles['h1']
    title_style.alignment = TA_CENTER
    story.append(Paragraph(f"AWS Config Compliance Report", title_style))
    story.append(Paragraph(f"Account ID: {account_id}", styles['Normal']))
    story.append(Paragraph(f"Generated on: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}", styles['Normal']))
    story.append(Spacer(1, 24))

    # --- Summary Section --- 
    story.append(Paragraph("Compliance Summary", styles['h2']))
    compliant_count = 0
    non_compliant_count = 0
    for rule in compliance_details:
        if rule['Compliance']['ComplianceType'] == 'COMPLIANT':
            compliant_count += 1
        elif rule['Compliance']['ComplianceType'] == 'NON_COMPLIANT':
            non_compliant_count += 1
            
    summary_data = [
        ['Status', 'Rule Count'],
        ['Compliant', compliant_count],
        ['Non-Compliant', non_compliant_count],
        ['Insufficient Data / Not Applicable', len(compliance_details) - compliant_count - non_compliant_count],
        ['Total Rules Evaluated', len(compliance_details)]
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
    story.append(Spacer(1, 24))

    # --- Non-Compliant Rules Section --- 
    non_compliant_rules = [r for r in compliance_details if r['Compliance']['ComplianceType'] == 'NON_COMPLIANT']
    if non_compliant_rules:
        story.append(Paragraph("Non-Compliant Rules & Resources", styles['h2']))
        
        for rule in non_compliant_rules:
            rule_name = rule.get('ConfigRuleName', 'N/A')
            story.append(Paragraph(f"<b>Rule:</b> {rule_name}", styles['h3']))
            
            # Fetch non-compliant resource details (might need pagination for large numbers)
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
                else:
                     story.append(Paragraph("<i>No specific non-compliant resources found or reported for this rule.</i>", styles['Italic']))

            except Exception as e:
                 story.append(Paragraph(f"<i>Error fetching resources for {rule_name}: {e}</i>", styles['Italic']))
            
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
    compliance_details = get_compliance_details()
    
    if not compliance_details:
        print("No compliance details found or error occurred.")
        # Optionally still generate a PDF saying no data?
        # return {'statusCode': 200, 'body': 'No compliance data found.'}
    
    print(f"Generating PDF report for Account: {account_id}...")
    pdf_data = generate_pdf_report(account_id, compliance_details)
    
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
