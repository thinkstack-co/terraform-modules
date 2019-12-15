# Terraform Modules
------------
https://www.thinkstack.co/

author: Zachary Hill

These terraform modules were created as part of a six month adoption of 'Infrastructure as Code' at Think|Stack. They serve as the basis to an iterative approach to managing infrastructure.

Design philosophy
------------------
When I began developing these modules, my initial design direction was to pre-package modules with everything necessary. So for example, a domain controller module would include things like:
- EC2 instance
- Security group
- Directory integration
