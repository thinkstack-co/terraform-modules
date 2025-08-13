"""AWS Network Diagram Generator Lambda Function.

Generates network diagrams of AWS infrastructure and uploads them to S3.
"""

import logging
import os
import tempfile
from typing import Any, Dict, List

# Type ignore for boto3 and diagrams since we can't add stubs
import boto3  # type: ignore
import botocore  # type: ignore
from diagrams import Cluster, Diagram  # type: ignore
from diagrams.aws.compute import EC2  # type: ignore


def get_vpcs(ec2: Any) -> List[Dict[str, Any]]:
    # Get all VPCs in the AWS account (handle pagination)
    paginator = ec2.get_paginator("describe_vpcs")
    vpcs: List[Dict[str, Any]] = []
    for page in paginator.paginate():
        vpcs.extend(page.get("Vpcs", []))
    return vpcs


def get_subnets(ec2: Any) -> List[Dict[str, Any]]:
    # Get all subnets in the AWS account (handle pagination)
    paginator = ec2.get_paginator("describe_subnets")
    subnets: List[Dict[str, Any]] = []
    for page in paginator.paginate():
        subnets.extend(page.get("Subnets", []))
    return subnets


def get_instances(ec2: Any) -> List[Dict[str, Any]]:
    # Get all EC2 instances in the AWS account (handle pagination)
    paginator = ec2.get_paginator("describe_instances")
    reservations: List[Dict[str, Any]] = []
    for page in paginator.paginate():
        reservations.extend(page.get("Reservations", []))
    return reservations


def lambda_handler(_event: Dict[str, Any], _context: Any) -> Dict[str, str]:
    # Main Lambda handler function
    logging.basicConfig(level=logging.INFO)
    region = os.environ.get("AWS_REGION", "us-east-1")
    s3_bucket = os.environ["S3_BUCKET"]
    ec2 = boto3.client("ec2", region_name=region)
    vpcs = get_vpcs(ec2)
    subnets = get_subnets(ec2)
    instances = get_instances(ec2)

    with tempfile.TemporaryDirectory() as tmpdir:
        with Diagram(
            "AWS Network Diagram",
            filename="network_diagram",  # diagrams adds extension automatically
            outformat="png",
            outpath=tmpdir,
            show=False,
        ):
            for vpc in vpcs:
                vpc_id = vpc["VpcId"]
                with Cluster(f"VPC {vpc_id}"):
                    for subnet in [s for s in subnets if s["VpcId"] == vpc_id]:
                        subnet_id = subnet["SubnetId"]
                        with Cluster(f"Subnet {subnet_id}"):
                            for r in instances:
                                for inst in r["Instances"]:
                                    if inst["SubnetId"] == subnet_id:
                                        EC2(inst["InstanceId"])
        # Upload to S3
        s3 = boto3.client("s3")
        try:
            out_file = os.path.join(tmpdir, "network_diagram.png")
            s3.upload_file(out_file, s3_bucket, "network_diagram.png", ExtraArgs={"ContentType": "image/png"})
        except botocore.exceptions.ClientError as e:
            logging.error(e)
            raise e
    return {"status": "diagram generated and uploaded"}
