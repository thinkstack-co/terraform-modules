import boto3
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.enums import TA_CENTER
from datetime import datetime
import io
import os


def get_account_info():
    iam = boto3.client('iam')
    sts = boto3.client('sts')
    try:
        aliases = iam.list_account_aliases().get('AccountAliases', [])
        alias = aliases[0] if aliases else 'N/A'
    except Exception:
        alias = 'N/A'
    account_id = sts.get_caller_identity()['Account']
    return alias, account_id


def get_config_rules():
    config = boto3.client('config')
    rules = []
    paginator = config.get_paginator('describe_config_rules')
    for page in paginator.paginate():
        rules.extend(page['ConfigRules'])
    return rules


def get_compliance_status():
    config = boto3.client('config')
    status = {}
    paginator = config.get_paginator('describe_compliance_by_config_rule')
    for page in paginator.paginate():
        for rule in page['ComplianceByConfigRules']:
            status[rule['ConfigRuleName']] = rule['Compliance']['ComplianceType']
    return status


def get_non_compliant_resources(rule_name):
    config = boto3.client('config')
    resources = []
    paginator = config.get_paginator('get_compliance_details_by_config_rule')
    for page in paginator.paginate(ConfigRuleName=rule_name, ComplianceTypes=['NON_COMPLIANT']):
        for result in page['EvaluationResults']:
            res = result['EvaluationResultIdentifier']['EvaluationResultQualifier']
            resources.append({
                'ResourceType': res['ResourceType'],
                'ResourceId': res['ResourceId'],
                'ResourceName': res.get('ResourceName', res['ResourceId']),
                'ResourceArn': res.get('ResourceArn', res['ResourceId'])
            })
    return resources


def get_resource_name_from_tag(arn_or_id):
    client = boto3.client('resourcegroupstaggingapi')
    try:
        response = client.get_resources(ResourceARNList=[arn_or_id])
        for resource in response.get('ResourceTagMappingList', []):
            for tag in resource.get('Tags', []):
                if tag['Key'] == 'Name':
                    return tag['Value']
    except Exception:
        pass
    return arn_or_id


def get_iam_user_name(user_id):
    iam = boto3.client('iam')
    try:
        response = iam.get_user(UserName=user_id)
        return response['User']['UserName']
    except Exception:
        return user_id


def lambda_handler(event, context):
    alias, account_id = get_account_info()
    now = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    rules = get_config_rules()
    compliance = get_compliance_status()

    # Prepare data for tables
    compliant_count = sum(1 for v in compliance.values() if v == 'COMPLIANT')
    non_compliant_count = sum(1 for v in compliance.values() if v == 'NON_COMPLIANT')
    insufficient_data_count = sum(1 for v in compliance.values() if v == 'INSUFFICIENT_DATA')

    # Rule compliance table data
    rule_table_data = [["Rule Name", "Status"]]
    for rule in rules:
        name = rule['ConfigRuleName']
        status = compliance.get(name, 'UNKNOWN')
        rule_table_data.append([name, status])

    # Non-compliant resources data
    non_compliant_section = []
    for rule in rules:
        name = rule['ConfigRuleName']
        if compliance.get(name) == 'NON_COMPLIANT':
            non_compliant_resources = get_non_compliant_resources(name)
            if non_compliant_resources:
                non_compliant_section.append([f"Rule: {name}", "", ""])
                for res in non_compliant_resources:
                    arn = res.get('ResourceArn', res['ResourceId'])
                    resource_name = get_resource_name_from_tag(arn)
                    # If it's an IAM user, try to get the friendly user name
                    if res['ResourceType'] == 'AWS::IAM::User':
                        # Try to extract username from ARN, fallback to user ID
                        # ARN format: arn:aws:iam::<account_id>:user/<username>
                        parts = arn.split(':user/')
                        if len(parts) == 2:
                            user_name = parts[1]
                        else:
                            user_name = res['ResourceId']
                        resource_name = get_iam_user_name(user_name)
                    non_compliant_section.append([
                        resource_name,
                        res['ResourceType'],
                        arn
                    ])

    # Build PDF
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter, rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=40)
    elements = []
    styles = getSampleStyleSheet()
    title_style = styles['Heading1']
    subtitle_style = styles['Heading2']
    subtitle_style.alignment = TA_CENTER
    normal_style = styles['Normal']
    small_style = ParagraphStyle('small', fontSize=9, leading=12)
    table_header_style = ParagraphStyle('table_header', fontSize=11, leading=14, alignment=TA_CENTER, fontName='Helvetica-Bold')

    # Title
    elements.append(Paragraph("AWS Config Compliance Report", title_style))
    elements.append(Spacer(1, 10))
    elements.append(Paragraph(f"Account Alias: <b>{alias}</b>", normal_style))
    elements.append(Paragraph(f"Account Number: <b>{account_id}</b>", normal_style))
    elements.append(Paragraph(f"Generated: <b>{now}</b>", small_style))
    elements.append(Spacer(1, 18))

    # Compliance summary table #
    summary_data = [[
        Paragraph("<b>Status</b>", table_header_style),
        Paragraph("<b>Count</b>", table_header_style)
    ],
        ["Compliant Rules", compliant_count],
        ["Non-Compliant Rules", non_compliant_count],
        ["Insufficient Data", insufficient_data_count]
    ]
    summary_table = Table(summary_data, colWidths=[180, 80])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#555555')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
        ('BACKGROUND', (0, 1), (-1, -1), colors.whitesmoke),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.whitesmoke, colors.HexColor('#f5f5f5')]),
        ('BOX', (0, 0), (-1, -1), 1, colors.gray),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
    ]))
    elements.append(Paragraph("Overall Compliance Summary", subtitle_style))
    elements.append(summary_table)
    elements.append(Spacer(1, 18))

    # Rule compliance status table
    rule_table = Table(rule_table_data, colWidths=[300, 120])
    rule_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1a237e')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
        ('BACKGROUND', (0, 1), (-1, -1), colors.whitesmoke),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.whitesmoke, colors.HexColor('#e3e6f3')]),
        ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
        ('BOX', (0, 0), (-1, -1), 1, colors.gray),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
    ]))
    elements.append(Paragraph("Rule Compliance Status", subtitle_style))
    elements.append(rule_table)
    elements.append(Spacer(1, 24))

    # Non-compliant resources section
    elements.append(Paragraph("Non-Compliant Resources", subtitle_style))
    if non_compliant_section:
        noncomp_table = Table(
            [[Paragraph('<b>Resource Name</b>', table_header_style),
              Paragraph('<b>Type</b>', table_header_style),
              Paragraph('<b>ARN/ID</b>', table_header_style)]
            ] + non_compliant_section,
            colWidths=[180, 100, 240]
        )
        noncomp_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#b71c1c')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
            ('BACKGROUND', (0, 1), (-1, -1), colors.whitesmoke),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.whitesmoke, colors.HexColor('#ffeaea')]),
            ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
            ('BOX', (0, 0), (-1, -1), 1, colors.gray),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.lightgrey),
        ]))
        elements.append(noncomp_table)
    else:
        elements.append(Paragraph("<i>No non-compliant resources found.</i>", normal_style))

    doc.build(elements)
    buffer.seek(0)

    s3 = boto3.client('s3')
    now_dt = datetime.utcnow()
    bucket = os.environ.get('CONFIG_REPORT_BUCKET', 'liberty-prod-config-bucket-20250305204205543600000001')
    prefix = os.environ.get('REPORTER_OUTPUT_S3_PREFIX', 'compliance-reports/weekly/')
    key = f"{prefix}{now_dt.year}/{now_dt.strftime('%m')}/{now_dt.strftime('%d')}/compliance-report-{now_dt.strftime('%Y%m%d-%H%M%S')}.pdf"
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=buffer.getvalue(),
        ContentType='application/pdf'
    )

    return {
        'statusCode': 200,
        'body': f'Successfully uploaded PDF to s3://{bucket}/{key}'
    }
