module "flow_logs" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/flow_logs"
    
    flow_vpc_id = "vpc-42718oh421"
}