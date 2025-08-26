# Terraform Validate Report

**Status**: ❌ 15 of 105 directories failed validation
## Summary
### ❌ FAIL: `./examples/cloudformation_test/basic`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mModule not installed[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 21:
[31m│[0m [0m  21: [4mmodule "cloudformation_test"[0m {[0m
[31m│[0m [0m
[31m│[0m [0mThis module's local cache directory  could not be read. Run "terraform
[31m│[0m [0minit" to install all modules required by this configuration.
[31m╵[0m[0m
```

### ✅ PASS: `./global/iam/iam_groups`

### ✅ PASS: `./global/iam/iam_policies/ebs_backup`

### ✅ PASS: `./global/iam/iam_policies/mfa_self_serv`

### ✅ PASS: `./global/iam/iam_policies/s3_put_object`

### ✅ PASS: `./global/iam/iam_roles`

### ✅ PASS: `./global/iam/iam_users`

### ✅ PASS: `./modules/aws/acm_certificate`

### ✅ PASS: `./modules/aws/alb/alb_listener`

### ✅ PASS: `./modules/aws/alb/alb_listener_rule`

### ✅ PASS: `./modules/aws/alb/alb_load_balancer`

### ✅ PASS: `./modules/aws/alb/alb_ssl_cert`

### ✅ PASS: `./modules/aws/alb/alb_target_group`

### ✅ PASS: `./modules/aws/aws_cost_report`

### ✅ PASS: `./modules/aws/azure_ad_sso`

### ✅ PASS: `./modules/aws/cloudtrail`

### ❌ FAIL: `./modules/aws/cloudwatch/alarm`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mIncorrect attribute value type[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 13, in resource "aws_cloudwatch_metric_alarm" "alarm":
[31m│[0m [0m  13:   alarm_actions             = [4mvar.alarm_actions[0m[0m
[31m│[0m [0m    [90m├────────────────[0m
[31m│[0m [0m[0m    [90m│[0m [1mvar.alarm_actions[0m is a string
[31m│[0m [0m[0m
[31m│[0m [0mInappropriate value for attribute "alarm_actions": set of string required.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mIncorrect attribute value type[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 20, in resource "aws_cloudwatch_metric_alarm" "alarm":
[31m│[0m [0m  20:   insufficient_data_actions = [4mvar.insufficient_data_actions[0m[0m
[31m│[0m [0m    [90m├────────────────[0m
[31m│[0m [0m[0m    [90m│[0m [1mvar.insufficient_data_actions[0m is a string
[31m│[0m [0m[0m
[31m│[0m [0mInappropriate value for attribute "insufficient_data_actions": set of
[31m│[0m [0mstring required.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mIncorrect attribute value type[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 23, in resource "aws_cloudwatch_metric_alarm" "alarm":
[31m│[0m [0m  23:   ok_actions                = [4mvar.ok_actions[0m[0m
[31m│[0m [0m    [90m├────────────────[0m
[31m│[0m [0m[0m    [90m│[0m [1mvar.ok_actions[0m is a string
[31m│[0m [0m[0m
[31m│[0m [0mInappropriate value for attribute "ok_actions": set of string required.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/cloudwatch/event`

### ❌ FAIL: `./modules/aws/cloudwatch/log_destination`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 36, in resource "aws_iam_policy" "firehose_policy":
[31m│[0m [0m  36:         [4maws_s3_bucket.firehose_bucket[0m.arn,[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "firehose_bucket" has not been declared
[31m│[0m [0min the root module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 37, in resource "aws_iam_policy" "firehose_policy":
[31m│[0m [0m  37:         format("%s/*", [4maws_s3_bucket.firehose_bucket[0m.arn)[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "firehose_bucket" has not been declared
[31m│[0m [0min the root module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 69, in resource "aws_cloudwatch_log_destination" "this":
[31m│[0m [0m  69:   role_arn   = [4maws_iam_role.iam_for_cloudwatch[0m.arn[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_iam_role" "iam_for_cloudwatch" has not been
[31m│[0m [0mdeclared in the root module.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/config`

### ✅ PASS: `./modules/aws/dhcp_options_set`

### ❌ FAIL: `./modules/aws/direct_connect_connection`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mDuplicate resource "aws_dx_connection" configuration[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 1:
[31m│[0m [0m   1: [4mresource "aws_dx_connection" "dxc"[0m {[0m
[31m│[0m [0m
[31m│[0m [0mA aws_dx_connection resource named "dxc" was already declared at
[31m│[0m [0mmain.tf:15,1-35. Resource names must be unique per type in each module.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/directory_service_ad_connector`

### ✅ PASS: `./modules/aws/directory_service_microsoftad`

### ✅ PASS: `./modules/aws/directory_service_simple_ad`

### ✅ PASS: `./modules/aws/ebs_volume`

### ✅ PASS: `./modules/aws/ec2_domain_controller`

### ✅ PASS: `./modules/aws/ec2_instance`

### ✅ PASS: `./modules/aws/eip`

### ✅ PASS: `./modules/aws/elastic_beanstalk_application`

### ✅ PASS: `./modules/aws/elastic_beanstalk_environment`

### ✅ PASS: `./modules/aws/eni`

### ✅ PASS: `./modules/aws/flow_logs`

### ✅ PASS: `./modules/aws/fsx`

### ✅ PASS: `./modules/aws/iam_policy`

### ✅ PASS: `./modules/aws/iam_role`

### ✅ PASS: `./modules/aws/iam_role_policy_attachment`

### ✅ PASS: `./modules/aws/iam_saml_provider`

### ✅ PASS: `./modules/aws/iam_user`

### ✅ PASS: `./modules/aws/iam_user_policy_attachment`

### ✅ PASS: `./modules/aws/keypair`

### ✅ PASS: `./modules/aws/kinesis_firehose`

### ✅ PASS: `./modules/aws/kms`

### ✅ PASS: `./modules/aws/lambda`

### ✅ PASS: `./modules/aws/lambda_event_source_mapping`

### ✅ PASS: `./modules/aws/lambda_permission`

### ✅ PASS: `./modules/aws/launch_template`

### ✅ PASS: `./modules/aws/network_diagram_generator`

### ✅ PASS: `./modules/aws/nlb/nlb_listener`

### ❌ FAIL: `./modules/aws/nlb/nlb_listener_rule`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 21, in resource "aws_lb_listener_rule" "this":
[31m│[0m [0m  21:     [4mfield[0m  = var.condition_field[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "field" is not expected here.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 22, in resource "aws_lb_listener_rule" "this":
[31m│[0m [0m  22:     [4mvalues[0m = var.condition_values[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "values" is not expected here.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/nlb/nlb_load_balancer`

### ✅ PASS: `./modules/aws/nlb/nlb_target_group`

### ✅ PASS: `./modules/aws/organization`

### ✅ PASS: `./modules/aws/organizations_account`

### ❌ FAIL: `./modules/aws/rds/cluster`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 30, in resource "aws_kms_key" "rds":
[31m│[0m [0m  30:           "AWS" = "arn:aws:iam::${[4mdata.aws_caller_identity.current[0m.account_id}:root"[0m
[31m│[0m [0m
[31m│[0m [0mA data resource "aws_caller_identity" "current" has not been declared in
[31m│[0m [0mthe root module.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/rds/cluster_instance`

### ✅ PASS: `./modules/aws/rds/cluster_parameter_group`

### ✅ PASS: `./modules/aws/rds/db_parameter_group`

### ✅ PASS: `./modules/aws/rds/db_subnet_group`

### ✅ PASS: `./modules/aws/route`

### ✅ PASS: `./modules/aws/route_transit_gateway`

### ✅ PASS: `./modules/aws/route53/alias_record`

### ✅ PASS: `./modules/aws/route53/dnssec`

### ✅ PASS: `./modules/aws/route53/failover_routing_record`

### ✅ PASS: `./modules/aws/route53/geolocation_routing_record`

### ✅ PASS: `./modules/aws/route53/latency_routing_record`

### ✅ PASS: `./modules/aws/route53/simple_record`

### ✅ PASS: `./modules/aws/route53/weighted_routing_record`

### ✅ PASS: `./modules/aws/route53/zone`

### ✅ PASS: `./modules/aws/s3/bucket`

### ✅ PASS: `./modules/aws/s3/notification`

### ❌ FAIL: `./modules/aws/s3/s3_legacy`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 2, in output "s3_bucket_id":
[31m│[0m [0m   2:   value = [4maws_s3_bucket.this[0m.id[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "this" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 6, in output "s3_bucket_arn":
[31m│[0m [0m   6:   value = [4maws_s3_bucket.this[0m.arn[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "this" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 10, in output "s3_bucket_domain_name":
[31m│[0m [0m  10:   value = [4maws_s3_bucket.this[0m.bucket_domain_name[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "this" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 14, in output "s3_hosted_zone_id":
[31m│[0m [0m  14:   value = [4maws_s3_bucket.this[0m.hosted_zone_id[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "this" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 18, in output "s3_bucket_region":
[31m│[0m [0m  18:   value = [4maws_s3_bucket.this[0m.region[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "this" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 22, in output "website_endpoint":
[31m│[0m [0m  22:   value = [4maws_s3_bucket_website_configuration.this[0m.website_endpoint[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket_website_configuration" "this" has not
[31m│[0m [0mbeen declared in the root module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 26, in output "website_domain":
[31m│[0m [0m  26:   value = [4maws_s3_bucket_website_configuration.this[0m.website_domain[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket_website_configuration" "this" has not
[31m│[0m [0mbeen declared in the root module.
[31m╵[0m[0m
```

### ❌ FAIL: `./modules/aws/s3/s3_website`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 2, in output "s3_bucket_id":
[31m│[0m [0m   2:   value = [4maws_s3_bucket.s3_bucket[0m.id[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "s3_bucket" has not been declared in the
[31m│[0m [0mroot module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 6, in output "s3_bucket_arn":
[31m│[0m [0m   6:   value = [4maws_s3_bucket.s3_bucket[0m.arn[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "s3_bucket" has not been declared in the
[31m│[0m [0mroot module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 10, in output "s3_bucket_domain_name":
[31m│[0m [0m  10:   value = [4maws_s3_bucket.s3_bucket[0m.bucket_domain_name[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "s3_bucket" has not been declared in the
[31m│[0m [0mroot module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 14, in output "s3_hosted_zone_id":
[31m│[0m [0m  14:   value = [4maws_s3_bucket.s3_bucket[0m.hosted_zone_id[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "s3_bucket" has not been declared in the
[31m│[0m [0mroot module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on outputs.tf line 18, in output "s3_bucket_region":
[31m│[0m [0m  18:   value = [4maws_s3_bucket.s3_bucket[0m.region[0m
[31m│[0m [0m
[31m│[0m [0mA managed resource "aws_s3_bucket" "s3_bucket" has not been declared in the
[31m│[0m [0mroot module.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/s3/s3_with_transition`

### ❌ FAIL: `./modules/aws/sqs_queue`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 30, in resource "aws_kms_key" "sqs":
[31m│[0m [0m  30:           "AWS" = "arn:aws:iam::${[4mdata.aws_caller_identity.current[0m.account_id}:root"[0m
[31m│[0m [0m
[31m│[0m [0mA data resource "aws_caller_identity" "current" has not been declared in
[31m│[0m [0mthe root module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 52, in resource "aws_kms_key" "sqs":
[31m│[0m [0m  52:               "arn:aws:sqs:*:${[4mdata.aws_caller_identity.current[0m.account_id}:queue/*"[0m
[31m│[0m [0m
[31m│[0m [0mA data resource "aws_caller_identity" "current" has not been declared in
[31m│[0m [0mthe root module.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 56, in resource "aws_kms_key" "sqs":
[31m│[0m [0m  56:             "aws:SourceArn" = "arn:aws:sqs:${[4mdata.aws_region.current[0m.name}:${data.aws_caller_identity.current.account_id}:queue/${var.name}"[0m
[31m│[0m [0m
[31m│[0m [0mA data resource "aws_region" "current" has not been declared in the root
[31m│[0m [0mmodule.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mReference to undeclared resource[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 56, in resource "aws_kms_key" "sqs":
[31m│[0m [0m  56:             "aws:SourceArn" = "arn:aws:sqs:${data.aws_region.current.name}:${[4mdata.aws_caller_identity.current[0m.account_id}:queue/${var.name}"[0m
[31m│[0m [0m
[31m│[0m [0mA data resource "aws_caller_identity" "current" has not been declared in
[31m│[0m [0mthe root module.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/ssm_role`

### ✅ PASS: `./modules/aws/transit_gateway`

### ✅ PASS: `./modules/aws/transit_gateway_attachment`

### ✅ PASS: `./modules/aws/transit_gateway_connect`

### ✅ PASS: `./modules/aws/transit_gateway_connect_peer`

### ✅ PASS: `./modules/aws/transit_gateway_route`

### ❌ FAIL: `./modules/aws/vendor/cato_sdwan`

```
[33m╷[0m[0m
[33m│[0m [0m[1m[33mWarning: [0m[0m[1mDeprecated attribute[0m
[33m│[0m [0m
[33m│[0m [0m[0m  on main.tf line 203, in resource "aws_cloudwatch_metric_alarm" "system":
[33m│[0m [0m 203:   alarm_actions       = ["arn:aws:automate:${data.aws_region.current[4m.name[0m}:ec2:recover"][0m
[33m│[0m [0m
[33m│[0m [0mThe attribute "name" is deprecated. Refer to the provider documentation for
[33m│[0m [0mdetails.
[33m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mUnsupported argument[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on main.tf line 81, in resource "aws_eip" "wan_external_ip":
[31m│[0m [0m  81:   [4mvpc[0m   = true[0m
[31m│[0m [0m
[31m│[0m [0mAn argument named "vpc" is not expected here.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/vendor/corelight`

### ✅ PASS: `./modules/aws/vendor/fortigate_firewall`

### ❌ FAIL: `./modules/aws/vendor/silverpeak`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable name[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 12, in variable "count":
[31m│[0m [0m  12: variable [4m"count"[0m {[0m
[31m│[0m [0m
[31m│[0m [0mThe variable name "count" is reserved due to its special meaning inside
[31m│[0m [0mmodule blocks.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/aws/vpc`

### ✅ PASS: `./modules/aws/vpc_peering_connection`

### ✅ PASS: `./modules/aws/vpc_peering_connection_accepter`

### ✅ PASS: `./modules/aws/vpn`

### ✅ PASS: `./modules/aws/vpn_route`

### ✅ PASS: `./modules/azuread/conditional_access/named_location`

### ❌ FAIL: `./modules/azuread/conditional_access/policy`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 10, in variable "state":
[31m│[0m [0m  10:     condition     = [4mcontains(["enabled", "disabled", "enabledForReportingButNotEnforced"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 10, in variable "state":
[31m│[0m [0m  10:     condition     = [4mcontains(["enabled", "disabled", "enabledForReportingButNotEnforced"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "state" must refer to var.state in order to test
[31m│[0m [0mincoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 23, in variable "client_app_types":
[31m│[0m [0m  23:     condition     = [4mcontains(["all", "browser", "mobileAppsAndDesktopClients", "exchangeActiveSync", "easSupported", "other"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 23, in variable "client_app_types":
[31m│[0m [0m  23:     condition     = [4mcontains(["all", "browser", "mobileAppsAndDesktopClients", "exchangeActiveSync", "easSupported", "other"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "client_app_types" must refer to
[31m│[0m [0mvar.client_app_types in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 33, in variable "sign_in_risk_levels":
[31m│[0m [0m  33:     condition     = [4mcontains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 33, in variable "sign_in_risk_levels":
[31m│[0m [0m  33:     condition     = [4mcontains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "sign_in_risk_levels" must refer to
[31m│[0m [0mvar.sign_in_risk_levels in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 42, in variable "user_risk_levels":
[31m│[0m [0m  42:     condition     = [4mcontains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 42, in variable "user_risk_levels":
[31m│[0m [0m  42:     condition     = [4mcontains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "user_risk_levels" must refer to
[31m│[0m [0mvar.user_risk_levels in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 78, in variable "device_filter_mode":
[31m│[0m [0m  78:     condition     = [4mcontains(["include", "exclude"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 78, in variable "device_filter_mode":
[31m│[0m [0m  78:     condition     = [4mcontains(["include", "exclude"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "device_filter_mode" must refer to
[31m│[0m [0mvar.device_filter_mode in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 113, in variable "excluded_platforms":
[31m│[0m [0m 113:     condition     = [4mcontains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 113, in variable "excluded_platforms":
[31m│[0m [0m 113:     condition     = [4mcontains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "excluded_platforms" must refer to
[31m│[0m [0mvar.excluded_platforms in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 122, in variable "included_platforms":
[31m│[0m [0m 122:     condition     = [4mcontains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 122, in variable "included_platforms":
[31m│[0m [0m 122:     condition     = [4mcontains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "included_platforms" must refer to
[31m│[0m [0mvar.included_platforms in order to test incoming values.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid validation expression[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 176, in variable "built_in_controls":
[31m│[0m [0m 176:     condition     = [4mcontains(["block", "mfa", "approvedApplication", "compliantApplication", "compliantDevice", "domainJoinedDevice", "passwordChange", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition expression must refer to at least one object from elsewhere
[31m│[0m [0min the configuration, or else its result would not be checking anything.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mInvalid variable validation condition[0m
[31m│[0m [0m
[31m│[0m [0m[0m  on variables.tf line 176, in variable "built_in_controls":
[31m│[0m [0m 176:     condition     = [4mcontains(["block", "mfa", "approvedApplication", "compliantApplication", "compliantDevice", "domainJoinedDevice", "passwordChange", "unknownFutureValue"])[0m[0m
[31m│[0m [0m
[31m│[0m [0mThe condition for variable "built_in_controls" must refer to
[31m│[0m [0mvar.built_in_controls in order to test incoming values.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/cloudflare/record`

### ✅ PASS: `./modules/cloudflare/zone`

### ✅ PASS: `./modules/module_template`

### ✅ PASS: `./modules/terraform/oauth_client`

### ✅ PASS: `./modules/terraform/team`

### ✅ PASS: `./modules/terraform/team_access`

### ✅ PASS: `./modules/terraform/workspace`

### ❌ FAIL: `./modules/thinkstack/aws_backup`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_selection.all_resources its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_selection.all_resources, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_alias.alias its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_kms_alias.alias, after which you can remove the provider configuration
[31m│[0m [0magain.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_policy.vault_prod_monthly its original
[31m│[0m [0mprovider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_policy.vault_prod_monthly, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.vault_prod_hourly its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault.vault_prod_hourly, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_key.key its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy aws_kms_key.key,
[31m│[0m [0mafter which you can remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.vault_prod_hourly its
[31m│[0m [0moriginal provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.vault_prod_hourly, after which you can
[31m│[0m [0mremove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.vault_disaster_recovery
[31m│[0m [0mits original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_dr_region is required,
[31m│[0m [0mbut it has been removed. This occurs when a provider configuration is
[31m│[0m [0mremoved while objects created by that provider still exist in the state.
[31m│[0m [0mRe-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.vault_disaster_recovery, after which
[31m│[0m [0myou can remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_iam_role_policy_attachment.backup its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_iam_role_policy_attachment.backup, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.vault_prod_monthly its
[31m│[0m [0moriginal provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.vault_prod_monthly, after which you can
[31m│[0m [0mremove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.vault_prod_daily its
[31m│[0m [0moriginal provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.vault_prod_daily, after which you can
[31m│[0m [0mremove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_policy.vault_disaster_recovery its original
[31m│[0m [0mprovider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_dr_region is required,
[31m│[0m [0mbut it has been removed. This occurs when a provider configuration is
[31m│[0m [0mremoved while objects created by that provider still exist in the state.
[31m│[0m [0mRe-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_policy.vault_disaster_recovery, after which you can remove
[31m│[0m [0mthe provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_plan.ec2_plan its original provider configuration
[31m│[0m [0mat provider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_plan.ec2_plan, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.vault_prod_monthly its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault.vault_prod_monthly, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_policy.vault_prod_hourly its original
[31m│[0m [0mprovider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_policy.vault_prod_hourly, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_policy.vault_prod_daily its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_policy.vault_prod_daily, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_selection.all_ec2 its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_selection.all_ec2, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_iam_role_policy_attachment.restores its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_iam_role_policy_attachment.restores, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.vault_disaster_recovery its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_dr_region is required,
[31m│[0m [0mbut it has been removed. This occurs when a provider configuration is
[31m│[0m [0mremoved while objects created by that provider still exist in the state.
[31m│[0m [0mRe-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault.vault_disaster_recovery, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_plan.plan its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_plan.plan, after which you can remove the provider configuration
[31m│[0m [0magain.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_key.dr_key its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_dr_region is required,
[31m│[0m [0mbut it has been removed. This occurs when a provider configuration is
[31m│[0m [0mremoved while objects created by that provider still exist in the state.
[31m│[0m [0mRe-add the provider configuration to destroy aws_kms_key.dr_key, after
[31m│[0m [0mwhich you can remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_iam_role.backup its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_iam_role.backup, after which you can remove the provider configuration
[31m│[0m [0magain.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.vault_prod_daily its original provider
[31m│[0m [0mconfiguration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_prod_region is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault.vault_prod_daily, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_alias.dr_alias its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].aws_dr_region is required,
[31m│[0m [0mbut it has been removed. This occurs when a provider configuration is
[31m│[0m [0mremoved while objects created by that provider still exist in the state.
[31m│[0m [0mRe-add the provider configuration to destroy aws_kms_alias.dr_alias, after
[31m│[0m [0mwhich you can remove the provider configuration again.
[31m╵[0m[0m
```

### ❌ FAIL: `./modules/thinkstack/aws_backup_custom`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.dr its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].dr is required, but it has
[31m│[0m [0mbeen removed. This occurs when a provider configuration is removed while
[31m│[0m [0mobjects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_backup_vault.dr, after which you can
[31m│[0m [0mremove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_key.dr_backup_key its original provider configuration
[31m│[0m [0mat provider["registry.terraform.io/hashicorp/aws"].dr is required, but it
[31m│[0m [0mhas been removed. This occurs when a provider configuration is removed
[31m│[0m [0mwhile objects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_kms_key.dr_backup_key, after which
[31m│[0m [0myou can remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_alias.dr_backup_alias its original provider
[31m│[0m [0mconfiguration at provider["registry.terraform.io/hashicorp/aws"].dr is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_kms_alias.dr_backup_alias, after which you can remove the provider
[31m│[0m [0mconfiguration again.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/thinkstack/aws_backup_custom/modules/aws_backup_iam_role`

### ✅ PASS: `./modules/thinkstack/aws_backup_custom/modules/aws_backup_plans`

### ❌ FAIL: `./modules/thinkstack/aws_backup_custom/modules/aws_backup_vault`

```
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_alias.dr_backup its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].dr is required, but it has
[31m│[0m [0mbeen removed. This occurs when a provider configuration is removed while
[31m│[0m [0mobjects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_kms_alias.dr_backup, after which you
[31m│[0m [0mcan remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.dr its original provider
[31m│[0m [0mconfiguration at provider["registry.terraform.io/hashicorp/aws"].dr is
[31m│[0m [0mrequired, but it has been removed. This occurs when a provider
[31m│[0m [0mconfiguration is removed while objects created by that provider still exist
[31m│[0m [0min the state. Re-add the provider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.dr, after which you can remove the
[31m│[0m [0mprovider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault_lock_configuration.dr_single its original
[31m│[0m [0mprovider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].dr is required, but it has
[31m│[0m [0mbeen removed. This occurs when a provider configuration is removed while
[31m│[0m [0mobjects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy
[31m│[0m [0maws_backup_vault_lock_configuration.dr_single, after which you can remove
[31m│[0m [0mthe provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.dr its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].dr is required, but it has
[31m│[0m [0mbeen removed. This occurs when a provider configuration is removed while
[31m│[0m [0mobjects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_backup_vault.dr, after which you can
[31m│[0m [0mremove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_kms_key.dr_backup its original provider configuration at
[31m│[0m [0mprovider["registry.terraform.io/hashicorp/aws"].dr is required, but it has
[31m│[0m [0mbeen removed. This occurs when a provider configuration is removed while
[31m│[0m [0mobjects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_kms_key.dr_backup, after which you
[31m│[0m [0mcan remove the provider configuration again.
[31m╵[0m[0m
[31m╷[0m[0m
[31m│[0m [0m[1m[31mError: [0m[0m[1mProvider configuration not present[0m
[31m│[0m [0m
[31m│[0m [0m[0mTo work with aws_backup_vault.dr_single its original provider configuration
[31m│[0m [0mat provider["registry.terraform.io/hashicorp/aws"].dr is required, but it
[31m│[0m [0mhas been removed. This occurs when a provider configuration is removed
[31m│[0m [0mwhile objects created by that provider still exist in the state. Re-add the
[31m│[0m [0mprovider configuration to destroy aws_backup_vault.dr_single, after which
[31m│[0m [0myou can remove the provider configuration again.
[31m╵[0m[0m
```

### ✅ PASS: `./modules/thinkstack/siem`
