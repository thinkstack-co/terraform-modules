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
| name | The name of the connection | `string` | `tf-dx-connection` | yes |
| bandwidth | The connection bandwidth.Valid values for dedicated: 1Gbps,10Gbps. Hosted: 50Mbps,100Mbps,200Mbps,300Mbps,400Mbps,500Mbps,1Gbps,2Gbps,5Gbps and 10Gbps. Case sensitive. | `string` | `"xvdf"` | yes |
| location | The AWS Direct Connect location where the connection is located.  | `string` | `EqDC2` | yes |
| instance\_id | ID of the instance to attach to | `string` | n/a | yes |
| tags | A map of tags to assign to the resource. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the connection. |
| arn | The ARN of the connection. |
| jumbo_frame_capable | Boolean value representing if jumbo frames have been enabled for this connection. |
| has_logical_redundancy | Indicates whether the connection supports a secondary BGP peer in the same address family (IPv4/IPv6). |
| aws_device | The Direct Connect endpoint on which the physical connection terminates. |