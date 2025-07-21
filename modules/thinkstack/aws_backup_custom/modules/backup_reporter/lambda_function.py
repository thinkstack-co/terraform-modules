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
S3_KEY_PREFIX = os.environ.get("S3_KEY_PREFIX", "")
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


def fetch_recovery_points(vault_name: str) -> List[Dict[str, Any]]:
    """Fetch recovery points for a specific vault."""
    recovery_points: List[Dict[str, Any]] = []
    next_token: Optional[str] = None

    while True:
        params: Dict[str, Any] = {
            "BackupVaultName": vault_name,
            "MaxResults": 100,
        }
        if next_token:
            params["NextToken"] = next_token

        try:
            response = backup.list_recovery_points_by_backup_vault(**params)
            recovery_points.extend(response.get("RecoveryPoints", []))
            next_token = response.get("NextToken")
            if not next_token:
                break
        except Exception as e:
            # Log the specific exception for troubleshooting
            print(f"Error fetching recovery points for vault {vault_name}: {str(e)}")
            break

    return recovery_points


def get_recovery_point_details(recovery_point_arn: str) -> Dict[str, Any]:
    """Get detailed information about a recovery point."""
    try:
        response = backup.describe_recovery_point(
            BackupVaultName=recovery_point_arn.split("/")[-2],
            RecoveryPointArn=recovery_point_arn
        )
        return response
    except Exception as e:
        print(f"Error getting recovery point details for {recovery_point_arn}: {str(e)}")
        return {}


def process_recovery_points_by_resource(vault_name: str) -> Dict[str, Dict[str, Any]]:
    """Process recovery points and group them by resource."""
    recovery_points = fetch_recovery_points(vault_name)
    resources: Dict[str, Dict[str, Any]] = {}
    
    for rp in recovery_points:
        resource_arn = rp.get("ResourceArn", "")
        if not resource_arn:
            continue
            
        resource_id, resource_type = get_resource_details(resource_arn)
        resource_name = get_resource_name(resource_arn)
        creation_date = rp.get("CreationDate")
        status = rp.get("Status", "UNKNOWN")
        
        # Use resource ARN as the key to group recovery points by resource
        if resource_arn not in resources:
            resources[resource_arn] = {
                "resource_name": resource_name,
                "resource_id": resource_id,
                "resource_type": resource_type,
                "resource_arn": resource_arn,
                "vault_name": vault_name,
                "backup_type": determine_backup_type(vault_name),
                "recovery_points": [],
                "successful_count": 0,
                "failed_count": 0,
                "oldest_backup": None,
                "newest_backup": None,
            }
        
        # Add this recovery point to the resource
        resources[resource_arn]["recovery_points"].append({
            "creation_date": creation_date,
            "status": status,
            "recovery_point_arn": rp.get("RecoveryPointArn", "")
        })
        
        # Update counts
        if status == "COMPLETED":
            resources[resource_arn]["successful_count"] += 1
        else:
            resources[resource_arn]["failed_count"] += 1
        
        # Update oldest/newest backup times
        if creation_date:
            if (resources[resource_arn]["oldest_backup"] is None or 
                creation_date < resources[resource_arn]["oldest_backup"]):
                resources[resource_arn]["oldest_backup"] = creation_date
            
            if (resources[resource_arn]["newest_backup"] is None or 
                creation_date > resources[resource_arn]["newest_backup"]):
                resources[resource_arn]["newest_backup"] = creation_date
    
    return resources


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

    # Title
    pdf.cell(0, 10, f"Customer: {CUSTOMER_IDENTIFIER}", ln=1, align="C")
    pdf.ln(5)
    pdf.cell(0, 10, f"AWS Backup Status Report - Recovery Points Summary", ln=1, align="C")
    pdf.set_font("Arial", "I", 10)
    pdf.cell(
        0,
        10,
        f"Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')} UTC",
        ln=1,
        align="C",
    )
    pdf.ln(5)

    # Summary statistics - handle empty resource_data gracefully
    if not resource_data:
        total_resources = 0
        total_successful = 0
        total_failed = 0
    else:
        total_resources = sum(len(resources) for resources in resource_data.values())
        total_successful = sum(
            resource["successful_count"]
            for resources in resource_data.values()
            for resource in resources.values()
        )
        total_failed = sum(
            resource["failed_count"]
            for resources in resource_data.values()
            for resource in resources.values()
    )
    total_recovery_points = total_successful + total_failed

    pdf.set_font("Arial", "B", 12)
    pdf.cell(
        0,
        10,
        f"Total Resources: {total_resources} | Recovery Points: {total_recovery_points} | Successful: {total_successful} | Failed: {total_failed}",
        ln=1,
        align="C",
    )
    pdf.ln(5)

    # Generate report organized by Vault -> Server -> Summary
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, "Backup Summary by Vault and Resource", ln=1, align="C")
    pdf.ln(5)

    # Sort vaults based on VAULT_SORT_ORDER
    def get_vault_priority(vault_name: str) -> int:
        # Extract vault type from name
        vault_type = None
        for vtype in VAULT_SORT_ORDER:
            if vtype.lower() in vault_name.lower():
                vault_type = vtype
                break
        if vault_type and vault_type in VAULT_SORT_ORDER:
            return VAULT_SORT_ORDER.index(vault_type)
        return len(VAULT_SORT_ORDER)  # Put unknown vaults at the end

    # Process each vault
    for vault_name in sorted(resource_data.keys(), key=get_vault_priority):
        resources = resource_data[vault_name]
        if not resources:
            continue

        # Vault header
        pdf.set_font("Arial", "B", 14)
        pdf.set_fill_color(220, 220, 220)
        pdf.cell(0, 10, f"Vault: {vault_name}", ln=1, fill=True, border=1)
        pdf.ln(3)

        # Sort resources by name within this vault
        sorted_resources = sorted(
            resources.items(),
            key=lambda x: x[1].get("resource_name", "").lower()
        )

        # Process each resource in this vault
        pdf.set_font("Arial", size=10)
        for resource_arn, resource_info in sorted_resources:
            resource_name = resource_info.get("resource_name", "Unknown")
            resource_type = resource_info.get("resource_type", "Unknown")
            successful_count = resource_info.get("successful_count", 0)
            failed_count = resource_info.get("failed_count", 0)
            total_count = successful_count + failed_count
            oldest_backup = resource_info.get("oldest_backup")
            newest_backup = resource_info.get("newest_backup")

            # Format dates
            oldest_str = oldest_backup.strftime("%Y-%m-%d %H:%M") if oldest_backup else "N/A"
            newest_str = newest_backup.strftime("%Y-%m-%d %H:%M") if newest_backup else "N/A"

            # Resource header
            pdf.set_font("Arial", "B", 11)
            pdf.cell(0, 8, f"Server: {resource_name} ({resource_type})", ln=1)
            
            # Summary statistics
            pdf.set_font("Arial", size=9)
            pdf.cell(0, 6, f"  Total Recovery Points: {total_count}", ln=1)
            
            # Color code the success/failure counts
            if successful_count > 0:
                pdf.set_text_color(0, 128, 0)  # Green
                pdf.cell(0, 6, f"  Successful: {successful_count}", ln=1)
                pdf.set_text_color(0, 0, 0)  # Reset to black
            else:
                pdf.cell(0, 6, f"  Successful: {successful_count}", ln=1)
            
            if failed_count > 0:
                pdf.set_text_color(255, 0, 0)  # Red
                pdf.cell(0, 6, f"  Unsuccessful: {failed_count}", ln=1)
                pdf.set_text_color(0, 0, 0)  # Reset to black
            else:
                pdf.cell(0, 6, f"  Unsuccessful: {failed_count}", ln=1)
            
            pdf.cell(0, 6, f"  Oldest Snapshot: {oldest_str}", ln=1)
            pdf.cell(0, 6, f"  Most Recent: {newest_str}", ln=1)
            pdf.ln(4)  # Space between resources

            # Page break guard
            if pdf.get_y() > 250:
                pdf.add_page()

        pdf.ln(6)  # Space between vaults

    # Add summary section for failed recovery points if any
    if total_failed > 0:
        pdf.add_page()
        pdf.set_font("Arial", "B", 14)
        pdf.cell(0, 10, "Resources with Failed Recovery Points", ln=1, align="C")
        pdf.ln(4)

        pdf.set_font("Arial", size=9)
        for vault_name, resources in resource_data.items():
            for resource_arn, resource_info in resources.items():
                if resource_info.get("failed_count", 0) > 0:
                    resource_name = resource_info.get("resource_name", "Unknown")
                    resource_id = resource_info.get("resource_id", "Unknown")
                    resource_type = resource_info.get("resource_type", "Unknown")
                    failed_count = resource_info.get("failed_count", 0)

                    pdf.set_font("Arial", "B", 10)
                    pdf.cell(0, 7, f"Resource: {resource_name} ({resource_id})", ln=1)
                    pdf.set_font("Arial", size=9)
                    pdf.cell(0, 6, f"Type: {resource_type} | Vault: {vault_name}", ln=1)
                    pdf.cell(0, 6, f"Failed Recovery Points: {failed_count}", ln=1)
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

    # Fetch recovery points for each enabled vault
    resource_data = {}
    try:
        for vault_name in vault_names:
            try:
                resources = process_recovery_points_by_resource(vault_name)
                # Always add the vault to resource_data, even if empty
                resource_data[vault_name] = resources if resources is not None else {}
            except Exception as e:
                print(f"Error processing vault {vault_name}: {str(e)}")
                # Ensure we still add an empty entry for this vault
                resource_data[vault_name] = {}
    except Exception as e:
        print(f"Error in resource data collection: {str(e)}")
        # Ensure resource_data is always defined, even if empty
        resource_data = {vault: {} for vault in vault_names}

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

    # Build S3 key with optional prefix
    if S3_KEY_PREFIX:
        key = (
            f"{S3_KEY_PREFIX}/{year}/{month}/{safe_customer}-backup-status-report-{year}-{month}-{day}.pdf"
        )
    else:
        key = (
            f"{year}/{month}/{safe_customer}-backup-status-report-{year}-{month}-{day}.pdf"
        )

    # Generate and upload PDF
    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        generate_pdf(resource_data, start_time, end_time, tmp.name)
        s3.upload_file(tmp.name, REPORT_BUCKET, key)

    # Calculate totals for response - handle empty resource_data gracefully
    if not resource_data:
        total_resources = 0
        total_recovery_points = 0
    else:
        total_resources = sum(len(resources) for resources in resource_data.values())
        total_recovery_points = sum(
            resource["successful_count"] + resource["failed_count"]
            for resources in resource_data.values()
            for resource in resources.values()
        )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "status": "ok",
                "s3_key": key,
                "vaults_checked": vault_names,
                "total_resources": total_resources,
                "total_recovery_points": total_recovery_points,
            }
        ),
    }
