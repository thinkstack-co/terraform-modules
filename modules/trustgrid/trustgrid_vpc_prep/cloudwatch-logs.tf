resource "aws_cloudwatch_log_group" "trustrid-log-group" {
  name = "${var.environment_name}-/var/log/trustgrid"
}

resource "aws_cloudwatch_log_group" "syslog-log-group" {
  name = "${var.environment_name}-/var/log/syslog"
}