"""
AWS Config Compliance Reporter Lambda Function

This Lambda function generates a comprehensive PDF compliance report based on AWS Config rule evaluations.
It summarizes the compliance status of all Config rules in the account and provides details about
non-compliant resources. The report is uploaded to an S3 bucket for easy access and archiving.

The function can be triggered on a schedule (using EventBridge) or manually.

Required environment variables:
- S3_BUCKET_NAME: The S3 bucket where reports will be stored
- REPORT_S3_PREFIX: (Optional) The prefix within the bucket for storing reports (default: 'compliance-reports/')

Dependencies:
- reportlab: For PDF generation (provided via Lambda Layer)
- boto3: For AWS API interactions (included in Lambda runtime)
"""

# Standard library imports
import boto3
import os
import io
from datetime import datetime

# ReportLab imports for PDF generation
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib import colors
from reportlab.lib.units import inch

# Environment variables for configuration
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
REPORT_S3_PREFIX = os.environ.get('REPORT_S3_PREFIX', 'compliance-reports/')

# Initialize AWS service clients
config_client = boto3.client('config')
sts_client = boto3.client('sts')
s3_client = boto3.client('s3')
iam_client = boto3.client('iam')
ec2_client = boto3.client('ec2')
rds_client = boto3.client('rds')

def get_account_id():
    """
    Fetches the current AWS Account ID.

    Returns:
        str: The AWS account ID or "UNKNOWN_ACCOUNT" if an error occurs
    """
    try:
        caller_identity = sts_client.get_caller_identity()
        return caller_identity['Account']
    except Exception as e:
        print(f"Error fetching account ID: {e}")
        return "UNKNOWN_ACCOUNT"

def get_compliance_summary():
    """
    Gets compliance summary for all AWS Config rules in the account.

    This function:
    1. Retrieves all Config rules and their compliance status
    2. Counts compliant and non-compliant rules
    3. For non-compliant rules, gets details about the non-compliant resources

    Returns:
        tuple: (
            compliant_count (int),
            non_compliant_count (int),
            rules_summary (list of dicts with 'name' and 'status'),
            non_compliant_details (dict mapping rule names to resource details)
        )
    """
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
    """
    Gets details of non-compliant resources for a specific AWS Config rule.
    
    Args:
        rule_name (str): The name of the Config rule to get non-compliant resources for
        
    Returns:
        list or None: A list of lists containing resource type and ID information,
                     formatted for inclusion in a table, or None if no resources found
                     or an error occurs
    """
    try:
        eval_results = config_client.get_compliance_details_by_config_rule(
            ConfigRuleName=rule_name,
            ComplianceTypes=['NON_COMPLIANT'],
            Limit=100  # Limit results per rule in the report for brevity
        )
        evaluations = eval_results.get('EvaluationResults', [])
        
        if evaluations:
            # Create a table-ready data structure with headers
            resource_data = [['Resource Type', 'Resource ID', 'Friendly Name']]
            for eval_item in evaluations:
                res_id = eval_item.get('EvaluationResultIdentifier', {}).get('EvaluationResultQualifier', {})
                resource_type = res_id.get('ResourceType', 'N/A')
                resource_id = res_id.get('ResourceId', 'N/A')
                
                # Get a more user-friendly identifier for the resource
                friendly_name = get_resource_friendly_name(resource_type, resource_id)
                
                resource_data.append([
                    resource_type,
                    resource_id,
                    friendly_name
                ])
            
            return resource_data
        else:
            return None

    except Exception as e:
        print(f"Error fetching resources for {rule_name}: {e}")
        return None

def get_resource_friendly_name(resource_type, resource_id):
    """
    Gets a user-friendly name for a resource based on its type and ID.
    
    For most resources, this will try to get the Name tag.
    For IAM users, this will get the username.
    
    Args:
        resource_type (str): The AWS resource type (e.g., AWS::EC2::Instance)
        resource_id (str): The resource ID (e.g., i-1234567890abcdef0)
        
    Returns:
        str: A user-friendly name for the resource, or the resource ID if not found
    """
    try:
        # Handle IAM users
        if resource_type == 'AWS::IAM::User':
            # For IAM users, the resource ID is often the user ARN
            # Extract the username from the ARN
            if 'arn:aws:iam::' in resource_id:
                # Format: arn:aws:iam::123456789012:user/username
                username = resource_id.split('/')[-1]
                return username
            
            # Try to get the user details directly if not an ARN
            try:
                user = iam_client.get_user(UserName=resource_id)
                return user.get('User', {}).get('UserName', resource_id)
            except:
                pass
        
        # Handle EC2 instances
        elif resource_type == 'AWS::EC2::Instance':
            try:
                response = ec2_client.describe_instances(InstanceIds=[resource_id])
                for reservation in response.get('Reservations', []):
                    for instance in reservation.get('Instances', []):
                        for tag in instance.get('Tags', []):
                            if tag.get('Key') == 'Name':
                                return tag.get('Value')
            except:
                pass
        
        # Handle S3 buckets
        elif resource_type == 'AWS::S3::Bucket':
            # For S3 buckets, the bucket name is already user-friendly
            return resource_id
        
        # Handle EBS volumes
        elif resource_type == 'AWS::EC2::Volume':
            try:
                response = ec2_client.describe_volumes(VolumeIds=[resource_id])
                for volume in response.get('Volumes', []):
                    for tag in volume.get('Tags', []):
                        if tag.get('Key') == 'Name':
                            return tag.get('Value')
            except:
                pass
        
        # Handle EIPs
        elif resource_type == 'AWS::EC2::EIP':
            try:
                response = ec2_client.describe_addresses(AllocationIds=[resource_id])
                for eip in response.get('Addresses', []):
                    for tag in eip.get('Tags', []):
                        if tag.get('Key') == 'Name':
                            return tag.get('Value')
            except:
                pass
        
        # Handle RDS instances
        elif resource_type == 'AWS::RDS::DBInstance':
            try:
                response = rds_client.describe_db_instances(DBInstanceIdentifier=resource_id)
                for instance in response.get('DBInstances', []):
                    return instance.get('DBName', resource_id)
            except:
                pass
        
        # Default case: return the resource ID
        return resource_id
    
    except Exception as e:
        print(f"Error getting friendly name for {resource_type} {resource_id}: {e}")
        return resource_id

def generate_pdf_report(account_id, compliant_count, non_compliant_count, rules_summary, non_compliant_details):
    """
    Generates a formatted PDF report with compliance information.

    The report includes:
    - Account information and generation timestamp
    - Compliance summary statistics
    - Table of all Config rules and their status
    - Detailed information about non-compliant resources

    Args:
        account_id (str): The AWS account ID
        compliant_count (int): Number of compliant rules
        non_compliant_count (int): Number of non-compliant rules
        rules_summary (list): List of dictionaries with rule names and statuses
        non_compliant_details (dict): Dictionary mapping rule names to non-compliant resource details

    Returns:
        bytes: The PDF report as a byte stream
    """
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter,
                            leftMargin=72, rightMargin=72,
                            topMargin=72, bottomMargin=72)
    styles = getSampleStyleSheet()
    story = []

    # Add report title
    title = "AWS Config Compliance Report"
    story.append(Paragraph(title, styles['h1']))
    story.append(Spacer(1, 0.2*inch))

    # Add report metadata (account ID and timestamp)
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
            resource_table = Table(resource_data, colWidths=[200, 250, 200])
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
    """
    Uploads the generated PDF report to an S3 bucket.

    The report is stored with a path structure of:
    {prefix}/{year}/{month}/{day}/aws-config-compliance-report-{timestamp}.pdf

    Args:
        pdf_data (bytes): The PDF report data
        bucket_name (str): The S3 bucket name
        report_prefix (str): The prefix within the bucket

    Returns:
        str or None: The S3 URI of the uploaded report, or None if upload fails
    """
    now = datetime.utcnow()
    report_key = f"{report_prefix.strip('/')}/{now.strftime('%Y/%m/%d')}/aws-config-compliance-report-{now.strftime('%Y%m%d_%H%M%S')}.pdf"
    try:
        # Upload the PDF to S3 with appropriate content type
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
    """
    Lambda function entry point.

    This is the main function that orchestrates the report generation process:
    1. Validates configuration
    2. Gets the account ID
    3. Fetches compliance data
    4. Generates the PDF report
    5. Uploads the report to S3

    Args:
        event (dict): The Lambda event data (not used in this function)
        context (LambdaContext): The Lambda context object (not used in this function)

    Returns:
        dict: Response with status code and message
    """
    print("Starting compliance report generation...")

    # Validate that required environment variables are set
    if not S3_BUCKET_NAME:
        print("Error: S3_BUCKET_NAME environment variable not set.")
        return {'statusCode': 500, 'body': 'S3 bucket name not configured.'}

    # Get the AWS account ID
    account_id = get_account_id()
    print(f"Account ID: {account_id}")

    # Fetch compliance data from AWS Config
    print("Fetching compliance summary and rule details...")
    compliant_count, non_compliant_count, rules_summary, non_compliant_details = get_compliance_summary()
    total_rules = len(rules_summary)
    print(f"Summary: Total Rules={total_rules}, Compliant={compliant_count}, Non-Compliant={non_compliant_count}")

    # Generate the PDF report
    print("Generating PDF report...")
    pdf_data = generate_pdf_report(account_id, compliant_count, non_compliant_count, rules_summary, non_compliant_details)

    # Upload the report to S3
    print(f"Uploading report to S3 bucket: {S3_BUCKET_NAME}, Prefix: {REPORT_S3_PREFIX}")
    report_location = upload_to_s3(pdf_data, S3_BUCKET_NAME, REPORT_S3_PREFIX)

    # Return success or failure response
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

"""
# Local testing code (commented out for production)
if __name__ == '__main__':
    # Mock environment variables for local testing
    os.environ['S3_BUCKET_NAME'] = 'your-test-bucket-name'
    os.environ['REPORT_S3_PREFIX'] = 'test-compliance-reports/'
    lambda_handler(None, None)
"""
