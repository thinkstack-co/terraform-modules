#cloud-config

write_files:
  - content: ${license}
    path: /usr/local/trustgrid/license.txt
    permissions: "000644"
    owner: root:root
  - content: |
      [general]
      state_file = /var/awslogs/state/agent-state

      [/var/log/syslog]
      file = /var/log/syslog
      log_group_name = ${syslog_log_group_name}
      log_stream_name = ${syslog_log_stream_name}

      [/var/log/trustgrid/tg-default.log]
      file = /var/log/trustgrid/tg-default.log
      log_group_name = ${trustgrid_log_group_name}
      log_stream_name = ${trustgrid_log_stream_name}
      datetime_format = %b %d %H:%M:%S

    permissions: "000644"
    path: /etc/cloudwatch.cfg
    owner: root:root