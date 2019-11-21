resource "aws_instance" "ec2" {
    ami                     = "${var.ami}"
    count                   = "${var.count}"
    ebs_optimized           = "${var.ebs_optimized}"
    subnet_id               = "${var.subnet_id}"
    instance_type           = "${var.instance_type}"
    key_name                = "${var.key_name}"
    user_data               = "${var.user_data}"
    private_ip              = "${var.private_ip}"
    vpc_security_group_ids  = ["${var.security_group_ids}"]
    volume_tags             = "${merge(var.tags, map("Name", format("%s%01d", var.instance_name_prefix, count.index + 1)))}"
    tags                    = "${merge(var.tags, map("Name", format("%s%01d", var.instance_name_prefix, count.index + 1)))}"
/*    root_block_device {
        volume_type = "${var.root_volume_type}"
        volume_size = "${var.root_volume_size}"
        }
    ebs_block_device {
        device_name = "${var.ebs_device_name}"
        volume_type = "${var.ebs_volume_type}"
        volume_size = "${var.ebs_volume_size}"
        }*/
    
    lifecycle {
        ignore_changes  = ["volume_tags"]
    }

}

###################################################
# CloudWatch Alarms
###################################################

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  actions_enabled           = true
  alarm_actions             = []
  alarm_description         = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name                = "${format("%s-instance-alarm", element(aws_instance.ec2.*.id, count.index))}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = "${var.count}"
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = "${element(aws_instance.ec2.*.id, count.index)}"
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
  #unit                      = "${var.unit}"
}

#####################
# Status Check Failed System Metric
#####################

resource "aws_cloudwatch_metric_alarm" "system" {
  actions_enabled           = true
  alarm_actions             = ["arn:aws:automate:${var.region}:ec2:recover"]
  alarm_description         = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name                = "${format("%s-system-alarm", element(aws_instance.ec2.*.id, count.index))}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = "${var.count}"
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = "${element(aws_instance.ec2.*.id, count.index)}"
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
  #unit                      = "${var.unit}"
}
