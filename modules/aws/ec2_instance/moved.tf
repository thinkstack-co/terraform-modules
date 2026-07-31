###########################
# State migration (moved blocks)
###########################
# v2.8.2 dropped count from aws_instance.ec2. This renames the old count-indexed
# state ([0]) to the un-indexed address in place, so a consumer bumping straight
# from <=v2.4.2 to v3 migrates with zero destroy. No-op when [0] isn't in state,
# so consumers already on >=v2.8.2 are unaffected.
#
# Callers using the removed `number` variable with a value >1 have additional
# instances at [1]+ that v3 cannot represent; var.number rejects those at plan
# time rather than destroying them. See variables.tf.

moved {
  from = aws_instance.ec2[0]
  to   = aws_instance.ec2
}
