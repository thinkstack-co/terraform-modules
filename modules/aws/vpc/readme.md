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

<h3 align="center">module_name</h3>
  <p align="center">
    module_description
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
### Description
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

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
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