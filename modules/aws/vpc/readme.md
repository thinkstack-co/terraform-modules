## Description
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
| db\_propagating\_vgws | A list of VGWs the db route table should propagate. | `list` | `[]` | no |
| db\_subnets\_list | A list of database subnets inside the VPC. | `list` | <pre>[<br>  "10.11.11.0/24",<br>  "10.11.12.0/24",<br>  "10.11.13.0/24"<br>]</pre> | no |
| dmz\_propagating\_vgws | A list of VGWs the DMZ route table should propagate. | `list` | `[]` | no |
| dmz\_subnets\_list | A list of DMZ subnets inside the VPC. | `list` | <pre>[<br>  "10.11.101.0/24",<br>  "10.11.102.0/24",<br>  "10.11.103.0/24"<br>]</pre> | no |
| enable\_dns\_hostnames | should be true if you want to use private DNS within the VPC | `bool` | `true` | no |
| enable\_dns\_support | should be true if you want to use private DNS within the VPC | `bool` | `true` | no |
| enable\_firewall | should be true if you are using a firewall to NAT traffic for the private subnets | `bool` | `false` | no |
| enable\_nat\_gateway | should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| enable\_s3\_endpoint | should be true if you want to provision an S3 endpoint to the VPC | `bool` | `false` | no |
| fw\_dmz\_network\_interface\_id | Firewall DMZ eni id | `list` | `[]` | no |
| fw\_network\_interface\_id | Firewall network interface id | `list` | `[]` | no |
| instance\_tenancy | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| map\_public\_ip\_on\_launch | should be false if you do not want to auto-assign public IP on launch | `bool` | `true` | no |
| mgmt\_propagating\_vgws | A list of VGWs the mgmt route table should propagate. | `list` | `[]` | no |
| mgmt\_subnets\_list | A list of mgmt subnets inside the VPC. | `list` | <pre>[<br>  "10.11.61.0/24",<br>  "10.11.62.0/24",<br>  "10.11.63.0/24"<br>]</pre> | no |
| name | Name to be used on all the resources as identifier | `string` | `"terraform"` | no |
| private\_propagating\_vgws | A list of VGWs the private route table should propagate. | `list` | `[]` | no |
| private\_subnets\_list | A list of private subnets inside the VPC. | `list` | <pre>[<br>  "10.11.1.0/24",<br>  "10.11.2.0/24",<br>  "10.11.3.0/24"<br>]</pre> | no |
| public\_propagating\_vgws | A list of VGWs the public route table should propagate. | `list` | `[]` | no |
| public\_subnets\_list | A list of public subnets inside the VPC. | `list` | <pre>[<br>  "10.11.201.0/24",<br>  "10.11.202.0/24",<br>  "10.11.203.0/24"<br>]</pre> | no |
| single\_nat\_gateway | should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| tags | A map of tags to add to all resources | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| vpc\_cidr | The CIDR block for the VPC | `string` | `"10.11.0.0/16"` | no |
| vpc\_region | The region for the VPC | `any` | n/a | yes |
| workspaces\_propagating\_vgws | A list of VGWs the workspaces route table should propagate. | `list` | `[]` | no |
| workspaces\_subnets\_list | A list of workspaces subnets inside the VPC. | `list` | <pre>[<br>  "10.11.21.0/24",<br>  "10.11.22.0/24",<br>  "10.11.23.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zone | n/a |
| db\_route\_table\_ids | n/a |
| db\_subnet\_ids | n/a |
| default\_security\_group\_id | n/a |
| dmz\_route\_table\_ids | n/a |
| dmz\_subnet\_ids | n/a |
| igw\_id | n/a |
| mgmt\_route\_table\_ids | n/a |
| mgmt\_subnet\_ids | n/a |
| nat\_eips | n/a |
| nat\_eips\_public\_ips | n/a |
| natgw\_ids | n/a |
| private\_route\_table\_ids | n/a |
| private\_subnet\_ids | n/a |
| private\_subnets | n/a |
| public\_route\_table\_ids | n/a |
| public\_subnet\_ids | n/a |
| public\_subnets | n/a |
| vpc\_cidr\_block | n/a |
| vpc\_id | n/a |
| workspaces\_route\_table\_ids | n/a |
| workspaces\_subnet\_ids | n/a |