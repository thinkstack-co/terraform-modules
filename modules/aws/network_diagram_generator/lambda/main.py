import os
import sys
import tempfile
from datetime import datetime

# Configure environment to use Graphviz from Lambda Layer
# Lambda Layers are mounted to /opt
os.environ['PATH'] = '/opt/bin:' + os.environ['PATH']
os.environ['LD_LIBRARY_PATH'] = '/opt/lib:' + os.environ.get('LD_LIBRARY_PATH', '')

# Force the diagrams library to use the Layer's Graphviz
os.environ['GRAPHVIZ_DOT'] = '/opt/bin/dot'

import boto3  # type: ignore
import botocore  # type: ignore
from diagrams import Cluster, Diagram, Edge, Node  # type: ignore
from diagrams.aws.compute import EC2  # type: ignore
from diagrams.aws.network import ALB, ELB, NLB  # type: ignore
from diagrams.aws.network import VPC as VPCIcon  # type: ignore
from diagrams.aws.network import (PrivateSubnet,  # type: ignore
                                  PublicSubnet)
from diagrams.aws.security import WAF  # type: ignore
from diagrams.aws.storage import S3  # type: ignore

# Removed unused imports: General, CloudFront, Custom


# Custom Node classes for better visualization
class PublicSubnetNode(Node):
    _provider = "aws"
    _type = "network"
    _icon_dir = "resources"
    fontcolor = "black"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "public-subnet.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#e8f5e9",
            "color": "#4caf50",
        }


class PrivateSubnetNode(Node):
    _provider = "aws"
    _type = "network"
    _icon_dir = "resources"
    fontcolor = "white"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "private-subnet.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#e3f2fd",
            "color": "#2196f3",
        }


class VPCNode(Node):
    _provider = "aws"
    _type = "network"
    _icon_dir = "resources"
    fontcolor = "white"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "vpc.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#f3e5f5",
            "color": "#9c27b0",
        }


class EC2Node(Node):
    _provider = "aws"
    _type = "compute"
    _icon_dir = "resources"
    fontcolor = "black"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "ec2.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#fff3e0",
            "color": "#ff9800",
        }


class ELBNode(Node):
    _provider = "aws"
    _type = "network"
    _icon_dir = "resources"
    fontcolor = "white"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "elb.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#ffebee",
            "color": "#f44336",
        }


class TargetGroupNode(Node):
    _provider = "aws"
    _type = "network"
    _icon_dir = "resources"
    fontcolor = "black"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "target-group.png")
        self.graph_attr = {"style": "dashed", "color": "#f44336"}


class AZNode(Node):
    _provider = "aws"
    _type = "general"
    _icon_dir = "resources"
    fontcolor = "blue"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "az.png")
        self.graph_attr = {"style": "dotted", "color": "#3f51b5"}


class WAFNode(Node):
    _provider = "aws"
    _type = "security"
    _icon_dir = "resources"
    fontcolor = "white"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "waf.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#fce4ec",
            "color": "#e91e63",
        }


class S3Node(Node):
    _provider = "aws"
    _type = "storage"
    _icon_dir = "resources"
    fontcolor = "black"
    _shape = "box"

    def __init__(self, label):
        super().__init__(label, "s3.png")
        self.graph_attr = {
            "style": "filled",
            "fillcolor": "#e8f5e9",
            "color": "#4caf50",
        }


# Helper functions to fetch AWS resources and process data
def get_vpcs(ec2):
    return ec2.describe_vpcs()["Vpcs"]


def get_subnets(ec2):
    return ec2.describe_subnets()["Subnets"]


def get_instances(ec2):
    return ec2.describe_instances()["Reservations"]


def get_elbs(elb):
    try:
        return elb.describe_load_balancers()["LoadBalancers"]
    except Exception as e:
        print(f"Error fetching ELBs: {e}")
        return []


def get_target_groups(elb):
    try:
        return elb.describe_target_groups()["TargetGroups"]
    except Exception as e:
        print(f"Error fetching target groups: {e}")
        return []


def get_target_health(elb, target_group_arn):
    try:
        return elb.describe_target_health(TargetGroupArn=target_group_arn)[
            "TargetHealthDescriptions"
        ]
    except Exception as e:
        print(f"Error fetching target health: {e}")
        return []


def get_waf_web_acls(waf):
    try:
        # Try WAFv2 first
        response = waf.list_web_acls(Scope="REGIONAL")
        return response.get("WebACLs", [])
    except Exception as e:
        print(f"Error fetching WAF ACLs: {e}")
        return []


def get_waf_associations(waf, web_acl_arn):
    try:
        response = waf.list_resources_for_web_acl(
            WebACLArn=web_acl_arn, ResourceType="APPLICATION_LOAD_BALANCER"
        )
        return response.get("ResourceArns", [])
    except Exception as e:
        print(f"Error fetching WAF associations: {e}")
        return []


def get_s3_buckets(s3):
    try:
        return s3.list_buckets()["Buckets"]
    except Exception as e:
        print(f"Error fetching S3 buckets: {e}")
        return []


def process_ec2_instances_in_subnet(instances, subnet_id, instance_nodes):
    """Process EC2 instances in a subnet and add them to the diagram.

    Args:
        instances: List of EC2 instance reservations
        subnet_id: The subnet ID to filter instances by
        instance_nodes: Dictionary to store instance nodes
    """
    for reservation in instances:
        for instance in reservation["Instances"]:
            if (
                instance.get("SubnetId") == subnet_id
                and instance.get("State", {}).get("Name") == "running"
            ):
                instance_name = get_instance_name(instance)
                instance_type = instance.get("InstanceType", "")
                instance_nodes[instance["InstanceId"]] = EC2(
                    f"{instance_name}\n{instance_type}"
                )


def get_bucket_region(s3, bucket_name):
    try:
        response = s3.get_bucket_location(Bucket=bucket_name)
        region = response.get("LocationConstraint")
        return region if region else "us-east-1"
    except Exception as e:
        print(f"Error getting region for bucket {bucket_name}: {e}")
        return None


def get_resource_name(resource, default_key="Id"):
    """Extract name from tags or use ID"""
    for tag in resource.get("Tags", []):
        if tag["Key"] == "Name":
            return tag["Value"]
    return resource.get(default_key, "Unknown")


def get_instance_name(instance):
    return get_resource_name(instance, "InstanceId")


def get_vpc_name(vpc):
    return get_resource_name(vpc, "VpcId")


def get_subnet_name(subnet):
    return get_resource_name(subnet, "SubnetId")


def lambda_handler(event, context):
    region = os.environ.get("AWS_REGION", "us-east-1")
    s3_bucket = os.environ["S3_BUCKET"]

    # Initialize AWS clients
    ec2 = boto3.client("ec2", region_name=region)
    elb = boto3.client("elbv2", region_name=region)
    waf = boto3.client("wafv2", region_name=region)
    s3 = boto3.client("s3", region_name=region)

    # Fetch all resources
    vpcs = get_vpcs(ec2)
    subnets = get_subnets(ec2)
    instances = get_instances(ec2)
    elbs = get_elbs(elb)
    target_groups = get_target_groups(elb)
    web_acls = get_waf_web_acls(waf)
    s3_buckets = get_s3_buckets(s3)

    # Create mappings for easier lookup
    instance_map = {}
    for reservation in instances:
        for instance in reservation["Instances"]:
            instance_map[instance["InstanceId"]] = instance

    target_group_map = {tg["TargetGroupArn"]: tg for tg in target_groups}

    # Map load balancers to their target groups
    lb_to_tg = {}
    for lb in elbs:
        lb_to_tg[lb["LoadBalancerArn"]] = []
        # Get listeners for this load balancer
        try:
            listeners = elb.describe_listeners(LoadBalancerArn=lb["LoadBalancerArn"])[
                "Listeners"
            ]
            for listener in listeners:
                for action in listener.get("DefaultActions", []):
                    if action["Type"] == "forward" and "TargetGroupArn" in action:
                        lb_to_tg[lb["LoadBalancerArn"]].append(action["TargetGroupArn"])
        except Exception as e:
            print(f"Error getting listeners for {lb['LoadBalancerName']}: {e}")

    # Map WAF to load balancers
    waf_to_lb = {}
    for acl in web_acls:
        associations = get_waf_associations(waf, acl["ARN"])
        waf_to_lb[acl["ARN"]] = associations

    with tempfile.TemporaryDirectory() as tmpdir:
        # Generate timestamp for the filename
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        diagram_filename = f"network_diagram_{timestamp}"
        diagram_path = os.path.join(tmpdir, diagram_filename)

        with Diagram(
            "AWS Network Architecture",
            filename=diagram_path,
            show=False,
            graph_attr={"fontsize": "20", "bgcolor": "white"},
            node_attr={"fontsize": "12"},
            edge_attr={"fontsize": "10"},
        ):

            # Create WAF nodes first (they'll be at the top)
            waf_nodes = {}
            if web_acls:
                with Cluster(
                    "Web Application Firewalls", graph_attr={"bgcolor": "#fce4ec"}
                ):
                    for acl in web_acls:
                        waf_nodes[acl["ARN"]] = WAF(acl["Name"])

            # Create S3 bucket nodes
            s3_nodes = {}
            regional_buckets = [
                b for b in s3_buckets if get_bucket_region(s3, b["Name"]) == region
            ]
            if regional_buckets:
                with Cluster(
                    f"S3 Buckets ({region})", graph_attr={"bgcolor": "#e8f5e9"}
                ):
                    for bucket in regional_buckets[
                        :10
                    ]:  # Limit to 10 buckets for readability
                        s3_nodes[bucket["Name"]] = S3(bucket["Name"])

            # Process each VPC
            vpc_nodes = {}
            subnet_nodes = {}
            instance_nodes = {}
            lb_nodes = {}
            tg_nodes = {}

            for vpc in vpcs:
                vpc_id = vpc["VpcId"]
                vpc_name = get_vpc_name(vpc)
                vpc_cidr = vpc.get("CidrBlock", "")

                with Cluster(
                    f"VPC: {vpc_name}\n{vpc_cidr}", graph_attr={"bgcolor": "#f3e5f5"}
                ):
                    vpc_nodes[vpc_id] = VPCIcon(vpc_id)

                    # Get all AZs for this VPC
                    vpc_azs = sorted(
                        set(
                            [
                                s["AvailabilityZone"]
                                for s in subnets
                                if s["VpcId"] == vpc_id
                            ]
                        )
                    )

                    # Create load balancers for this VPC
                    vpc_lbs = [lb for lb in elbs if lb["VpcId"] == vpc_id]
                    if vpc_lbs:
                        with Cluster(
                            "Load Balancers", graph_attr={"bgcolor": "#ffebee"}
                        ):
                            for lb in vpc_lbs:
                                lb_name = lb["LoadBalancerName"]
                                lb_type = lb["Type"]
                                if lb_type == "application":
                                    lb_nodes[lb["LoadBalancerArn"]] = ALB(lb_name)
                                elif lb_type == "network":
                                    lb_nodes[lb["LoadBalancerArn"]] = NLB(lb_name)
                                else:
                                    lb_nodes[lb["LoadBalancerArn"]] = ELB(lb_name)

                    # Process each AZ
                    for az in vpc_azs:
                        with Cluster(
                            f"Availability Zone: {az}",
                            graph_attr={"bgcolor": "#e3f2fd", "style": "dashed"},
                        ):

                            # Public subnets in this AZ
                            public_subnets = [
                                s
                                for s in subnets
                                if s["VpcId"] == vpc_id
                                and s["AvailabilityZone"] == az
                                and s.get("MapPublicIpOnLaunch", False)
                            ]

                            if public_subnets:
                                with Cluster(
                                    "Public Subnets", graph_attr={"bgcolor": "#e8f5e9"}
                                ):
                                    for subnet in public_subnets:
                                        subnet_id = subnet["SubnetId"]
                                        subnet_name = get_subnet_name(subnet)
                                        subnet_cidr = subnet.get("CidrBlock", "")

                                        with Cluster(f"{subnet_name}\n{subnet_cidr}"):
                                            subnet_nodes[subnet_id] = PublicSubnet(
                                                subnet_id
                                            )

                                            # EC2 instances in this subnet
                                            for reservation in instances:
                                                for instance in reservation[
                                                    "Instances"
                                                ]:
                                                    if (
                                                        instance.get("SubnetId")
                                                        == subnet_id
                                                        and instance.get(
                                                            "State", {}
                                                        ).get("Name")
                                                        == "running"
                                                    ):
                                                        instance_name = (
                                                            get_instance_name(instance)
                                                        )
                                                        instance_type = instance.get(
                                                            "InstanceType", ""
                                                        )
                                                        instance_nodes[
                                                            instance["InstanceId"]
                                                        ] = EC2(
                                                            f"{instance_name}\n{instance_type}"
                                                        )

                            # Private subnets in this AZ
                            private_subnets = [
                                s
                                for s in subnets
                                if s["VpcId"] == vpc_id
                                and s["AvailabilityZone"] == az
                                and not s.get("MapPublicIpOnLaunch", False)
                            ]

                            if private_subnets:
                                with Cluster(
                                    "Private Subnets", graph_attr={"bgcolor": "#e3f2fd"}
                                ):
                                    for subnet in private_subnets:
                                        subnet_id = subnet["SubnetId"]
                                        subnet_name = get_subnet_name(subnet)
                                        subnet_cidr = subnet.get("CidrBlock", "")

                                        with Cluster(f"{subnet_name}\n{subnet_cidr}"):
                                            subnet_nodes[subnet_id] = PrivateSubnet(
                                                subnet_id
                                            )

                                            # EC2 instances in this subnet
                                            for reservation in instances:
                                                for instance in reservation[
                                                    "Instances"
                                                ]:
                                                    if (
                                                        instance.get("SubnetId")
                                                        == subnet_id
                                                        and instance.get(
                                                            "State", {}
                                                        ).get("Name")
                                                        == "running"
                                                    ):
                                                        instance_name = (
                                                            get_instance_name(instance)
                                                        )
                                                        instance_type = instance.get(
                                                            "InstanceType", ""
                                                        )
                                                        instance_nodes[
                                                            instance["InstanceId"]
                                                        ] = EC2(
                                                            f"{instance_name}\n{instance_type}"
                                                        )

                    # Create target groups for this VPC
                    vpc_tgs = [tg for tg in target_groups if tg["VpcId"] == vpc_id]
                    if vpc_tgs:
                        with Cluster(
                            "Target Groups",
                            graph_attr={"bgcolor": "#ffebee", "style": "dashed"},
                        ):
                            for tg in vpc_tgs:
                                tg_name = tg["TargetGroupName"]
                                tg_nodes[tg["TargetGroupArn"]] = TargetGroupNode(
                                    tg_name
                                )

            # Draw connections
            # WAF to Load Balancers
            for waf_arn, lb_arns in waf_to_lb.items():
                if waf_arn in waf_nodes:
                    for lb_arn in lb_arns:
                        if lb_arn in lb_nodes:
                            (
                                waf_nodes[waf_arn]
                                >> Edge(label="protects", style="dashed", color="red")
                                >> lb_nodes[lb_arn]
                            )

            # Load Balancers to Target Groups
            for lb_arn, tg_arns in lb_to_tg.items():
                if lb_arn in lb_nodes:
                    for tg_arn in tg_arns:
                        if tg_arn in tg_nodes:
                            (
                                lb_nodes[lb_arn]
                                >> Edge(
                                    label="forwards to", style="solid", color="blue"
                                )
                                >> tg_nodes[tg_arn]
                            )

            # Target Groups to Instances
            for tg_arn, tg in target_group_map.items():
                if tg_arn in tg_nodes:
                    targets = get_target_health(elb, tg_arn)
                    for target in targets:
                        instance_id = target["Target"]["Id"]
                        if instance_id in instance_nodes:
                            health = target["TargetHealth"]["State"]
                            color = "green" if health == "healthy" else "red"
                            (
                                tg_nodes[tg_arn]
                                >> Edge(label=health, style="dotted", color=color)
                                >> instance_nodes[instance_id]
                            )

        # Upload to S3 with organized path structure
        s3_client = boto3.client("s3")
        try:
            # Create organized S3 key with date structure
            now = datetime.now()
            year = now.strftime("%Y")
            month = now.strftime("%m")
            day = now.strftime("%d")

            # Upload the main diagram
            main_key = f"network-diagrams/{year}/{month}/{day}/{diagram_filename}.png"
            s3_client.upload_file(f"{diagram_path}.png", s3_bucket, main_key)

            # Also keep a "latest" version for easy access
            latest_key = "network-diagrams/latest/network_diagram.png"
            s3_client.upload_file(f"{diagram_path}.png", s3_bucket, latest_key)

            print(f"Diagram uploaded to s3://{s3_bucket}/{main_key}")
            print(f"Latest diagram available at s3://{s3_bucket}/{latest_key}")

        except botocore.exceptions.ClientError as e:
            print(f"Error uploading to S3: {e}")
            raise e

    return {
        "statusCode": 200,
        "body": {
            "status": "success",
            "message": "Network diagram generated and uploaded",
            "s3_bucket": s3_bucket,
            "s3_key": main_key,
            "timestamp": timestamp,
        },
    }
