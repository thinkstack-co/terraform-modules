module "hourly_trigger" {
  source              = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch?ref=v0.4.5"
  description         = "Event which triggers at 20 past the hour, every hour"
  event_target_arn    = module.lambda_function.arn
  name                = "hourly-trigger"
  schedule_expression = "cron(20 0/1 * * ? *)"
}
