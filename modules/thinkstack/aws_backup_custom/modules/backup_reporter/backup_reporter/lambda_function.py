"""AWS Backup Reporter Lambda Function.

Generates PDF reports of AWS backup vaults, recovery points, and backup times across US regions.
"""

import datetime
import os
import tempfile
from typing import Any, Dict, List, Optional, Tuple, Union, cast
from collections import defaultdict

# Type ignore for boto3 since we can't add stubs
import boto3  # type: ignore
from fpdf import FPDF  # type: ignore

# ENV VARS
REPORT_BUCKET = os.environ["REPORT_BUCKET"]
CUSTOMER_IDENTIFIER = os.environ.get("CUSTOMER_IDENTIFIER", "")

# US regions to scan for backup vaults
US_REGIONS = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]

s3 = boto3.client("s3")
sts = boto3.client("sts")


def get_all_backup_vaults() -> Dict[str, List[str]]:
    """Get all backup vaults across US regions.

    Returns:
        Dictionary mapping region names to lists of vault names in that region.
    """
    vaults_by_region = {}
    
    for region in US_REGIONS:
        print(f"Scanning region: {region}")
        backup_client = boto3.client("backup", region_name=region)
        vaults_by_region[region] = []
        
        try:
            paginator = backup_client.get_paginator("list_backup_vaults")
            for page in paginator.paginate():
                for vault in page["BackupVaultList"]:
                    vaults_by_region[region].append(vault["BackupVaultName"])
                    print(f"Found vault: {vault['BackupVaultName']} in {region}")
        except Exception as e:
            print(f"Error scanning region {region}: {str(e)}")
            continue
    
    return vaults_by_region


def get_vault_summary(vault_name: str, region: str) -> Dict[str, Any]:
    """
    Get summary information for a specific backup vault (fast version).

    Args:
        vault_name: Name of the backup vault
        region: AWS region where the vault is located

    Returns:
        Dictionary containing:
        {
          "total_recovery_points": int,
          "vault_size_bytes": int,
          "creation_date": datetime_string
        }
    """
    backup_client = boto3.client("backup", region_name=region)
    
    try:
        # Get vault details (fast)
        vault_response = backup_client.describe_backup_vault(BackupVaultName=vault_name)
        
        # Count recovery points (much faster than processing each one)
        total_recovery_points = 0
        try:
            paginator = backup_client.get_paginator("list_recovery_points_by_backup_vault")
            for page in paginator.paginate(BackupVaultName=vault_name):
                total_recovery_points += len(page["RecoveryPoints"])
        except Exception as e:
            print(f"Error counting recovery points for vault {vault_name}: {str(e)}")
        
        return {
            "total_recovery_points": total_recovery_points,
            "vault_size_bytes": vault_response.get("NumberOfRecoveryPoints", 0),
            "creation_date": vault_response.get("CreationDate")
        }
        
    except Exception as e:
        print(f"Error getting vault summary for {vault_name} in {region}: {str(e)}")
        return {
            "total_recovery_points": 0,
            "vault_size_bytes": 0,
            "creation_date": None
        }


def get_backup_job_status_overview(region: str) -> Dict[str, Any]:
    """Get backup job status overview for a region (like the screenshot).

    Args:
        region: AWS region to check backup jobs

    Returns:
        Dictionary with job status counts and error examples:
        {
          "completed": int,
          "completed_with_issues": int,
          "failed": int,
          "expired": int,
          "running": int,
          "error_examples": ["example error message", ...]
        }
    """
    backup_client = boto3.client("backup", region_name=region)
    
    # Initialize counters
    status_counts = {
        "completed": 0,
        "completed_with_issues": 0,
        "failed": 0,
        "expired": 0,
        "running": 0,
        "error_examples": []
    }
    
    try:
        # Get backup jobs from the last 14 days (like the screenshot)
        from_date = datetime.datetime.now() - datetime.timedelta(days=14)
        
        paginator = backup_client.get_paginator("list_backup_jobs")
        for page in paginator.paginate(ByCreatedAfter=from_date):
            for job in page["BackupJobs"]:
                status = job.get("State", "UNKNOWN")
                status_message = job.get("StatusMessage", "")
                
                if status == "COMPLETED":
                    # AWS uses specific criteria for "completed with issues"
                    # Let's check the actual fields AWS uses for this determination
                    
                    # Check if there's a specific "MessageCategory" field that indicates issues
                    message_category = job.get("MessageCategory", "")
                    
                    # AWS typically marks jobs as "completed with issues" based on:
                    # 1. MessageCategory field
                    # 2. Specific status messages
                    # 3. Backup validation issues
                    
                    has_issues = False
                    
                    # Check MessageCategory first (this is what AWS console likely uses)
                    if message_category and message_category.upper() in ["WARNING", "ERROR", "VSS_ERROR"]:
                        has_issues = True
                    
                    # If no MessageCategory, fall back to status message analysis
                    elif status_message:
                        status_lower = status_message.lower()
                        # Be very specific about what constitutes an "issue"
                        has_issues = (
                            "vss error" in status_lower or
                            "warning:" in status_lower or
                            "error:" in status_lower or
                            "partial backup" in status_lower or
                            "backup completed with warnings" in status_lower or
                            "failed to" in status_lower
                        )
                    
                    if has_issues:
                        status_counts["completed_with_issues"] += 1
                        # Collect error examples (limit to 3 unique examples)
                        if len(status_counts["error_examples"]) < 3 and status_message:
                            if status_message not in status_counts["error_examples"]:
                                status_counts["error_examples"].append(status_message)
                    else:
                        status_counts["completed"] += 1
                elif status == "FAILED":
                    status_counts["failed"] += 1
                    # Collect error examples for failed jobs too
                    if len(status_counts["error_examples"]) < 3 and status_message:
                        if status_message not in status_counts["error_examples"]:
                            status_counts["error_examples"].append(status_message)
                elif status == "EXPIRED":
                    status_counts["expired"] += 1
                elif status in ["RUNNING", "PENDING", "ABORTING", "CREATED"]:
                    status_counts["running"] += 1
                    
    except Exception as e:
        print(f"Error getting backup job status for region {region}: {str(e)}")
    
    return status_counts


def generate_pdf(
    backup_data: Dict[str, Any], outfile: str
) -> None:
    """Generate a PDF report of AWS backup information.

    Args:
        backup_data: Dictionary containing vault summaries and job status by region
        outfile: Output file path for the PDF
    """
    pdf = FPDF()
    # patch missing attribute
    pdf.unifontsubset = False
    pdf.add_page()

    # Header
    pdf.set_font("Arial", "B", 16)
    pdf.cell(0, 10, f"Customer: {CUSTOMER_IDENTIFIER}", ln=1, align="C")
    try:
        acct = sts.get_caller_identity()["Account"]
    except Exception as e:
        print(f"Error getting account ID: {str(e)}")
        acct = "Unknown"
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 8, f"AWS Account ID: {acct}", ln=1, align="C")

    pdf.set_font("Arial", "B", 14)
    pdf.cell(0, 8, "AWS Backup Report - Recovery Points by Vault", ln=1, align="C")
    pdf.set_font("Arial", size=10, style="I")
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    pdf.cell(0, 6, f"Generated: {current_time}", ln=1, align="C")
    pdf.ln(6)

    # Calculate totals for summary
    total_vaults = 0
    total_recovery_points = 0
    
    for region_name, region_data in backup_data.items():
        if "vaults" in region_data:
            total_vaults += len(region_data["vaults"])
            for vault_data in region_data["vaults"].values():
                total_recovery_points += vault_data["total_recovery_points"]
    
    # Summary section
    pdf.set_font("Arial", "B", 12)
    pdf.set_fill_color(240, 240, 240)
    pdf.cell(0, 8, "AWS Backup Summary", ln=1, fill=True)
    pdf.set_font("Arial", size=10)
    pdf.cell(0, 6, f"Total Regions Scanned: {len(backup_data)}", ln=1)
    pdf.cell(0, 6, f"Total Backup Vaults: {total_vaults}", ln=1)
    pdf.cell(0, 6, f"Total Recovery Points: {total_recovery_points}", ln=1)
    pdf.ln(8)

    # For each region
    for region in sorted(backup_data.keys()):
        region_data = backup_data[region]
        
        # Region header
        pdf.set_font("Arial", "B", 14)
        pdf.set_fill_color(200, 220, 255)
        pdf.cell(0, 8, f"Region: {region}", ln=1, fill=True)
        pdf.ln(2)
        
        # Backup Job Status Overview
        if "job_status" in region_data:
            job_status = region_data["job_status"]
            pdf.set_font("Arial", "B", 12)
            pdf.cell(0, 6, "Backup Job Status (Last 14 Days):", ln=1)
            pdf.set_font("Arial", size=10)
            
            # Create a simple status table
            col_width = 35
            h = 6
            pdf.set_fill_color(220, 255, 220)  # Light green
            pdf.cell(col_width, h, f"Completed: {job_status['completed']:,}", border=1, fill=True)
            pdf.set_fill_color(255, 255, 200)  # Light yellow
            pdf.cell(col_width, h, f"With Issues: {job_status['completed_with_issues']:,}", border=1, fill=True)
            pdf.set_fill_color(255, 220, 220)  # Light red
            pdf.cell(col_width, h, f"Failed: {job_status['failed']:,}", border=1, fill=True)
            pdf.set_fill_color(255, 200, 200)  # Light red
            pdf.cell(col_width, h, f"Expired: {job_status['expired']:,}", border=1, fill=True)
            pdf.set_fill_color(200, 200, 255)  # Light blue
            pdf.cell(col_width, h, f"Running: {job_status['running']:,}", border=1, fill=True)
            pdf.ln(h + 2)
            
            # Add error examples if any exist
            if job_status.get("error_examples") and len(job_status["error_examples"]) > 0:
                pdf.set_font("Arial", "B", 10)
                pdf.cell(0, 6, "Example Error Messages:", ln=1)
                pdf.set_font("Arial", size=8)
                
                for i, error_msg in enumerate(job_status["error_examples"][:3], 1):
                    # Truncate very long error messages
                    display_error = error_msg[:120] + "..." if len(error_msg) > 120 else error_msg
                    pdf.cell(0, 5, f"{i}. {display_error}", ln=1)
                
                pdf.ln(2)
            else:
                pdf.ln(2)
        
        # Backup Vaults - show ALL vaults, even empty ones
        if "vaults" in region_data:
            pdf.set_font("Arial", "B", 12)
            pdf.cell(0, 6, "Backup Vaults:", ln=1)
            pdf.ln(2)
            
            # Vault table header
            col1, col2, col3 = 80, 40, 60
            h = 7
            pdf.set_font("Arial", "B", 10)
            pdf.set_fill_color(200, 200, 200)
            pdf.cell(col1, h, "Vault Name", border=1, fill=True)
            pdf.cell(col2, h, "Recovery Points", border=1, fill=True, align="C")
            pdf.cell(col3, h, "Created", border=1, fill=True, align="C")
            pdf.ln(h)
            
            # Vault rows
            pdf.set_font("Arial", size=9)
            for vault_name in sorted(region_data["vaults"].keys()):
                vault_data = region_data["vaults"][vault_name]
                
                # Format creation date
                created = "N/A"
                if vault_data["creation_date"]:
                    created = vault_data["creation_date"].strftime("%m/%d/%Y")
                
                # Truncate long vault names
                display_name = vault_name[:40] + "..." if len(vault_name) > 40 else vault_name
                
                pdf.cell(col1, h, display_name, border=1)
                pdf.cell(col2, h, f"{vault_data['total_recovery_points']:,}", border=1, align="C")
                pdf.cell(col3, h, created, border=1, align="C")
                pdf.ln(h)
            
            pdf.ln(6)
        else:
            pdf.set_font("Arial", size=10)
            pdf.cell(0, 6, "No backup vaults found in this region.", ln=1)
            pdf.ln(4)
            
        # Page break guard
        if pdf.get_y() > 250:
            pdf.add_page()

    pdf.output(outfile)


def lambda_handler(_event: Dict[str, Any], _context: Any) -> Dict[str, str]:
    """Main Lambda handler function.

    Args:
        _event: Lambda event data (not used, prefixed with underscore)
        _context: Lambda context object (not used, prefixed with underscore)

    Returns:
        Dict with status information and S3 key of generated report
    """
    print("Starting backup report generation...")
    
    # Get all backup vaults across US regions
    vaults_by_region = get_all_backup_vaults()
    
    # Collect backup data for all regions
    backup_data = {}
    for region, vault_names in vaults_by_region.items():
        print(f"Processing region {region}...")
        
        # Get backup job status overview for this region
        job_status = get_backup_job_status_overview(region)
        
        # Get vault summaries (fast) - include ALL vaults, even empty ones
        vaults = {}
        for vault_name in vault_names:
            print(f"Getting summary for vault {vault_name} in {region}...")
            vault_summary = get_vault_summary(vault_name, region)
            vaults[vault_name] = vault_summary
            print(f"Vault {vault_name}: {vault_summary['total_recovery_points']} recovery points")
        
        backup_data[region] = {
            "job_status": job_status,
            "vaults": vaults
        }
    
    # Generate S3 key for the report
    current_time = datetime.datetime.now()
    year = current_time.year
    month = f"{current_time.month:02d}"
    day = f"{current_time.day:02d}"
    
    # Sanitize customer name for S3 key
    safe_customer = (
        CUSTOMER_IDENTIFIER.lower()
        .replace(" ", "-")
        .replace("_", "-")
        .replace(".", "")
        .replace("/", "")
        .replace("\\", "")
    )
    key = f"{year}/{month}/{safe_customer}-backup-report-{year}-{month}-{day}.pdf"

    # Generate and upload the PDF report
    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        generate_pdf(backup_data, tmp.name)
        s3.upload_file(tmp.name, REPORT_BUCKET, key)
    
    print(f"Backup report generated successfully: {key}")
    return {"status": "ok", "s3_key": key}
