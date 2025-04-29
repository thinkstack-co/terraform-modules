import io
import os
from datetime import datetime

import boto3
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


def lookup_iam_username_by_id(user_id):
    """
    Given the internal IAM UserId (AIDA…), return the console username
    by paging through IAM ListUsers.
    """
    iam = boto3.client("iam")
    paginator = iam.get_paginator("list_users")
    for page in paginator.paginate():
        for u in page.get("Users", []):
            if u.get("UserId") == user_id:
                return u.get("UserName")
    # if we didn’t find it, just return the ID
    return user_id


def get_account_info():
    import os

    sts = boto3.client("sts")
    org = boto3.client("organizations")
    account_id = sts.get_caller_identity()["Account"]
    # 1. Try Organizations API
    try:
        response = org.describe_account(AccountId=account_id)
        account_name = response["Account"]["Name"]
        return account_name, account_id
    except Exception as e:
        print(f"ERROR: Failed to fetch Organizations account name: {e}")
    # 2. Try environment variable
    account_env = os.environ.get("ACCOUNT_DISPLAY_NAME")
    if account_env:
        return account_env, account_id
    # 3. Fallback to IAM alias
    iam = boto3.client("iam")
    try:
        aliases = iam.list_account_aliases().get("AccountAliases", [])
        alias = aliases[0] if aliases else "N/A"
    except Exception:
        alias = "N/A"
    return alias, account_id


def get_config_rules():
    config = boto3.client("config")
    rules = []
    paginator = config.get_paginator("describe_config_rules")
    for page in paginator.paginate():
        rules.extend(page["ConfigRules"])
    return rules


def get_compliance_status():
    config = boto3.client("config")
    status = {}
    paginator = config.get_paginator("describe_compliance_by_config_rule")
    for page in paginator.paginate():
        for rule in page["ComplianceByConfigRules"]:
            status[rule["ConfigRuleName"]] = rule["Compliance"]["ComplianceType"]
    return status


def get_non_compliant_resources(rule_name):
    config = boto3.client("config")
    resources = []
    paginator = config.get_paginator("get_compliance_details_by_config_rule")

    for page in paginator.paginate(
        ConfigRuleName=rule_name, ComplianceTypes=["NON_COMPLIANT"]
    ):
        for result in page["EvaluationResults"]:
            res = result["EvaluationResultIdentifier"]["EvaluationResultQualifier"]

            if res["ResourceType"] == "AWS::IAM::User":
                user_id = res["ResourceId"]
                # Turn the internal ID into the login name
                user_name = lookup_iam_username_by_id(user_id)

                # Fetch the real ARN
                iam = boto3.client("iam")
                try:
                    arn = iam.get_user(UserName=user_name)["User"]["Arn"]
                except iam.exceptions.NoSuchEntityException:
                    # Fallback if the user no longer exists in IAM
                    account_id = boto3.client("sts").get_caller_identity()["Account"]
                    arn = f"arn:aws:iam::{account_id}:user/{user_name}"

                resources.append(
                    {
                        "ResourceType": "AWS::IAM::User",
                        "ResourceId": user_id,
                        "ResourceName": user_name,
                        "ResourceArn": arn,
                    }
                )

            else:
                resources.append(
                    {
                        "ResourceType": res["ResourceType"],
                        "ResourceId": res["ResourceId"],
                        "ResourceName": res.get("ResourceName", res["ResourceId"]),
                        "ResourceArn": res.get("ResourceArn", res["ResourceId"]),
                    }
                )

    return resources


def get_resource_name_from_tag(arn_or_id):
    client = boto3.client("resourcegroupstaggingapi")
    try:
        response = client.get_resources(ResourceARNList=[arn_or_id])
        for resource in response.get("ResourceTagMappingList", []):
            for tag in resource.get("Tags", []):
                if tag["Key"] == "Name":
                    return tag["Value"]
    except Exception:
        pass
    return arn_or_id


def get_iam_user_name(user_id):
    iam = boto3.client("iam")
    try:
        response = iam.get_user(UserName=user_id)
        return response["User"]["UserName"]
    except Exception:
        return user_id


def lambda_handler(event, context):
    account_name, account_id = get_account_info()
    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    rules = get_config_rules()
    compliance = get_compliance_status()

    # Prepare data for tables
    compliant_count = sum(1 for v in compliance.values() if v == "COMPLIANT")
    non_compliant_count = sum(1 for v in compliance.values() if v == "NON_COMPLIANT")
    insufficient_data_count = sum(
        1 for v in compliance.values() if v == "INSUFFICIENT_DATA"
    )

    # Rule compliance table data
    rule_table_data = [["Rule Name", "Status"]]
    for rule in rules:
        name = rule["ConfigRuleName"]
        status = compliance.get(name, "UNKNOWN")
        rule_table_data.append([name, status])

    # Non-compliant resources section
    non_compliant_section = []
    for rule in rules:
        name = rule["ConfigRuleName"]
        if compliance.get(name) == "NON_COMPLIANT":
            non_compliant_resources = get_non_compliant_resources(name)
            if non_compliant_resources:
                non_compliant_section.append([f"Rule: {name}", "", ""])
                for res in non_compliant_resources:
                    arn = res["ResourceArn"]

                    if res["ResourceType"] == "AWS::IAM::User":
                        # Use the console username we looked up earlier
                        display_name = f"{res['ResourceName']} (IAM Username)"
                    else:
                        # For other resources, try to use the Name tag if present
                        display_name = get_resource_name_from_tag(arn)

                    non_compliant_section.append(
                        [display_name, res["ResourceType"], arn]
                    )

    # ── DEBUG FINAL ROWS ──
    print("DEBUG final non_compliant_section:", non_compliant_section)
    # ── END DEBUG FINAL ROWS ──

    # Build PDF (unchanged) …
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40,
    )
    elements = []
    styles = getSampleStyleSheet()
    title_style = styles["Heading1"]
    subtitle_style = styles["Heading2"]
    subtitle_style.alignment = TA_CENTER
    normal_style = styles["Normal"]
    small_style = ParagraphStyle("small", fontSize=9, leading=12)
    table_header_style = ParagraphStyle(
        "table_header",
        fontSize=11,
        leading=14,
        alignment=TA_CENTER,
        fontName="Helvetica-Bold",
    )

    elements.append(Paragraph("AWS Config Compliance Report", title_style))
    elements.append(Spacer(1, 10))
    elements.append(Paragraph(f"Account Name: <b>{account_name}</b>", normal_style))
    elements.append(Paragraph(f"Account Number: <b>{account_id}</b>", normal_style))
    elements.append(Paragraph(f"Generated: <b>{now}</b>", small_style))
    elements.append(Spacer(1, 18))

    # Compliance summary table
    summary_data = [
        [
            Paragraph("<b>Status</b>", table_header_style),
            Paragraph("<b>Count</b>", table_header_style),
        ],
        ["Compliant Rules", compliant_count],
        ["Non-Compliant Rules", non_compliant_count],
        ["Insufficient Data", insufficient_data_count],
    ]
    summary_table = Table(summary_data, colWidths=[180, 80])
    summary_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#555555")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 11),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 8),
                ("BACKGROUND", (0, 1), (-1, -1), colors.whitesmoke),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.whitesmoke, colors.HexColor("#f5f5f5")],
                ),
                ("BOX", (0, 0), (-1, -1), 1, colors.gray),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.lightgrey),
            ]
        )
    )
    elements.append(Paragraph("Overall Compliance Summary", subtitle_style))
    elements.append(summary_table)
    elements.append(Spacer(1, 18))

    # Rule compliance status table
    rule_table = Table(rule_table_data, colWidths=[300, 120])
    rule_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1a237e")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("ALIGN", (0, 0), (-1, 0), "CENTER"),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("BOTTOMPADDING", (0, 0), (-1, 0), 8),
                ("BACKGROUND", (0, 1), (-1, -1), colors.whitesmoke),
                (
                    "ROWBACKGROUNDS",
                    (0, 1),
                    (-1, -1),
                    [colors.whitesmoke, colors.HexColor("#e3e6f3")],
                ),
                ("ALIGN", (0, 1), (-1, -1), "LEFT"),
                ("BOX", (0, 0), (-1, -1), 1, colors.gray),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.lightgrey),
            ]
        )
    )
    elements.append(Paragraph("Rule Compliance Status", subtitle_style))
    elements.append(rule_table)
    elements.append(Spacer(1, 24))

    # Non-compliant resources table
    elements.append(Paragraph("Non-Compliant Resources", subtitle_style))
    if non_compliant_section:
        # Build a simple 2‑col table: Resource Name | Type
        table_data = [
            [
                Paragraph("<b>Resource Name</b>", table_header_style),
                Paragraph("<b>Type</b>", table_header_style),
            ]
        ]
        for name, rtype, arn in non_compliant_section:
            table_data.append(
                [Paragraph(name, normal_style), Paragraph(rtype, normal_style)]
            )

        noncomp_table = Table(table_data, colWidths=[300, 120])
        noncomp_table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#b71c1c")),
                    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                    ("ALIGN", (0, 0), (-1, -1), "LEFT"),
                    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                    ("FONTSIZE", (0, 0), (-1, -1), 10),
                    ("BOTTOMPADDING", (0, 0), (-1, 0), 8),
                    ("BACKGROUND", (0, 1), (-1, -1), colors.whitesmoke),
                    (
                        "ROWBACKGROUNDS",
                        (0, 1),
                        (-1, -1),
                        [colors.whitesmoke, colors.HexColor("#ffeaea")],
                    ),
                    ("BOX", (0, 0), (-1, -1), 1, colors.gray),
                    ("GRID", (0, 0), (-1, -1), 0.5, colors.lightgrey),
                ]
            )
        )
        elements.append(noncomp_table)

    else:
        elements.append(
            Paragraph("<i>No non-compliant resources found.</i>", normal_style)
        )

    doc.build(elements)
    buffer.seek(0)

    s3 = boto3.client("s3")
    now_dt = datetime.utcnow()
    bucket = os.environ.get(
        "CONFIG_REPORT_BUCKET", "liberty-prod-config-bucket-20250305204205543600000001"
    )
    prefix = os.environ.get("REPORTER_OUTPUT_S3_PREFIX", "compliance-reports/weekly/")
    key = (
        f"{prefix}{now_dt.year}/"
        f"{now_dt.strftime('%m')}/"
        f"{now_dt.strftime('%d')}/"
        f"compliance-report-{now_dt.strftime('%Y%m%d-%H%M%S')}.pdf"
    )
    s3.put_object(
        Bucket=bucket, Key=key, Body=buffer.getvalue(), ContentType="application/pdf"
    )

    return {
        "statusCode": 200,
        "body": f"Successfully uploaded PDF to s3://{bucket}/{key}",
    }
