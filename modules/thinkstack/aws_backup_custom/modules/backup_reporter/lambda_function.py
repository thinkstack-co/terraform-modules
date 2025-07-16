"""AWS Backup Reporter Lambda Function.

Generates PDF reports of AWS Backup jobs and uploads them to S3.
"""

import datetime
import json
import os
import tempfile
from typing import Any, Dict, List, Optional, Tuple, Union, cast

# Type ignore for boto3 since we can't add stubs
import boto3  # type: ignore

from fpdf import FPDF  # type: ignore

# ENV VARS
REPORT_BUCKET = os.environ["REPORT_BUCKET"]
CUSTOMER_IDENTIFIER = os.environ.get("CUSTOMER_IDENTIFIER", "")
# Report configuration
REPORT_DAYS = int(os.environ.get("REPORT_DAYS", "1"))
if REPORT_DAYS < 1 or REPORT_DAYS > 7:
    REPORT_DAYS = 1  # Default to 1 day if invalid
# Vault configuration from environment
ENABLE_HOURLY = os.environ.get("ENABLE_HOURLY_REPORT", "true").lower() == "true"
ENABLE_DAILY = os.environ.get("ENABLE_DAILY_REPORT", "true").lower() == "true"
ENABLE_WEEKLY = os.environ.get("ENABLE_WEEKLY_REPORT", "true").lower() == "true"
ENABLE_MONTHLY = os.environ.get("ENABLE_MONTHLY_REPORT", "true").lower() == "true"
ENABLE_YEARLY = os.environ.get("ENABLE_YEARLY_REPORT", "true").lower() == "true"
# Vault name patterns
VAULT_NAME_PREFIX = os.environ.get("VAULT_NAME_PREFIX", "")
HOURLY_VAULT_NAME = os.environ.get("HOURLY_VAULT_NAME", f"{VAULT_NAME_PREFIX}hourly")
DAILY_VAULT_NAME = os.environ.get("DAILY_VAULT_NAME", f"{VAULT_NAME_PREFIX}daily")
WEEKLY_VAULT_NAME = os.environ.get("WEEKLY_VAULT_NAME", f"{VAULT_NAME_PREFIX}weekly")
MONTHLY_VAULT_NAME = os.environ.get("MONTHLY_VAULT_NAME", f"{VAULT_NAME_PREFIX}monthly")
YEARLY_VAULT_NAME = os.environ.get("YEARLY_VAULT_NAME", f"{VAULT_NAME_PREFIX}yearly")
# Vault sort order
VAULT_SORT_ORDER = os.environ.get(
    "VAULT_SORT_ORDER", "hourly,daily,weekly,monthly,yearly"
).split(",")

backup = boto3.client("backup")
s3 = boto3.client("s3")
sts = boto3.client("sts")


def get_time_period() -> Tuple[datetime.datetime, datetime.datetime]:
    """Get the time period for backup job queries based on REPORT_DAYS."""
    end_time = datetime.datetime.now()
    start_time = end_time - datetime.timedelta(days=REPORT_DAYS)
    return start_time, end_time


def get_vault_names() -> List[str]:
    """Get list of vault names to check based on enabled flags."""
    vault_names: List[str] = []
    if ENABLE_HOURLY and HOURLY_VAULT_NAME:
        vault_names.append(HOURLY_VAULT_NAME)
    if ENABLE_DAILY and DAILY_VAULT_NAME:
        vault_names.append(DAILY_VAULT_NAME)
    if ENABLE_WEEKLY and WEEKLY_VAULT_NAME:
        vault_names.append(WEEKLY_VAULT_NAME)
    if ENABLE_MONTHLY and MONTHLY_VAULT_NAME:
        vault_names.append(MONTHLY_VAULT_NAME)
    if ENABLE_YEARLY and YEARLY_VAULT_NAME:
        vault_names.append(YEARLY_VAULT_NAME)
    return vault_names


def get_resource_details(resource_arn: str) -> Tuple[str, str]:
    """Extract resource details from ARN."""
    # Example ARN: arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0
    parts = resource_arn.split(":")
    if len(parts) >= 6:
        service = parts[2]
        resource_part = parts[5]
        if "/" in resource_part:
            resource_type, resource_id = resource_part.split("/", 1)
        else:
            resource_type = resource_part
            resource_id = parts[6] if len(parts) > 6 else "Unknown"

        # Map service to friendly resource type names
        resource_type_map: Dict[str, Union[str, Dict[str, str]]] = {
            "ec2": {
                "instance": "EC2 Instance",
                "volume": "EBS Volume",
                "snapshot": "EBS Snapshot",
                "image": "AMI",
            },
            "rds": {
                "db": "RDS Database",
                "cluster": "RDS Cluster",
                "snapshot": "RDS Snapshot",
            },
            "elasticfilesystem": "EFS",
            "dynamodb": "DynamoDB Table",
            "s3": "S3 Bucket",
            "fsx": "FSx",
            "storagegateway": "Storage Gateway",
        }

        if service in resource_type_map:
            if isinstance(resource_type_map[service], dict):
                service_map = cast(Dict[str, str], resource_type_map[service])
                friendly_type = service_map.get(
                    resource_type, f"{service.upper()} {resource_type}"
                )
            else:
                friendly_type = str(resource_type_map[service])
        else:
            friendly_type = f"{service.upper()} {resource_type}"

        return resource_id, friendly_type

    return "Unknown", "Unknown"


def fetch_backup_jobs(
    vault_name: str, start_time: datetime.datetime, end_time: datetime.datetime
) -> List[Dict[str, Any]]:
    """Fetch backup jobs for a specific vault within the time period."""
    jobs: List[Dict[str, Any]] = []
    next_token: Optional[str] = None

    while True:
        params: Dict[str, Any] = {
            "ByBackupVaultName": vault_name,
            "ByCreatedAfter": start_time,
            "ByCreatedBefore": end_time,
            "MaxResults": 100,
        }
        if next_token:
            params["NextToken"] = next_token

        try:
            response = backup.list_backup_jobs(**params)
            jobs.extend(response.get("BackupJobs", []))
            next_token = response.get("NextToken")
            if not next_token:
                break
        except Exception as e:
            # Log the specific exception for troubleshooting
            print(f"Error fetching backup jobs for vault {vault_name}: {str(e)}")
            break

    return jobs


def get_resource_name(resource_arn: str) -> str:
    """Try to get the resource name from tags."""
    try:
        # Try to get tags using the backup service
        response = backup.list_tags(ResourceArn=resource_arn)
        tags = response.get("Tags", {})
        return tags.get("Name", "No Name Tag")
    except Exception as e:
        # If we can't get tags, return a default
        # This is expected for some resource types that don't support tagging
        print(f"Error getting resource name for {resource_arn}: {str(e)}")
        return "No Name Tag"


def determine_backup_type(vault_name: str) -> str:
    """Determine backup type from vault name."""
    vault_lower = vault_name.lower()
    if "hourly" in vault_lower:
        return "Hourly"
    if "daily" in vault_lower:
        return "Daily"
    if "weekly" in vault_lower:
        return "Weekly"
    if "monthly" in vault_lower:
        return "Monthly"
    if "yearly" in vault_lower:
        return "Yearly"
    return "Custom"


def generate_pdf(
    backup_data: Dict[str, List[Dict[str, Any]]],
    start_time: datetime.datetime,
    end_time: datetime.datetime,
    outfile: str,
) -> None:
    """Generate PDF report for backup status"""
    pdf = FPDF()
    pdf.unifontsubset = False
    pdf.add_page()

    # Header
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Customer: {CUSTOMER_IDENTIFIER}", ln=1, align="C")
    try:
        acct = sts.get_caller_identity()["Account"]
    except Exception as e:
        # This might happen if the Lambda role doesn't have STS permissions
        print(f"Error getting account ID: {str(e)}")
        acct = "Unknown"
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 8, f"AWS Account ID: {acct}", ln=1, align="C")

    pdf.set_font("Arial", "B", 14)
    pdf.cell(
        0,
        8,
        f"AWS Backup Status Report - Last {REPORT_DAYS} Day{'s' if REPORT_DAYS > 1 else ''}",
        ln=1,
        align="C",
    )
    pdf.set_font("Arial", size=10, style="I")
    start_str = start_time.strftime('%Y-%m-%d %H:%M')
    end_str = end_time.strftime('%Y-%m-%d %H:%M')
    pdf.cell(
        0,
        6,
        f"Period: {start_str} to {end_str} UTC",
        ln=1,
        align="C",
    )
    pdf.ln(6)

    # Summary statistics
    total_jobs = sum(len(jobs) for jobs in backup_data.values())
    successful_jobs = sum(
        len([j for j in jobs if j["State"] == "COMPLETED"])
        for jobs in backup_data.values()
    )
    failed_jobs = sum(
        len([j for j in jobs if j["State"] == "FAILED"])
        for jobs in backup_data.values()
    )
    running_jobs = sum(
        len([j for j in jobs if j["State"] in ["RUNNING", "PENDING", "CREATED"]])
        for jobs in backup_data.values()
    )

    pdf.set_font("Arial", "B", 12)
    summary_text = f"Total Backup Jobs: {total_jobs} | Successful: {successful_jobs}"
    summary_text += f" | Failed: {failed_jobs} | Running/Pending: {running_jobs}"
    pdf.cell(
        0,
        7,
        summary_text,
        ln=1,
        align="C",
    )
    pdf.ln(4)

    # Table header
    # Resource Name, Resource ID, Resource Type, Backup Type, Creation Time, Vault, Status
    col_widths = [35, 25, 30, 25, 30, 35, 20]
    headers = [
        "Resource Name",
        "Resource ID",
        "Resource Type",
        "Backup Type",
        "Creation Time",
        "Vault",
        "Status",
    ]
    h = 7

    pdf.set_font("Arial", "B", 9)
    pdf.set_fill_color(200, 200, 200)
    # Print table headers
    for i, header in enumerate(headers):
        pdf.cell(col_widths[i], h, header, border=1, fill=True, align="C")
    pdf.ln(h)

    # Sort vaults based on VAULT_SORT_ORDER
    def get_vault_priority(vault_item: Tuple[str, List[Dict[str, Any]]]) -> int:
        vault_name = vault_item[0]
        # Extract vault type from name
        vault_type = None
        for vtype in VAULT_SORT_ORDER:
            if vtype.lower() in vault_name.lower():
                vault_type = vtype
                break
        if vault_type and vault_type in VAULT_SORT_ORDER:
            return VAULT_SORT_ORDER.index(vault_type)
        return len(VAULT_SORT_ORDER)  # Put unknown vaults at the end

    # Rows grouped by vault
    pdf.set_font("Arial", size=8)
    for vault_name, jobs in sorted(backup_data.items(), key=get_vault_priority):
        if not jobs:
            continue

        # Sort jobs by creation time (newest first)
        sorted_jobs = sorted(
            jobs,
            key=lambda x: x.get("CreationDate", datetime.datetime.now()),
            reverse=True,
        )

        for job in sorted_jobs:
            resource_arn = job.get("ResourceArn", "Unknown")
            resource_id, resource_type = get_resource_details(resource_arn)
            resource_name = get_resource_name(resource_arn)
            backup_type = determine_backup_type(vault_name)
            creation_time = job.get("CreationDate", datetime.datetime.now())
            status = job.get("State", "Unknown")

            # Truncate long values
            resource_name = (
                resource_name[:30] + "..." if len(resource_name) > 30 else resource_name
            )
            resource_id = (
                resource_id[:20] + "..." if len(resource_id) > 20 else resource_id
            )
            vault_display = vault_name.replace(VAULT_NAME_PREFIX, "")[:30]

            # Color code based on status
            if status == "COMPLETED":
                pdf.set_text_color(0, 128, 0)  # Green
            elif status == "FAILED":
                pdf.set_text_color(255, 0, 0)  # Red
            elif status in ["RUNNING", "PENDING", "CREATED"]:
                pdf.set_text_color(255, 165, 0)  # Orange
            else:
                pdf.set_text_color(0, 0, 0)  # Black

            pdf.cell(col_widths[0], h, resource_name, border=1)
            pdf.cell(col_widths[1], h, resource_id, border=1)
            pdf.cell(col_widths[2], h, resource_type, border=1)
            pdf.cell(col_widths[3], h, backup_type, border=1)
            pdf.cell(
                col_widths[4],
                h,
                creation_time.strftime("%Y-%m-%d %H:%M"),
                border=1,
                align="C",
            )
            pdf.cell(col_widths[5], h, vault_display, border=1)
            pdf.cell(col_widths[6], h, status, border=1, align="C")
            pdf.ln(h)

            # Reset text color
            pdf.set_text_color(0, 0, 0)

            # Page break guard
            if pdf.get_y() > 260:
                pdf.add_page()
                # Reprint headers
                pdf.set_font("Arial", "B", 9)
                pdf.set_fill_color(200, 200, 200)
                for i, header in enumerate(headers):
                    pdf.cell(col_widths[i], h, header, border=1, fill=True, align="C")
                pdf.ln(h)
                pdf.set_font("Arial", size=8)

    # Failed jobs detail section if any
    if failed_jobs > 0:
        pdf.add_page()
        pdf.set_font("Arial", "B", 14)
        pdf.cell(0, 10, "Failed Backup Jobs Details", ln=1, align="C")
        pdf.ln(4)

        pdf.set_font("Arial", size=9)
        for vault_name, jobs in backup_data.items():
            failed = [j for j in jobs if j["State"] == "FAILED"]
            for job in failed:
                resource_arn = job.get("ResourceArn", "Unknown")
                resource_id, resource_type = get_resource_details(resource_arn)
                resource_name = get_resource_name(resource_arn)

                pdf.set_font("Arial", "B", 10)
                pdf.cell(0, 7, f"Resource: {resource_name} ({resource_id})", ln=1)
                pdf.set_font("Arial", size=9)
                pdf.cell(0, 6, f"Type: {resource_type} | Vault: {vault_name}", ln=1)
                pdf.cell(0, 6, f"Failed at: {job.get('CreationDate', 'Unknown')}", ln=1)
                if job.get("StatusMessage"):
                    pdf.multi_cell(
                        0, 5, f"Error: {job.get('StatusMessage', 'No error message')}"
                    )
                pdf.ln(4)

    pdf.output(outfile)


def lambda_handler(_event: Dict[str, Any], _context: Any) -> Dict[str, Any]:
    """Main Lambda handler function.

    Args:
        _event: Lambda event data (not used, prefixed with underscore)
        _context: Lambda context object (not used, prefixed with underscore)

    Returns:
        Dict with status information and S3 key of generated report
    """
    start_time, end_time = get_time_period()
    vault_names = get_vault_names()

    if not vault_names:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "No vaults enabled for reporting"}),
        }

    # Fetch backup jobs for each enabled vault
    backup_data = {}
    for vault_name in vault_names:
        jobs = fetch_backup_jobs(vault_name, start_time, end_time)
        if jobs:
            backup_data[vault_name] = jobs

    # Generate report filename
    now = datetime.datetime.now()
    year = now.year
    month = f"{now.month:02d}"
    day = f"{now.day:02d}"

    # Sanitize customer name for S3 key
    safe_customer = (
        (
            CUSTOMER_IDENTIFIER.lower()
            .replace(" ", "-")
            .replace("_", "-")
            .replace(".", "")
            .replace("/", "")
            .replace("\\", "")
        )
        if CUSTOMER_IDENTIFIER
        else "backup"
    )

    key = (
        f"{year}/{month}/{safe_customer}-backup-status-report-{year}-{month}-{day}.pdf"
    )

    # Generate and upload PDF
    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        generate_pdf(backup_data, start_time, end_time, tmp.name)
        s3.upload_file(tmp.name, REPORT_BUCKET, key)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "status": "ok",
                "s3_key": key,
                "vaults_checked": vault_names,
                "total_jobs": sum(len(jobs) for jobs in backup_data.values()),
            }
        ),
    }
