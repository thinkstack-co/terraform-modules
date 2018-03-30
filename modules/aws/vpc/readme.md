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
