locals {
  recover_action_unsupported_instances = [
    # Instance types that don't support CloudWatch recover actions
    "x2gd.xlarge", "x2gd.2xlarge", "x2gd.4xlarge", "x2gd.8xlarge", "x2gd.12xlarge", "x2gd.16xlarge", "x2gd.metal", "z1d.large", "z1d.xlarge", "z1d.2xlarge",
    "z1d.3xlarge", "z1d.6xlarge", "z1d.12xlarge", "z1d.metal", "r5d.2xlarge", "r5d.4xlarge", "r5d.8xlarge", "r5d.12xlarge", "r5d.16xlarge", "r5d.24xlarge",
    "r5d.metal", "r5dn.large", "r5dn.xlarge", "r5dn.2xlarge", "r5dn.4xlarge", "r5dn.8xlarge", "r5dn.12xlarge", "r5dn.16xlarge", "r5dn.24xlarge", "r5dn.metal",
    "r6gd.medium", "r6gd.large", "r6gd.xlarge", "r6gd.2xlarge", "r6gd.4xlarge", "r6gd.8xlarge", "r6gd.12xlarge", "r6gd.16xlarge", "r6gd.metal", "r6id.large",
    "r6id.xlarge", "r6id.2xlarge", "r6id.4xlarge", "r6id.8xlarge", "r6id.12xlarge", "r6id.16xlarge", "r6id.24xlarge", "r6id.32xlarge", "r6id.metal", "r6idn.large",
    "r6idn.xlarge", "r6idn.2xlarge", "r6idn.4xlarge", "r6idn.8xlarge", "r6idn.12xlarge", "r6idn.16xlarge", "r6idn.24xlarge", "r6idn.32xlarge", "r6idn.metal", "trn1.2xlarge",
    "trn1.32xlarge", "trn1n.32xlarge", "x2gd.medium", "x2gd.large", "m5dn.2xlarge", "m5dn.4xlarge", "m5dn.8xlarge", "m5dn.12xlarge", "m5dn.16xlarge", "m5dn.24xlarge",
    "m5dn.metal", "m6gd.medium", "m6gd.large", "m6gd.xlarge", "m6gd.2xlarge", "m6gd.4xlarge", "m6gd.8xlarge", "m6gd.12xlarge", "m6gd.16xlarge", "m6gd.metal",
    "m6id.large", "m6id.xlarge", "m6id.2xlarge", "m6id.4xlarge", "m6id.8xlarge", "m6id.12xlarge", "m6id.16xlarge", "m6id.24xlarge", "m6id.32xlarge", "m6id.metal",
    "m6idn.large", "m6idn.xlarge", "m6idn.2xlarge", "m6idn.4xlarge", "m6idn.8xlarge", "m6idn.12xlarge", "m6idn.16xlarge", "m6idn.24xlarge", "m6idn.32xlarge", "m6idn.metal",
    "mac1.metal", "mac2.metal", "p3dn.24xlarge", "p4d.24xlarge", "r5ad.large", "r5ad.xlarge", "r5ad.2xlarge", "r5ad.4xlarge", "r5ad.8xlarge", "r5ad.12xlarge",
    "r5ad.16xlarge", "r5ad.24xlarge", "r5d.large", "r5d.xlarge", "i3en.24xlarge", "i3en.metal", "i4g.large", "i4g.xlarge", "i4g.2xlarge", "i4g.4xlarge", "i4g.8xlarge",
    "i4g.16xlarge", "im4gn.large", "im4gn.xlarge", "im4gn.2xlarge", "im4gn.4xlarge", "im4gn.8xlarge", "im4gn.16xlarge", "inf2.xlarge", "inf2.8xlarge", "inf2.24xlarge",
    "inf2.48xlarge", "is4gen.medium", "is4gen.large", "is4gen.xlarge", "is4gen.2xlarge", "is4gen.4xlarge", "is4gen.8xlarge", "m1.small", "m1.medium", "m1.large", "m1.xlarge",
    "m2.xlarge", "m2.2xlarge", "m2.4xlarge", "m5ad.large", "m5ad.xlarge", "m5ad.2xlarge", "m5ad.4xlarge", "m5ad.8xlarge", "m5ad.12xlarge", "m5ad.16xlarge", "m5ad.24xlarge",
    "m5d.large", "m5d.xlarge", "m5d.2xlarge", "m5d.4xlarge", "m5d.8xlarge", "m5d.12xlarge", "m5d.16xlarge", "m5d.24xlarge", "m5d.metal", "m5dn.large", "m5dn.xlarge", "d3en.8xlarge",
    "d3en.12xlarge", "dl1.24xlarge", "f1.2xlarge", "f1.4xlarge", "f1.16xlarge", "g2.2xlarge", "g2.8xlarge", "g4ad.xlarge", "g4ad.2xlarge", "g4ad.4xlarge", "g4ad.8xlarge",
    "g4ad.16xlarge", "g4dn.xlarge", "g4dn.2xlarge", "g4dn.4xlarge", "g4dn.8xlarge", "g4dn.12xlarge", "g4dn.16xlarge", "g4dn.metal", "g5.xlarge", "g5.2xlarge", "g5.4xlarge",
    "g5.8xlarge", "g5.12xlarge", "g5.16xlarge", "g5.24xlarge", "g5.48xlarge", "g5g.metal", "h1.2xlarge", "h1.4xlarge", "h1.8xlarge", "h1.16xlarge", "i2.xlarge", "i2.2xlarge",
    "i2.4xlarge", "i2.8xlarge", "i3.large", "i3.xlarge", "i3.2xlarge", "i3.4xlarge", "i3.8xlarge", "i3.16xlarge", "i3.metal", "i3en.large", "i3en.xlarge", "i3en.2xlarge",
    "i3en.3xlarge", "i3en.6xlarge", "i3en.12xlarge", "c1.medium", "c1.xlarge", "c5ad.large", "c5ad.xlarge", "c5ad.2xlarge", "c5ad.4xlarge", "c5ad.8xlarge", "c5ad.12xlarge",
    "c5ad.16xlarge", "c5ad.24xlarge", "c5d.large", "c5d.xlarge", "c5d.2xlarge", "c5d.4xlarge", "c5d.9xlarge", "c5d.12xlarge", "c5d.18xlarge", "c5d.24xlarge", "c5d.metal", "c6gd.medium",
    "c6gd.large", "c6gd.xlarge", "c6gd.2xlarge", "c6gd.4xlarge", "c6gd.8xlarge", "c6gd.12xlarge", "c6gd.16xlarge", "c6gd.metal", "c6id.large", "c6id.xlarge",
    "c6id.2xlarge", "c6id.4xlarge", "c6id.8xlarge", "c6id.12xlarge", "c6id.16xlarge", "c6id.24xlarge", "c6id.32xlarge", "c6id.metal", "d2.xlarge", "d2.2xlarge", "d2.4xlarge",
    "d2.8xlarge", "d3.xlarge", "d3.2xlarge", "d3.4xlarge", "d3.8xlarge", "d3en.xlarge", "d3en.2xlarge", "d3en.4xlarge", "d3en.6xlarge"
  ]
}
