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

<h3 align="center">RDS Cluster Module</h3>
  <p align="center">
    This module creates a RDS cluster.
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

```
module "webapp_prod_db_cluster" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/rds/cluster"

  availability_zones              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cluster_identifier              = "webapp-prod-cluster"
  database_name                   = "webapp_prod_cluster"
  db_subnet_group_name            = "webapp_subnet_group"
  db_cluster_parameter_group_name = module.webapp_aurora_cluster_parameter_group.id[0]
  engine                          = "aurora"
  engine_mode                     = "provisioned"
  engine_version                  = "5.6.mysql_aurora.1.22.2"
  master_password                 = var.webapp_db_master_password
  master_username                 = var.webapp_db_master_username
  port                            = "3306"
  preferred_backup_window         = "05:00-07:00"
  preferred_maintenance_window    = "Sun:09:00-Sun:09:30"
  vpc_security_group_ids          = [module.webapp_db_sg.id]
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

| Name                                                                                                               | Type     |
| ------------------------------------------------------------------------------------------------------------------ | -------- |
| [aws_kms_alias.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)         | resource |
| [aws_kms_key.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)             | resource |
| [aws_rds_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |

## Inputs

| Name                                                                                                                                       | Description                                                                                                                                                                                                                                                                                                                                                                                           | Type        | Default                                           | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------- | :------: |
| <a name="input_apply_immediately"></a> [apply_immediately](#input_apply_immediately)                                                       | (Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information.                                                                                                                                                                                                           | `bool`      | `false`                                           |    no    |
| <a name="input_availability_zones"></a> [availability_zones](#input_availability_zones)                                                    | (Optional) A list of EC2 Availability Zones that instances in the DB cluster can be created in                                                                                                                                                                                                                                                                                                        | `list(any)` | n/a                                               |   yes    |
| <a name="input_backup_retention_period"></a> [backup_retention_period](#input_backup_retention_period)                                     | (Optional) The days to retain backups for. Default 1                                                                                                                                                                                                                                                                                                                                                  | `number`    | `30`                                              |    no    |
| <a name="input_cluster_identifier"></a> [cluster_identifier](#input_cluster_identifier)                                                    | (Optional, Forces new resources) The cluster identifier. If omitted, Terraform will assign a random, unique identifier.                                                                                                                                                                                                                                                                               | `string`    | n/a                                               |   yes    |
| <a name="input_database_name"></a> [database_name](#input_database_name)                                                                   | (Optional) Name for an automatically created database on cluster creation. There are different naming restrictions per database engine: RDS Naming Constraints                                                                                                                                                                                                                                        | `string`    | n/a                                               |   yes    |
| <a name="input_db_cluster_parameter_group_name"></a> [db_cluster_parameter_group_name](#input_db_cluster_parameter_group_name)             | (Optional) A cluster parameter group to associate with the cluster.                                                                                                                                                                                                                                                                                                                                   | `string`    | n/a                                               |   yes    |
| <a name="input_db_subnet_group_name"></a> [db_subnet_group_name](#input_db_subnet_group_name)                                              | (Optional) A DB subnet group to associate with this DB instance. NOTE: This must match the db_subnet_group_name specified on every aws_rds_cluster_instance in the cluster.                                                                                                                                                                                                                           | `string`    | n/a                                               |   yes    |
| <a name="input_engine"></a> [engine](#input_engine)                                                                                        | (Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora.                                                                                                                                                                                                                                                                                                        | `string`    | n/a                                               |   yes    |
| <a name="input_engine_mode"></a> [engine_mode](#input_engine_mode)                                                                         | (Optional) The database engine mode. Valid values: provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless.                                                                                                                                                                                                                                   | `string`    | n/a                                               |   yes    |
| <a name="input_engine_version"></a> [engine_version](#input_engine_version)                                                                | (Optional) The database engine version.                                                                                                                                                                                                                                                                                                                                                               | `string`    | n/a                                               |   yes    |
| <a name="input_iam_database_authentication_enabled"></a> [iam_database_authentication_enabled](#input_iam_database_authentication_enabled) | (Optional) Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled.                                                                                                                                                                                                                                                                        | `bool`      | `false`                                           |    no    |
| <a name="input_iam_roles"></a> [iam_roles](#input_iam_roles)                                                                               | (Optional) A List of ARNs for the IAM roles to associate to the RDS Cluster.                                                                                                                                                                                                                                                                                                                          | `list(any)` | `[]`                                              |    no    |
| <a name="input_key_customer_master_key_spec"></a> [key_customer_master_key_spec](#input_key_customer_master_key_spec)                      | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string`    | `"SYMMETRIC_DEFAULT"`                             |    no    |
| <a name="input_key_deletion_window_in_days"></a> [key_deletion_window_in_days](#input_key_deletion_window_in_days)                         | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.                                                                                                                                                                                                                                                     | `number`    | `30`                                              |    no    |
| <a name="input_key_description"></a> [key_description](#input_key_description)                                                             | (Optional) The description of the key as viewed in AWS console.                                                                                                                                                                                                                                                                                                                                       | `string`    | `"CloudTrail kms key used to encrypt audit logs"` |    no    |
| <a name="input_key_enable_key_rotation"></a> [key_enable_key_rotation](#input_key_enable_key_rotation)                                     | (Optional) Specifies whether key rotation is enabled. Defaults to false.                                                                                                                                                                                                                                                                                                                              | `bool`      | `true`                                            |    no    |
| <a name="input_key_is_enabled"></a> [key_is_enabled](#input_key_is_enabled)                                                                | (Optional) Specifies whether the key is enabled. Defaults to true.                                                                                                                                                                                                                                                                                                                                    | `bool`      | `true`                                            |    no    |
| <a name="input_key_name_prefix"></a> [key_name_prefix](#input_key_name_prefix)                                                             | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/).                                                                                                                                                                                                                                                 | `string`    | `"alias/rds_key_"`                                |    no    |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage)                                                                               | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported.                                                                                                                                                                                                                                                            | `string`    | `"ENCRYPT_DECRYPT"`                               |    no    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                                                            | (Optional) The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true.                                                                                                                                                                                                                                                                                 | `string`    | `""`                                              |    no    |
| <a name="input_master_password"></a> [master_password](#input_master_password)                                                             | (Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints                                                                                                                                                                                          | `string`    | n/a                                               |   yes    |
| <a name="input_master_username"></a> [master_username](#input_master_username)                                                             | (Required unless a snapshot_identifier is provided) Username for the master DB user. Please refer to the RDS Naming Constraints                                                                                                                                                                                                                                                                       | `string`    | n/a                                               |   yes    |
| <a name="input_port"></a> [port](#input_port)                                                                                              | (Optional) The port on which the DB accepts connections                                                                                                                                                                                                                                                                                                                                               | `string`    | n/a                                               |   yes    |
| <a name="input_preferred_backup_window"></a> [preferred_backup_window](#input_preferred_backup_window)                                     | (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region. e.g. 04:00-09:00                                                                                                                            | `string`    | n/a                                               |   yes    |
| <a name="input_preferred_maintenance_window"></a> [preferred_maintenance_window](#input_preferred_maintenance_window)                      | (Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g. wed:04:00-wed:04:30                                                                                                                                                                                                                                                                                         | `string`    | n/a                                               |   yes    |
| <a name="input_scaling_configuration"></a> [scaling_configuration](#input_scaling_configuration)                                           | (Optional) Nested attribute with scaling properties. Only valid when engine_mode is set to serverless. More details below.                                                                                                                                                                                                                                                                            | `list(any)` | `[]`                                              |    no    |
| <a name="input_skip_final_snapshot"></a> [skip_final_snapshot](#input_skip_final_snapshot)                                                 | (Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false.                                                                                                   | `string`    | `false`                                           |    no    |
| <a name="input_snapshot_identifier"></a> [snapshot_identifier](#input_snapshot_identifier)                                                 | (Optional) Specifies whether or not to create this cluster from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05.                                                                                                                                                                                                                   | `string`    | `""`                                              |    no    |
| <a name="input_storage_encrypted"></a> [storage_encrypted](#input_storage_encrypted)                                                       | (Optional) Specifies whether the DB cluster is encrypted. The default is false if not specified.                                                                                                                                                                                                                                                                                                      | `bool`      | `true`                                            |    no    |
| <a name="input_vpc_security_group_ids"></a> [vpc_security_group_ids](#input_vpc_security_group_ids)                                        | (Optional) List of VPC security groups to associate with the Cluster                                                                                                                                                                                                                                                                                                                                  | `list(any)` | `[]`                                              |    no    |

## Outputs

| Name                                      | Description |
| ----------------------------------------- | ----------- |
| <a name="output_id"></a> [id](#output_id) | n/a         |

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
