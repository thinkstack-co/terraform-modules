# Usage
    module "sqs_queue_map" {
      source           = "github.com/thinkstack-co/terraform-modules//modules/aws/lambda_event_source_mapping"
      
      event_source_arn = module.lambda_function.arn
      function_name    = module.lambda_function.name

# Variables
## Required
    event_source_arn
    function_name

## Optional
    batch_size
    enabled
    starting_position
    starting_position_timestamp

# Outputs
    n/a
