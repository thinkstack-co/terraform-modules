## Description
Module which builds out a VPC with multiple subnets for network segmentation, associated routes, gateways, and flow logs for all instances within the VPC.

Creates the following
-   VPC
-   Two private subnets, one in each of two AZs
-   Two public subnets, one in each of two AZs
-   Three database subnets, one in each of three AZs
-   Two DMZ subnets, one in each of the two AZs
-   Two NAT gateways for the private subnets
-   Two EIPs attached to the NAT gateways
-   One internet gateway
-   Three route tables. One for the public subnets, and two for each of the private subnets
-   Cloudwatch group
-   KMS key
-   KMS alias
-   IAM policy
-   IAM role
-   VPC flow log

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azs | A list of Availability zones in the region | `list` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| cloudwatch_name_prefix | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. | `string` | `"flow_logs_"` | no |
| cloudwatch_retention_in_days | (Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `365` | no |
| db_propagating_vgws | A list of VGWs the db route table should propagate. | `list` | `[]` | no |
| db_subnets_list | A list of database subnets inside the VPC. | `list` | <pre>[<br>  "10.11.11.0/24",<br>  "10.11.12.0/24",<br>  "10.11.13.0/24"<br>]</pre> | no |
| dmz_propagating_vgws | A list of VGWs the DMZ route table should propagate. | `list` | `[]` | no |
| dmz_subnets_list | A list of DMZ subnets inside the VPC. | `list` | <pre>[<br>  "10.11.101.0/24",<br>  "10.11.102.0/24",<br>  "10.11.103.0/24"<br>]</pre> | no |
| enable_dns_hostnames | (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false. | `bool` | `true` | no |
| enable_dns_support | (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true. | `bool` | `true` | no |
| enable_firewall | (Optional) A boolean flag to enable/disable the use of a firewall instance within the VPC. Defaults False. | `bool` | `false` | no |
| enable_nat_gateway | (Optional) A boolean flag to enable/disable the use of NAT gateways in the private subnets. Defaults True. | `bool` | `true` | no |
| enable_s3_endpoint | (Optional) A boolean flag to enable/disable the use of a S3 endpoint with the VPC. Defaults False | `bool` | `false` | no |
| enable_vpc_flow_logs | (Optional) A boolean flag to enable/disable the use of VPC flow logs with the VPC. Defaults True. | `bool` | `true` | no |
| flow_log_destination_type | (Optional) The type of the logging destination. Valid values: cloud-watch-logs, s3. Default: cloud-watch-logs. | `string` | `"cloud-watch-logs"` | no |
| flow_max_aggregation_interval | (Optional) The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: 60 seconds (1 minute) or 600 seconds (10 minutes). Default: 600. | `number` | `60` | no |
| flow_traffic_type | (Optional) The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL. | `string` | `"ALL"` | no |
| fw_dmz_network_interface_id | Firewall DMZ eni id | `list` | `[]` | no |
| fw_network_interface_id | Firewall network interface id | `list` | `[]` | no |
| iam_policy_description | (Optional, Forces new resource) Description of the IAM policy. | `string` | `"Used with flow logs to send packet capture logs to a CloudWatch log group"` | no |
| iam_policy_name_prefix | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name. | `string` | `"flow_log_policy_"` | no |
| iam_policy_path | (Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information. | `string` | `"/"` | no |
| iam_role_assume_role_policy | (Required) The policy that grants an entity permission to assume the role. | `string` | `See Policy` | no |
| iam_role_description | (Optional) The description of the role. | `string` | `"Role utilized for EC2 instances ENI flow logs. This role allows creation of log streams and adding logs to the log streams in cloudwatch"` | no |
| iam_role_force_detach_policies | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false. | `bool` | `false` | no |
| iam_role_max_session_duration | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `string` | `3600` | no |
| iam_role_name_prefix | (Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name. | `string` | `"flow_logs_role_"` | no |
| iam_role_permissions_boundary | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `""` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| key_customer_master_key_spec | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `SYMMETRIC_DEFAULT` | no |
| key_description | (Optional) The description of the key as viewed in AWS console. | `string` | `"CloudWatch kms key used to encrypt flow logs"` | no |
| key_deletion_window_in_days | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| key_enable_key_rotation | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| key_usage | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| key_is_enabled | (Optional) Specifies whether the key is enabled. Defaults to true. | `bool` | `true` | no |
| key_name_prefix | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/). | `string` | `"alias/flow_logs_key_"` | no |
| map_public_ip_on_launch | (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false. | `bool` | `true` | no |
| mgmt_propagating_vgws | A list of VGWs the mgmt route table should propagate. | `list` | `[]` | no |
| mgmt_subnets_list | A list of mgmt subnets inside the VPC. | `list` | <pre>[<br>  "10.11.61.0/24",<br>  "10.11.62.0/24",<br>  "10.11.63.0/24"<br>]</pre> | no |
| name | (Required) Name to be tagged on all of the resources as an identifier | `string` | `null` | yes |
| private_propagating_vgws | A list of VGWs the private route table should propagate. | `list` | `[]` | no |
| private_subnets_list | A list of private subnets inside the VPC. | `list` | <pre>[<br>  "10.11.1.0/24",<br>  "10.11.2.0/24",<br>  "10.11.3.0/24"<br>]</pre> | no |
| public_propagating_vgws | A list of VGWs the public route table should propagate. | `list` | `[]` | no |
| public_subnets_list | A list of public subnets inside the VPC. | `list` | <pre>[<br>  "10.11.201.0/24",<br>  "10.11.202.0/24",<br>  "10.11.203.0/24"<br>]</pre> | no |
| single_nat_gateway | (Optional) A boolean flag to enable/disable use of only a single shared NAT Gateway across all of your private networks. Defaults False. | `bool` | `false` | no |
| tags | A map of tags to add to all resources | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| vpc_cidr | The CIDR block for the VPC | `string` | `"10.11.0.0/16"` | no |
| vpc_region | The region for the VPC | `any` | n/a | yes |
| workspaces_propagating_vgws | A list of VGWs the workspaces route table should propagate. | `list` | `[]` | no |
| workspaces_subnets_list | A list of workspaces subnets inside the VPC. | `list` | <pre>[<br>  "10.11.21.0/24",<br>  "10.11.22.0/24",<br>  "10.11.23.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zone | n/a |
| db_route_table_ids | n/a |
| db_subnet_ids | n/a |
| default_security_group_id | n/a |
| dmz_route_table_ids | n/a |
| dmz_subnet_ids | n/a |
| igw_id | n/a |
| mgmt_route_table_ids | n/a |
| mgmt_subnet_ids | n/a |
| nat_eips | n/a |
| nat_eips_public_ips | n/a |
| natgw_ids | n/a |
| private_route_table_ids | n/a |
| private_subnet_ids | n/a |
| private_subnets | n/a |
| public_route_table_ids | n/a |
| public_subnet_ids | n/a |
| public_subnets | n/a |
| vpc_cidr_block | n/a |
| vpc_id | n/a |
| workspaces_route_table_ids | n/a |
| workspaces_subnet_ids | n/a |