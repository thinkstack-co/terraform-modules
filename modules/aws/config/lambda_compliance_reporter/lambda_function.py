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
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib import colors
from reportlab.lib.units import inch

# Environment variables for configuration
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
REPORT_S3_PREFIX = os.environ.get('REPORT_S3_PREFIX', 'compliance-reports/')

# AWS clients
config_client = boto3.client('config')
sts_client = boto3.client('sts')
s3_client = boto3.client('s3')
iam_client = boto3.client('iam')
ec2_client = boto3.client('ec2')
rds_client = boto3.client('rds')
organizations_client = boto3.client('organizations')

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

def get_account_name():
    """
    Attempts to get the AWS account name using multiple methods:
    1. Organizations API (if account is part of an organization)
    2. IAM account alias (if set)
    3. Default to account ID if other methods fail
    
    Returns:
        str: The account name or alias, or account ID if neither is available
    """
    account_id = get_account_id()
    
    # Try Organizations API first
    try:
        response = organizations_client.describe_account(AccountId=account_id)
        if 'Account' in response and 'Name' in response['Account']:
            return response['Account']['Name']
    except Exception as e:
        print(f"Unable to get account name from Organizations API: {e}")
    
    # Try IAM account alias
    try:
        response = iam_client.list_account_aliases()
        if response['AccountAliases'] and len(response['AccountAliases']) > 0:
            return response['AccountAliases'][0]
    except Exception as e:
        print(f"Unable to get account alias: {e}")
    
    # Default to account ID
    return f"Account {account_id}"

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
        list or None: A list of lists containing resource type and friendly name information,
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
            # For IAM users, we want to show both the username and ARN
            if rule_name.lower().find('mfa') >= 0 or rule_name.lower().find('iam') >= 0:
                resource_data = [['Resource Type', 'Name']]
            else:
                resource_data = [['Resource Type', 'Name']]
                
            for eval_item in evaluations:
                res_id = eval_item.get('EvaluationResultIdentifier', {}).get('EvaluationResultQualifier', {})
                resource_type = res_id.get('ResourceType', 'N/A')
                resource_id = res_id.get('ResourceId', 'N/A')
                
                # Get a more user-friendly identifier for the resource
                name_tag = get_resource_name_tag(resource_type, resource_id)
                
                resource_data.append([
                    resource_type,
                    name_tag
                ])
            
            return resource_data
        else:
            return None

    except Exception as e:
        print(f"Error fetching resources for {rule_name}: {e}")
        return None

def get_resource_name_tag(resource_type, resource_id):
    """
    Gets the 'Name' tag value for a resource based on its type and ID.
     
    For most AWS resources, this will try to get the 'Name' tag.
     For IAM users, this will get the username.
     
     Args:
         resource_type (str): The AWS resource type (e.g., AWS::EC2::Instance)
         resource_id (str): The resource ID (e.g., i-1234567890abcdef0)
         
     Returns:
        str: The 'Name' tag value for the resource, or the resource ID if not found
     """
    try:
        # Handle IAM users
        if resource_type == 'AWS::IAM::User':
            # The resource_id from Config is usually the IAM user ARN
            # We need to extract the username from the ARN
            try:
                # First, try to get the IAM user details from AWS Config
                config_response = config_client.get_resource_config_history(
                    resourceType='AWS::IAM::User',
                    resourceId=resource_id,
                    limit=1
                )
                
                if config_response.get('configurationItems'):
                    config_item = config_response['configurationItems'][0]
                    resource_name = config_item.get('resourceName')
                    if resource_name:
                        return resource_name  # This is the IAM username
            except Exception as e:
                print(f"Error getting config history for IAM user: {e}")
            
            # If we couldn't get it from Config, extract from ARN
            if 'arn:aws:iam::' in resource_id:
                # Format: arn:aws:iam::123456789012:user/username
                username = resource_id.split('/')[-1]
                return username
            
            # As a last resort, try to get user details directly
            # Note: This might fail due to permissions
            try:
                # If resource_id is not an ARN but a username
                user = iam_client.get_user(UserName=resource_id)
                return user.get('User', {}).get('UserName', resource_id)
            except Exception as e:
                print(f"Error getting IAM user details: {e}")
        
        # Handle EC2 instances
        elif resource_type == 'AWS::EC2::Instance':
            try:
                # Try to get the resource configuration from AWS Config
                config_response = config_client.get_resource_config_history(
                    resourceType='AWS::EC2::Instance',
                    resourceId=resource_id,
                    limit=1
                )
                
                if config_response.get('configurationItems'):
                    config_item = config_response['configurationItems'][0]
                    tags = config_item.get('tags', {})
                    if 'Name' in tags:
                        return tags['Name']
            except Exception as e:
                print(f"Error getting config history for EC2 instance: {e}")
            
            # If Config doesn't have the info, try EC2 API directly
            try:
                response = ec2_client.describe_instances(InstanceIds=[resource_id])
                for reservation in response.get('Reservations', []):
                    for instance in reservation.get('Instances', []):
                        for tag in instance.get('Tags', []):
                            if tag.get('Key') == 'Name':
                                return tag.get('Value')
            except Exception as e:
                print(f"Error getting EC2 instance details: {e}")
        
        # Handle S3 buckets
        elif resource_type == 'AWS::S3::Bucket':
            try:
                # Try to get tags for the S3 bucket
                response = s3_client.get_bucket_tagging(Bucket=resource_id)
                for tag in response.get('TagSet', []):
                    if tag.get('Key') == 'Name':
                        return tag.get('Value')
            except Exception as e:
                # If no tags or can't get tags, return the bucket name
                return resource_id
        
        # Handle EBS volumes
        elif resource_type == 'AWS::EC2::Volume':
            try:
                # Try to get the resource configuration from AWS Config
                config_response = config_client.get_resource_config_history(
                    resourceType='AWS::EC2::Volume',
                    resourceId=resource_id,
                    limit=1
                )
                
                if config_response.get('configurationItems'):
                    config_item = config_response['configurationItems'][0]
                    tags = config_item.get('tags', {})
                    if 'Name' in tags:
                        return tags['Name']
            except Exception as e:
                print(f"Error getting config history for EBS volume: {e}")
            
            # If Config doesn't have the info, try EC2 API directly
            try:
                response = ec2_client.describe_volumes(VolumeIds=[resource_id])
                for volume in response.get('Volumes', []):
                    for tag in volume.get('Tags', []):
                        if tag.get('Key') == 'Name':
                            return tag.get('Value')
            except Exception as e:
                print(f"Error getting EBS volume details: {e}")
        
        # Handle EIPs
        elif resource_type == 'AWS::EC2::EIP':
            try:
                # Try to get the resource configuration from AWS Config
                config_response = config_client.get_resource_config_history(
                    resourceType='AWS::EC2::EIP',
                    resourceId=resource_id,
                    limit=1
                )
                
                if config_response.get('configurationItems'):
                    config_item = config_response['configurationItems'][0]
                    tags = config_item.get('tags', {})
                    if 'Name' in tags:
                        return tags['Name']
            except Exception as e:
                print(f"Error getting config history for EIP: {e}")
            
            # If Config doesn't have the info, try EC2 API directly
            try:
                response = ec2_client.describe_addresses(AllocationIds=[resource_id])
                for eip in response.get('Addresses', []):
                    for tag in eip.get('Tags', []):
                        if tag.get('Key') == 'Name':
                            return tag.get('Value')
            except Exception as e:
                print(f"Error getting EIP details: {e}")
        
        # Handle RDS instances
        elif resource_type == 'AWS::RDS::DBInstance':
            try:
                # Try to get the resource configuration from AWS Config
                config_response = config_client.get_resource_config_history(
                    resourceType='AWS::RDS::DBInstance',
                    resourceId=resource_id,
                    limit=1
                )
                
                if config_response.get('configurationItems'):
                    config_item = config_response['configurationItems'][0]
                    tags = config_item.get('tags', {})
                    if 'Name' in tags:
                        return tags['Name']
            except Exception as e:
                print(f"Error getting config history for RDS instance: {e}")
            
            # If Config doesn't have the info, try RDS API directly
            try:
                response = rds_client.describe_db_instances(DBInstanceIdentifier=resource_id)
                # First check for tags
                for instance in response.get('DBInstances', []):
                    for tag in instance.get('TagList', []):
                        if tag.get('Key') == 'Name':
                            return tag.get('Value')
                    # If no Name tag, use the DB name or instance ID
                    return instance.get('DBName', resource_id)
            except Exception as e:
                print(f"Error getting RDS instance details: {e}")
        
        # Try AWS Config for any resource type
        try:
            config_response = config_client.get_resource_config_history(
                resourceType=resource_type,
                resourceId=resource_id,
                limit=1
            )
            
            if config_response.get('configurationItems'):
                config_item = config_response['configurationItems'][0]
                tags = config_item.get('tags', {})
                if 'Name' in tags:
                    return tags['Name']
        except Exception as e:
            print(f"Error getting config history for {resource_type}: {e}")
        
        # Default case: return the resource ID
        return resource_id
    
    except Exception as e:
        print(f"Error getting Name tag for {resource_type} {resource_id}: {e}")
        return resource_id

def generate_pdf_report(account_id, compliant_count, non_compliant_count, rules_summary, non_compliant_details):
    """
    Generates a formatted PDF report with compliance information.

    This function creates a PDF document with:
    1. A title and header with account ID and timestamp
    2. A summary of compliant vs. non-compliant rules
    3. A table of all rules and their compliance status
    4. For each non-compliant rule, a table of affected resources

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
    styles.add(ParagraphStyle(name='Heading2', fontSize=14, spaceAfter=6))
    story = []

    # Add report title
    title = "AWS Config Compliance Report"
    story.append(Paragraph(title, styles['Title']))
    story.append(Spacer(1, 0.2*inch))

    # Add report metadata (account ID and timestamp)
    report_time = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    account_name = get_account_name()
    story.append(Paragraph(f"Account Name: {account_name}", styles['Normal']))
    story.append(Paragraph(f"Account ID: {account_id}", styles['Normal']))
    story.append(Paragraph(f"Generated On: {report_time}", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))

    # Overall Summary
    story.append(Paragraph("Overall Compliance Summary", styles['Heading2']))
    summary_data = [
        ["Status", "Count"],
        ["Compliant", str(compliant_count)],
        ["Non-Compliant", str(non_compliant_count)],
        ["Total", str(compliant_count + non_compliant_count)]
    ]
    summary_table = Table(summary_data, colWidths=[2*inch, 1*inch])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (1, 0), colors.navy),
        ('TEXTCOLOR', (0, 0), (1, 0), colors.white),
        ('ALIGN', (0, 0), (1, 0), 'CENTER'),
        ('FONTNAME', (0, 0), (1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (1, 0), 12),
        ('BACKGROUND', (0, 1), (1, -1), colors.lightgrey),
        ('GRID', (0, 0), (1, -1), 1, colors.black)
    ]))
    story.append(summary_table)
    story.append(Spacer(1, 0.3*inch))

    # Rule Compliance Status Section
    story.append(Paragraph("Rule Compliance Status", styles['Heading2']))
    if rules_summary:
        rule_data = [["Rule Name", "Status"]]
        for rule in rules_summary:
            status = rule.get('status', 'UNKNOWN')
            status_color = colors.green if status == 'COMPLIANT' else colors.red if status == 'NON_COMPLIANT' else colors.orange
            rule_data.append([rule.get('name', 'Unknown Rule'), status])
        
        rule_table = Table(rule_data, colWidths=[4*inch, 1.5*inch])
        rule_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (1, 0), colors.navy),
            ('TEXTCOLOR', (0, 0), (1, 0), colors.white),
            ('ALIGN', (0, 0), (1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (1, 0), 12),
            ('GRID', (0, 0), (1, -1), 1, colors.black),
            ('ALIGN', (1, 1), (1, -1), 'CENTER')
        ]))
        story.append(rule_table)
    else:
        story.append(Paragraph("No Config rules found or compliance data available.", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))

    # Non-Compliant Details Section
    story.append(Paragraph("Non-Compliant Rule Details", styles['Heading2']))
    if non_compliant_details:
        for rule_name, resources in non_compliant_details.items():
            story.append(Paragraph(f"Rule: {rule_name}", styles['Heading2']))
            
            if resources:
                resource_data = [["Resource Type", "Resource Name"]]
                for resource in resources:
                    resource_data.append([resource[0], resource[1]])
                
                resource_table = Table(resource_data, colWidths=[2*inch, 3.5*inch])
                resource_table.setStyle(TableStyle([
                    ('BACKGROUND', (0, 0), (1, 0), colors.navy),
                    ('TEXTCOLOR', (0, 0), (1, 0), colors.white),
                    ('ALIGN', (0, 0), (1, 0), 'CENTER'),
                    ('FONTNAME', (0, 0), (1, 0), 'Helvetica-Bold'),
                    ('BOTTOMPADDING', (0, 0), (1, 0), 12),
                    ('GRID', (0, 0), (1, -1), 1, colors.black)
                ]))
                story.append(resource_table)
            else:
                story.append(Paragraph("No specific resource details available.", styles['Normal']))
            
            story.append(Spacer(1, 0.2*inch))
    else:
        story.append(Paragraph("No non-compliant resources found.", styles['Normal']))
    
    # Build the PDF
    doc.build(story)
    buffer.seek(0)
    return buffer.read()

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
    account_name = get_account_name()
    print(f"Account Name: {account_name}")

    # Fetch compliance data from AWS Config
    print("Fetching compliance summary and rule details...")
    compliant_count, non_compliant_count, rules_summary, non_compliant_details = get_compliance_summary()
    print(f"Found {compliant_count} compliant and {non_compliant_count} non-compliant rules.")

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
