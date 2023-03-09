## Usage

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

<h3 align="center">Route53 Simple Record Module</h3>
  <p align="center">
    This modules creates a simple dns record in a Route53 zone.
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
### Example TXT record
```
module "domain_txt" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

    zone_id = module.example_com_zone.zone_id
    name    = "example.com"
    type    = "TXT"
    ttl     = 300
    records = [
        "v=spf1 include:_spf.google.com ~all",
        "google-site-verification=h-218181818181818181818181818fdsa",
        "v=DKIM1; k=rsa; p=fdjkslafjlkdsajoifjiofjdlskafjlkdsajklfdsoiafdsafdsafdsa/stf0Ga4z2XaZG7detZ+beakt9hF5I7hBarjspZuIwVNb+VnDJ2t21wlxnswHt5huiAxg52g+99x890fd09sa0fdsafdsa8f09dsa809fd80s9a/fdsafdsafdsafdsafdsafdsafdsa\"\"EtbJup2cDxlYAH8/HiLq+bhLIKnzwhsiu16k91DDJYAXjmOm2o3MRD9AVtVWIyRb59Qhi9FOlySNOezxxM+WPCXTzPqPs78jshMcMLZbLTrNFWkNcdrLCD79RdUN+DdXDBj4cemdjxs4Ul4J5IkwwIDAQAB",
        "v=DKIM1; k=rsa; p=dfsa098fd809saf809dsa809fdhjsafhfdjsiafidosa/GASDFJUKALJKffdsa0+xEObmrCjxcG2VtNHiwZ+6sD0PGC2ldjAPIVaYtKJmoJaO+Dt/fds89a0f809dsa809fd809saf890dsa908fdsa/eJCh\"\"lZQzIOmNzp0CRJDSPy9+jOYqMpVyeThzWnIALam0Z6M8nJ/ue6ezygRBR70AbG/fd90sa890fds809af809dsa809f8d90safdsa/AC0nU5QmoKvd40qzMm0CA0ycXt5hb5iDR+T1Kx8ps9KPXQIDAQAB",
    ]
}
```

### Example A record
```
module "test" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

    zone_id = module.example_com_zone.zone_id
    name    = "test.example.com"
    type    = "A"
    ttl     = 300
    records = [
        "1.1.1.1"
    ]
}
```

### Example CNAME record
```
module "mail" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

    zone_id = module.example_com_zone.zone_id
    name    = "mail.example.com"
    type    = "CNAME"
    ttl     = 300
    records = [
        "ghs.googlehosted.com."
    ]
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
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_health_check_id"></a> [health\_check\_id](#input\_health\_check\_id) | (Optional) The health check the record should be associated with. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the record. | `string` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | (Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add "" inside the Terraform configuration string. | `list(string)` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional, Required for non-alias records) The TTL of the record in seconds. | `number` | `300` | no |
| <a name="input_type"></a> [type](#input\_type) | (Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | (Required) The ID of the hosted zone to contain this record. | `string` | n/a | yes |

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