"""
AWS Network Diagram Generator (AWS Lambda)

Renders a simple AWS network diagram using the `diagrams` library (Graphviz under
the hood):
- Discovers VPCs, Subnets, and EC2 instances in a single region
- Draws a VPC -> Subnet -> EC2 hierarchy
- Uploads the generated PNG to S3

Requirements:
- `diagrams` Python library available in the Lambda package
- Graphviz runtime present in the Lambda environment (e.g., via a Lambda layer)

Environment variables:
- S3_BUCKET (str, required): S3 bucket to upload the diagram to
- AWS_REGION (str, optional): Region to scan; defaults to "us-east-1"

IAM permissions (exec role):
- s3:PutObject to the target bucket/key
"""

import logging
import os
import tempfile

import boto3
import botocore
from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2


def get_vpcs(ec2):  # ec2: boto3 EC2 client
    """Return all VPCs for the client's region.

    Parameters:
        ec2: boto3 EC2 client configured for the target region.

    Returns:
        list[dict]: Items from describe_vpcs()["Vpcs"].
    """
    return ec2.describe_vpcs()["Vpcs"]


def get_subnets(ec2):  # ec2: boto3 EC2 client
    """Return all subnets for the client's region.

    Parameters:
        ec2: boto3 EC2 client configured for the target region.

    Returns:
        list[dict]: Items from describe_subnets()["Subnets"].
    """
    return ec2.describe_subnets()["Subnets"]


def get_instances(ec2):  # ec2: boto3 EC2 client
    """Return EC2 instance reservations for the client's region.

    Note: EC2's DescribeInstances API returns a list of Reservations, each
    containing an "Instances" list.

    Parameters:
        ec2: boto3 EC2 client configured for the target region.

    Returns:
        list[dict]: Items from describe_instances()["Reservations"].
    """
    return ec2.describe_instances()["Reservations"]


def lambda_handler(event, context):  # AWS Lambda entry point
    """Render and upload an AWS network diagram.

    Steps:
      1. Read region and S3 bucket from environment
      2. Discover VPCs, Subnets, and EC2 Instances
      3. Render a PNG diagram into the Lambda /tmp space using diagrams/Graphviz
      4. Upload the PNG to S3 as "network_diagram.png"

    Environment:
      - S3_BUCKET: Destination S3 bucket (required)
      - AWS_REGION: Region to scan (optional; default "us-east-1")

    Returns:
      dict: Status message indicating success.
    """
    region = os.environ.get("AWS_REGION", "us-east-1")  # Default to us-east-1
    s3_bucket = os.environ["S3_BUCKET"]  # Required: destination bucket
    ec2 = boto3.client("ec2", region_name=region)  # EC2 client scoped to region

    vpcs = get_vpcs(ec2)  # Discover VPCs
    subnets = get_subnets(ec2)  # Discover Subnets
    instances = get_instances(ec2)  # Discover EC2 instances (via Reservations)

    with tempfile.TemporaryDirectory() as tmpdir:  # Ephemeral workspace (/tmp)
        diagram_path = os.path.join(tmpdir, "network_diagram.png")  # Local path
        # Build the diagram; show=False avoids opening window in headless Lambda.
        with Diagram("AWS Network Diagram", filename=diagram_path, show=False):
            # For each VPC, nest its subnets and then EC2 instances within those subnets
            for vpc in vpcs:  # Iterate discovered VPCs
                vpc_id = vpc["VpcId"]
                with Cluster(f"VPC {vpc_id}"):  # Visual grouping for the VPC
                    # Filter subnets that belong to the current VPC
                    for subnet in [s for s in subnets if s["VpcId"] == vpc_id]:
                        subnet_id = subnet["SubnetId"]
                        with Cluster(f"Subnet {subnet_id}"):  # Visual grouping
                            # Instances returned in Reservations; traverse to individual
                            for r in instances:
                                for inst in r["Instances"]:
                                    if inst["SubnetId"] == subnet_id:  # Place in subnet
                                        EC2(inst["InstanceId"])  # Render EC2 node
        # Upload to S3
        s3 = boto3.client("s3")  # S3 client for uploading the generated PNG
        try:
            s3.upload_file(diagram_path, s3_bucket, "network_diagram.png")  # key
        except botocore.exceptions.ClientError as e:
            logging.error(e)  # Log the error to CloudWatch Logs
            raise e  # Re-raise to fail the invocation for visibility
    return {"status": "diagram generated and uploaded"}  # Simple success message
