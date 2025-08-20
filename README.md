<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
# terraform-modules
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

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

[![Logo](images/terraform_modules_logo.webp)](https://github.com/thinkstack-co/terraform-modules)

## Project Overview

Terraform modules to deploy and manage cloud resources using the latest well architected frameworks

[**Explore the docs »**](https://github.com/thinkstack-co/terraform-modules)

[Think|Stack](https://www.thinkstack.co/) · [Report Bug](https://github.com/thinkstack-co/terraform-modules/issues) · [Request Feature](https://github.com/thinkstack-co/terraform-modules/issues)

## Table of Contents

- [About The Project](#about-the-project)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://github.com/thinkstack-co/terraform-modules)

These terraform modules were originally created as part of a six month adoption of 'Infrastructure as Code' at Think|Stack. They serve as the basis to an iterative approach to managing infrastructure. They've grown and expanded to be the workhorse of our organization that we wish to share and collaborate with the world. We are ever evolving and this code will continues to evolve as features, needs, and best practices do.

[back to top](#terraform-modules)

### Built With

- [![Terraform][Terraform.io]][Terraform-url]

[back to top](#terraform-modules)

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running, simply clone this repo.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.

- MacOS

  ```sh
  brew install terraform
  ```

- Debian/Ubuntu

  ```sh
  apt install terraform
  ```

- Windows

  ```sh
  choco install -y terraform
  ```

### Installation

1. Clone the repo

   ```sh
   git clone https://github.com/thinkstack-co/terraform-modules.git
   ```

[back to top](#terraform-modules)

<!-- USAGE EXAMPLES -->
## Usage

Navigate to the folder for the provider and subsequent module, service, or infrastructure you're looking to utilize. Within each module a README.md has documented the usage instructions and examples for that module. Included in each README.md is also an output of automated `terraform-docs` which has requirements, inputs, and outputs.

### Examples

- [CloudTrail](https://github.com/thinkstack-co/terraform-modules/tree/main/modules/aws/cloudtrail)
- [EC2](https://github.com/thinkstack-co/terraform-modules/tree/main/modules/aws/ec2_instance)
- [VPC](https://github.com/thinkstack-co/terraform-modules/tree/main/modules/aws/vpc)

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

[back to top](#terraform-modules)

### Local linting and validation

Run local checks to find deprecated Terraform syntax and validation issues.

1. Install tools (macOS):

   ```sh
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform tflint shellcheck
   # Python Black (choose one)
   brew install black
   # or: pipx install black
   ```

2. Generate reports:

   ```sh
   bash lint-local.sh all
   ```

   - TFLint runs with plugin init on first run (network required)
   - Terraform validate runs with `-backend=false` to avoid touching remote state

3. View results in `reports/`:
   - `reports/terraform-tflint-report.md`
   - `reports/terraform-tflint-deprecations.md`
   - `reports/terraform-validate-report.md`
   - `reports/bash-shellcheck-report.md`
   - `reports/python-black-report.md`

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/thinkstack-co/terraform-modules/issues) for a full list of proposed features (and known issues).

[back to top](#terraform-modules)

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thank you!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

[back to top](#terraform-modules)

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

[back to top](#terraform-modules)

<!-- CONTACT -->
## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - info@thinkstack.co

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

[back to top](#terraform-modules)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

[back to top](#terraform-modules)

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