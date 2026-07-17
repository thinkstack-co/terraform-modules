<!-- Blank module readme template: Do a search and replace with your text editor for the following: `module_name`, `module_description` -->
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/thinkstack-co/terraform-modules">
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">VPC Module</h3>
  <p align="center">
    Module which builds out a VPC with multiple subnets for network segmentation, associated routes, gateways, and flow logs for all instances within the VPC. See the terraform-docs output below for all built resources.
    <br />
    <a href="https://github.com/thinkstack-co/terraform-modules"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.thinkstack.co/">Think|Stack</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Report Bug</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- USAGE EXAMPLES -->

## Usage

### Simple Example

This example sends uses an internet gateway for the public subnets and NAT gateways for the internal subnets. It utilizes the 10.11.0.0/16 subnet space with /24 subnets for each segmented subnet per availability zone.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name                    = "client_prod_vpc"
    vpc_cidr                = "10.11.0.0/16"
    azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

### Firewall Example

This example sends all egress traffic out a EC2 instance acting as a firewall. It also changes the default VPC CIDR block and subnets.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name                    = "client_prod_vpc"
    vpc_cidr                = "10.11.0.0/16"
    azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    enable_firewall         = true
    fw_network_interface_id = module.aws_ec2_fortigate_fw.private_network_interface_id
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

### Setting Subnet Example

This example sends uses an internet gateway for the public subnets and NAT gateways for the internal subnets. It utilizes a unique 10.100.0.0/16 subnet space with /24 subnets for each segmented subnet per availability zone.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name                    = "client_prod_vpc"
    vpc_cidr                = "10.100.0.0/16"
    azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    db_subnets_list         = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
    dmz_subnets_list        = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]
    mgmt_subnets_list       = ["10.100.61.0/24", "10.100.62.0/24", "10.100.63.0/24"]
    private_subnets_list    = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
    public_subnets_list     = ["10.100.201.0/24", "10.100.202.0/24", "10.100.203.0/24"]
    workspaces_subnets_list = ["10.100.21.0/24", "10.100.22.0/24", "10.100.23.0/24"]
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

### Disabling an Availability Zone

`disabled_azs` is a global cascade. Any AZ name listed here is fully removed from the module — every subnet, route table, NAT gateway, EIP, route table association, and S3 endpoint association tied to that AZ is skipped across all subnet groups. The AZ stays in `azs` (so positional alignment with the `*_subnets_list` variables and `fw_network_interface_id` is preserved), it just produces no resources. CIDR slots for disabled AZs are still consumed positionally; do not remove them from the `*_subnets_list` variables.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name         = "client_prod_vpc"
    vpc_cidr     = "10.11.0.0/16"
    azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
    disabled_azs = ["us-east-1c"]
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

### Disabling an Entire Subnet Group

The `*_subnet_disabled` flags skip a whole subnet category across every AZ. Use these when a customer doesn't need a tier (e.g. no Workspaces deployment, no DMZ for firewall inspection). Disabling a group also skips its route tables, route table associations, default routes, and S3 endpoint associations.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name                       = "client_prod_vpc"
    vpc_cidr                   = "10.11.0.0/16"
    azs                        = ["us-east-1a", "us-east-1b", "us-east-1c"]
    dmz_subnet_disabled        = true
    workspaces_subnet_disabled = true
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

### Disabling Subnets in Specific AZs

The per-subnet-type `*_subnet_disabled_azs` lists give finer control than `disabled_azs`. Use them when you want to keep an AZ enabled for some subnet types but skip it for others — for example, public + private in all three AZs but db only in two. An AZ is skipped for a given subnet type if it appears in either `disabled_azs` or that type's `*_subnet_disabled_azs`.

```
module "vpc" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc"

    name                           = "client_prod_vpc"
    vpc_cidr                       = "10.11.0.0/16"
    azs                            = ["us-east-1a", "us-east-1b", "us-east-1c"]
    db_subnet_disabled_azs         = ["us-east-1c"]
    mgmt_subnet_disabled_azs       = ["us-east-1c"]
    workspaces_subnet_disabled_azs = ["us-east-1c"]
    tags = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "core_infrastructure"
    }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                    | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                  | resource    |
| [aws_eip.nateip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                                       | resource    |
| [aws_flow_log.vpc_flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                                           | resource    |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                         | resource    |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                               | resource    |
| [aws_iam_role_policy_attachment.role_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                    | resource    |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                                | resource    |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                            | resource    |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                  | resource    |
| [aws_nat_gateway.natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                                        | resource    |
| [aws_route.db_default_route_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                      | resource    |
| [aws_route.db_default_route_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                   | resource    |
| [aws_route.dmz_default_route_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                     | resource    |
| [aws_route.dmz_default_route_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                  | resource    |
| [aws_route.mgmt_default_route_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                    | resource    |
| [aws_route.mgmt_default_route_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                 | resource    |
| [aws_route.private_default_route_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                 | resource    |
| [aws_route.private_default_route_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                              | resource    |
| [aws_route.public_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                     | resource    |
| [aws_route.workspaces_default_route_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                              | resource    |
| [aws_route.workspaces_default_route_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                           | resource    |
| [aws_route_table.db_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                               | resource    |
| [aws_route_table.dmz_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                              | resource    |
| [aws_route_table.mgmt_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                             | resource    |
| [aws_route_table.private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                          | resource    |
| [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                           | resource    |
| [aws_route_table.workspaces_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                       | resource    |
| [aws_route_table_association.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                                   | resource    |
| [aws_route_table_association.dmz](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                                  | resource    |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                              | resource    |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                               | resource    |
| [aws_route_table_association.workspaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                           | resource    |
| [aws_security_group.security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                         | resource    |
| [aws_subnet.db_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                             | resource    |
| [aws_subnet.dmz_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                            | resource    |
| [aws_subnet.mgmt_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                           | resource    |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                        | resource    |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                         | resource    |
| [aws_subnet.workspaces_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                     | resource    |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                                          | resource    |
| [aws_vpc_endpoint.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                                | resource    |
| [aws_vpc_endpoint.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                                        | resource    |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                                         | resource    |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                                        | resource    |
| [aws_vpc_endpoint.ssm-contacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                               | resource    |
| [aws_vpc_endpoint.ssm-incidents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                              | resource    |
| [aws_vpc_endpoint.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                                | resource    |
| [aws_vpc_endpoint_route_table_association.private_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource    |
| [aws_vpc_endpoint_route_table_association.public_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association)  | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                           | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                             | data source |

## Inputs

| Name                                                                                                                        | Description                                                                                                                                                                                                                                                                                                                                                                                           | Type        | Default                                                                                                                                                                                                                                       | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_azs"></a> [azs](#input_azs)                                                                                  | A list of Availability zones in the region                                                                                                                                                                                                                                                                                                                                                            | `list`      | <pre>[<br> "us-east-2a",<br> "us-east-2b",<br> "us-east-2c"<br>]</pre>                                                                                                                                                                        |    no    |
| <a name="input_cloudwatch_name_prefix"></a> [cloudwatch_name_prefix](#input_cloudwatch_name_prefix)                         | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix.                                                                                                                                                                                                                                                                                                            | `string`    | `"flow_logs_"`                                                                                                                                                                                                                                |    no    |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch_retention_in_days](#input_cloudwatch_retention_in_days)       | (Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.                                                                                                           | `number`    | `90`                                                                                                                                                                                                                                          |    no    |
| <a name="input_db_propagating_vgws"></a> [db_propagating_vgws](#input_db_propagating_vgws)                                  | A list of VGWs the db route table should propagate.                                                                                                                                                                                                                                                                                                                                                   | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_db_subnets_list"></a> [db_subnets_list](#input_db_subnets_list)                                              | A list of database subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                            | `list`      | <pre>[<br> "10.11.11.0/24",<br> "10.11.12.0/24",<br> "10.11.13.0/24"<br>]</pre>                                                                                                                                                               |    no    |
| <a name="input_dmz_propagating_vgws"></a> [dmz_propagating_vgws](#input_dmz_propagating_vgws)                               | A list of VGWs the DMZ route table should propagate.                                                                                                                                                                                                                                                                                                                                                  | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_dmz_subnets_list"></a> [dmz_subnets_list](#input_dmz_subnets_list)                                           | A list of DMZ subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                                 | `list`      | <pre>[<br> "10.11.101.0/24",<br> "10.11.102.0/24",<br> "10.11.103.0/24"<br>]</pre>                                                                                                                                                            |    no    |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames)                               | (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.                                                                                                                                                                                                                                                                                                                 | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support)                                     | (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true.                                                                                                                                                                                                                                                                                                                    | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_enable_firewall"></a> [enable_firewall](#input_enable_firewall)                                              | (Optional) A boolean flag to enable/disable the use of a firewall instance within the VPC. Defaults False.                                                                                                                                                                                                                                                                                            | `bool`      | `false`                                                                                                                                                                                                                                       |    no    |
| <a name="input_enable_nat_gateway"></a> [enable_nat_gateway](#input_enable_nat_gateway)                                     | (Optional) A boolean flag to enable/disable the use of NAT gateways in the private subnets. Defaults True.                                                                                                                                                                                                                                                                                            | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_enable_s3_endpoint"></a> [enable_s3_endpoint](#input_enable_s3_endpoint)                                     | (Optional) A boolean flag to enable/disable the use of a S3 endpoint with the VPC. Defaults False                                                                                                                                                                                                                                                                                                     | `bool`      | `false`                                                                                                                                                                                                                                       |    no    |
| <a name="input_enable_ssm_vpc_endpoints"></a> [enable_ssm_vpc_endpoints](#input_enable_ssm_vpc_endpoints)                   | (Optional) A boolean flag to enable/disable SSM (Systems Manager) VPC endpoints. Defaults true.                                                                                                                                                                                                                                                                                                       | `bool`      | `false`                                                                                                                                                                                                                                       |    no    |
| <a name="input_enable_vpc_flow_logs"></a> [enable_vpc_flow_logs](#input_enable_vpc_flow_logs)                               | (Optional) A boolean flag to enable/disable the use of VPC flow logs with the VPC. Defaults True.                                                                                                                                                                                                                                                                                                     | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_flow_log_destination_type"></a> [flow_log_destination_type](#input_flow_log_destination_type)                | (Optional) The type of the logging destination. Valid values: cloud-watch-logs, s3. Default: cloud-watch-logs.                                                                                                                                                                                                                                                                                        | `string`    | `"cloud-watch-logs"`                                                                                                                                                                                                                          |    no    |
| <a name="input_flow_max_aggregation_interval"></a> [flow_max_aggregation_interval](#input_flow_max_aggregation_interval)    | (Optional) The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: 60 seconds (1 minute) or 600 seconds (10 minutes). Default: 600.                                                                                                                                                                                              | `number`    | `60`                                                                                                                                                                                                                                          |    no    |
| <a name="input_flow_traffic_type"></a> [flow_traffic_type](#input_flow_traffic_type)                                        | (Optional) The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL.                                                                                                                                                                                                                                                                                                                          | `string`    | `"ALL"`                                                                                                                                                                                                                                       |    no    |
| <a name="input_fw_dmz_network_interface_id"></a> [fw_dmz_network_interface_id](#input_fw_dmz_network_interface_id)          | Firewall DMZ eni id                                                                                                                                                                                                                                                                                                                                                                                   | `list(any)` | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_fw_network_interface_id"></a> [fw_network_interface_id](#input_fw_network_interface_id)                      | Firewall network interface id                                                                                                                                                                                                                                                                                                                                                                         | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_iam_policy_description"></a> [iam_policy_description](#input_iam_policy_description)                         | (Optional, Forces new resource) Description of the IAM policy.                                                                                                                                                                                                                                                                                                                                        | `string`    | `"Used with flow logs to send packet capture logs to a CloudWatch log group"`                                                                                                                                                                 |    no    |
| <a name="input_iam_policy_name_prefix"></a> [iam_policy_name_prefix](#input_iam_policy_name_prefix)                         | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name.                                                                                                                                                                                                                                                                                       | `string`    | `"flow_log_policy_"`                                                                                                                                                                                                                          |    no    |
| <a name="input_iam_policy_path"></a> [iam_policy_path](#input_iam_policy_path)                                              | (Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information.                                                                                                                                                                                                                                                                                                 | `string`    | `"/"`                                                                                                                                                                                                                                         |    no    |
| <a name="input_iam_role_assume_role_policy"></a> [iam_role_assume_role_policy](#input_iam_role_assume_role_policy)          | (Required) The policy that grants an entity permission to assume the role.                                                                                                                                                                                                                                                                                                                            | `string`    | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"vpc-flow-logs.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"` |    no    |
| <a name="input_iam_role_description"></a> [iam_role_description](#input_iam_role_description)                               | (Optional) The description of the role.                                                                                                                                                                                                                                                                                                                                                               | `string`    | `"Role utilized for EC2 instances ENI flow logs. This role allows creation of log streams and adding logs to the log streams in cloudwatch"`                                                                                                  |    no    |
| <a name="input_iam_role_force_detach_policies"></a> [iam_role_force_detach_policies](#input_iam_role_force_detach_policies) | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false.                                                                                                                                                                                                                                                                                            | `bool`      | `false`                                                                                                                                                                                                                                       |    no    |
| <a name="input_iam_role_max_session_duration"></a> [iam_role_max_session_duration](#input_iam_role_max_session_duration)    | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours.                                                                                                                                                  | `number`    | `3600`                                                                                                                                                                                                                                        |    no    |
| <a name="input_iam_role_name_prefix"></a> [iam_role_name_prefix](#input_iam_role_name_prefix)                               | (Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name.                                                                                                                                                                                                                                                                              | `string`    | `"flow_logs_role_"`                                                                                                                                                                                                                           |    no    |
| <a name="input_iam_role_permissions_boundary"></a> [iam_role_permissions_boundary](#input_iam_role_permissions_boundary)    | (Optional) The ARN of the policy that is used to set the permissions boundary for the role.                                                                                                                                                                                                                                                                                                           | `string`    | `""`                                                                                                                                                                                                                                          |    no    |
| <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy)                                           | A tenancy option for instances launched into the VPC                                                                                                                                                                                                                                                                                                                                                  | `string`    | `"default"`                                                                                                                                                                                                                                   |    no    |
| <a name="input_key_customer_master_key_spec"></a> [key_customer_master_key_spec](#input_key_customer_master_key_spec)       | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string`    | `"SYMMETRIC_DEFAULT"`                                                                                                                                                                                                                         |    no    |
| <a name="input_key_deletion_window_in_days"></a> [key_deletion_window_in_days](#input_key_deletion_window_in_days)          | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.                                                                                                                                                                                                                                                     | `number`    | `30`                                                                                                                                                                                                                                          |    no    |
| <a name="input_key_description"></a> [key_description](#input_key_description)                                              | (Optional) The description of the key as viewed in AWS console.                                                                                                                                                                                                                                                                                                                                       | `string`    | `"CloudWatch kms key used to encrypt flow logs"`                                                                                                                                                                                              |    no    |
| <a name="input_key_enable_key_rotation"></a> [key_enable_key_rotation](#input_key_enable_key_rotation)                      | (Optional) Specifies whether key rotation is enabled. Defaults to false.                                                                                                                                                                                                                                                                                                                              | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_key_is_enabled"></a> [key_is_enabled](#input_key_is_enabled)                                                 | (Optional) Specifies whether the key is enabled. Defaults to true.                                                                                                                                                                                                                                                                                                                                    | `string`    | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_key_name_prefix"></a> [key_name_prefix](#input_key_name_prefix)                                              | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/).                                                                                                                                                                                                                                                 | `string`    | `"alias/flow_logs_key_"`                                                                                                                                                                                                                      |    no    |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage)                                                                | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported.                                                                                                                                                                                                                                                            | `string`    | `"ENCRYPT_DECRYPT"`                                                                                                                                                                                                                           |    no    |
| <a name="input_map_public_ip_on_launch"></a> [map_public_ip_on_launch](#input_map_public_ip_on_launch)                      | (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.                                                                                                                                                                                                                                                                 | `bool`      | `true`                                                                                                                                                                                                                                        |    no    |
| <a name="input_mgmt_propagating_vgws"></a> [mgmt_propagating_vgws](#input_mgmt_propagating_vgws)                            | A list of VGWs the mgmt route table should propagate.                                                                                                                                                                                                                                                                                                                                                 | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_mgmt_subnets_list"></a> [mgmt_subnets_list](#input_mgmt_subnets_list)                                        | A list of mgmt subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                                | `list`      | <pre>[<br> "10.11.61.0/24",<br> "10.11.62.0/24",<br> "10.11.63.0/24"<br>]</pre>                                                                                                                                                               |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                               | (Required) Name to be tagged on all of the resources as an identifier                                                                                                                                                                                                                                                                                                                                 | `string`    | n/a                                                                                                                                                                                                                                           |   yes    |
| <a name="input_private_propagating_vgws"></a> [private_propagating_vgws](#input_private_propagating_vgws)                   | A list of VGWs the private route table should propagate.                                                                                                                                                                                                                                                                                                                                              | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_private_subnets_list"></a> [private_subnets_list](#input_private_subnets_list)                               | A list of private subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                             | `list`      | <pre>[<br> "10.11.1.0/24",<br> "10.11.2.0/24",<br> "10.11.3.0/24"<br>]</pre>                                                                                                                                                                  |    no    |
| <a name="input_public_propagating_vgws"></a> [public_propagating_vgws](#input_public_propagating_vgws)                      | A list of VGWs the public route table should propagate.                                                                                                                                                                                                                                                                                                                                               | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_public_subnets_list"></a> [public_subnets_list](#input_public_subnets_list)                                  | A list of public subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                              | `list`      | <pre>[<br> "10.11.201.0/24",<br> "10.11.202.0/24",<br> "10.11.203.0/24"<br>]</pre>                                                                                                                                                            |    no    |
| <a name="input_single_nat_gateway"></a> [single_nat_gateway](#input_single_nat_gateway)                                     | (Optional) A boolean flag to enable/disable use of only a single shared NAT Gateway across all of your private networks. Defaults False.                                                                                                                                                                                                                                                              | `bool`      | `false`                                                                                                                                                                                                                                       |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                               | (Optional) A mapping of tags to assign to the object.                                                                                                                                                                                                                                                                                                                                                 | `map`       | <pre>{<br> "created_by": "ThinkStack",<br> "environment": "prod",<br> "priority": "high",<br> "terraform": "true"<br>}</pre>                                                                                                                  |    no    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                                                                   | The CIDR block for the VPC                                                                                                                                                                                                                                                                                                                                                                            | `string`    | `"10.11.0.0/16"`                                                                                                                                                                                                                              |    no    |
| <a name="input_workspaces_propagating_vgws"></a> [workspaces_propagating_vgws](#input_workspaces_propagating_vgws)          | A list of VGWs the workspaces route table should propagate.                                                                                                                                                                                                                                                                                                                                           | `list`      | `[]`                                                                                                                                                                                                                                          |    no    |
| <a name="input_workspaces_subnets_list"></a> [workspaces_subnets_list](#input_workspaces_subnets_list)                      | A list of workspaces subnets inside the VPC.                                                                                                                                                                                                                                                                                                                                                          | `list`      | <pre>[<br> "10.11.21.0/24",<br> "10.11.22.0/24",<br> "10.11.23.0/24"<br>]</pre>                                                                                                                                                               |    no    |

## Outputs

| Name                                                                                                              | Description |
| ----------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_availability_zone"></a> [availability_zone](#output_availability_zone)                            | n/a         |
| <a name="output_db_route_table_ids"></a> [db_route_table_ids](#output_db_route_table_ids)                         | n/a         |
| <a name="output_db_subnet_ids"></a> [db_subnet_ids](#output_db_subnet_ids)                                        | n/a         |
| <a name="output_default_security_group_id"></a> [default_security_group_id](#output_default_security_group_id)    | n/a         |
| <a name="output_dmz_route_table_ids"></a> [dmz_route_table_ids](#output_dmz_route_table_ids)                      | n/a         |
| <a name="output_dmz_subnet_ids"></a> [dmz_subnet_ids](#output_dmz_subnet_ids)                                     | n/a         |
| <a name="output_igw_id"></a> [igw_id](#output_igw_id)                                                             | n/a         |
| <a name="output_mgmt_route_table_ids"></a> [mgmt_route_table_ids](#output_mgmt_route_table_ids)                   | n/a         |
| <a name="output_mgmt_subnet_ids"></a> [mgmt_subnet_ids](#output_mgmt_subnet_ids)                                  | n/a         |
| <a name="output_nat_eips"></a> [nat_eips](#output_nat_eips)                                                       | n/a         |
| <a name="output_nat_eips_public_ips"></a> [nat_eips_public_ips](#output_nat_eips_public_ips)                      | n/a         |
| <a name="output_natgw_ids"></a> [natgw_ids](#output_natgw_ids)                                                    | n/a         |
| <a name="output_private_route_table_ids"></a> [private_route_table_ids](#output_private_route_table_ids)          | n/a         |
| <a name="output_private_subnet_ids"></a> [private_subnet_ids](#output_private_subnet_ids)                         | n/a         |
| <a name="output_private_subnets"></a> [private_subnets](#output_private_subnets)                                  | n/a         |
| <a name="output_public_route_table_ids"></a> [public_route_table_ids](#output_public_route_table_ids)             | n/a         |
| <a name="output_public_subnet_ids"></a> [public_subnet_ids](#output_public_subnet_ids)                            | n/a         |
| <a name="output_public_subnets"></a> [public_subnets](#output_public_subnets)                                     | n/a         |
| <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output_vpc_cidr_block)                                     | n/a         |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                                                             | n/a         |
| <a name="output_workspaces_route_table_ids"></a> [workspaces_route_table_ids](#output_workspaces_route_table_ids) | n/a         |
| <a name="output_workspaces_subnet_ids"></a> [workspaces_subnet_ids](#output_workspaces_subnet_ids)                | n/a         |

<!-- END_TF_DOCS -->

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - info@thinkstack.co

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack/
[product-screenshot]: /images/screenshot.webp
[Terraform.io]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io
