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

<h3 align="center">RDS Cluster Instance</h3>
  <p align="center">
    This module creates a RDS Cluster Instance to be used with RDS Cluster
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
module "webapp_prod_db_instances" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/rds/cluster_instance"

  cluster_identifier           = module.webapp_prod_db_cluster.id[0]
  db_subnet_group_name         = module.webapp_db_subnet_group.id
  db_parameter_group_name      = module.webapp_aurora_db_parameter_group.id[0]
  engine                       = "aurora"
  identifier                   = "webapp-wordpress"
  instance_class               = "db.t3.medium"
  number                       = 2
  performance_insights_enabled = true

  tags = {
    terraform   = "yes"
    created_by  = "Zachary Hill"
    environment = "prod"
    project     = "website_migration"
  }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_rds_cluster_instance.cluster_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default isfalse. | `string` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | (Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true. | `string` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional, Computed) The EC2 Availability Zone that the DB instance is created in. See docs about the details. | `string` | `""` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | (Required) The identifier of the aws\_rds\_cluster in which to launch this instance. | `string` | n/a | yes |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | (Optional) The name of the DB parameter group to associate with this instance. | `string` | n/a | yes |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | (Required if publicly\_accessible = false, Optional otherwise) A DB subnet group to associate with this DB instance. NOTE: This must match the db\_subnet\_group\_name of the attached aws\_rds\_cluster. | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional) The name of the database engine to be used for the RDS instance. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide. | `string` | `""` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The database engine version. | `string` | `""` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Optional, Forces new resource) The indentifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier. | `string` | `""` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Required) The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora currently supports the below instance classes. Please see AWS Documentation for complete details. db.t2.small db.t2.medium db.r3.large db.r3.xlarge db.r3.2xlarge db.r3.4xlarge db.r3.8xlarge db.r4.large db.r4.xlarge db.r4.2xlarge db.r4.4xlarge db.r4.8xlarge db.r4.16xlarge | `string` | n/a | yes |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | (Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `string` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | (Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the AWS Documentation what IAM permissions are needed to allow Enhanced Monitoring for RDS Instances. | `string` | `""` | no |
| <a name="input_number"></a> [number](#input\_number) | The number of resources to create | `string` | n/a | yes |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | (Optional) Specifies whether Performance Insights is enabled or not. | `string` | `true` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | (Optional) The ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `""` | no |
| <a name="input_promotion_tier"></a> [promotion\_tier](#input\_promotion\_tier) | (Optional) Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer. | `string` | `0` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | (Optional) Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property. | `string` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the instance. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
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

* [Zachary Hill](https://zacharyhill.co)
* [Jake Jones](https://github.com/jakeasarus)

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