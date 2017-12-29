CloudTrail Module
=================

This module sets up and enables CloudTrail for all regions. The module handles setting up a new S3 bucket, in the region of your choice, to which all CloudTrail logs are sent. The S3 bucket enabled versioning by default.

It is highly recommended that mfa_delete be enabled after the initial build has completed.

Variables

Outputs

