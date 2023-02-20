output "trustgrid-instance-profile-name" {
    value = aws_iam_instance_profile.trustgrid-instance-profile.name
}

output "trustgrid-log-group" {
    value = aws_cloudwatch_log_group.trustrid-log-group.name
}

output "syslog-log-group" {
    value = aws_cloudwatch_log_group.syslog-log-group.name
}