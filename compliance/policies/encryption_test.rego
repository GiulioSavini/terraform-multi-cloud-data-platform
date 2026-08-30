package main

import rego.v1

plan(resources) := {"resource_changes": resources}

enc_findings contains m if {
	some m in deny
	regex.match("^(IAM-03|NET-03)", m)
}

bucket := {
	"address": "module.observability.aws_s3_bucket.log_archive",
	"type": "aws_s3_bucket",
	"change": {"actions": ["create"], "after": {"tags_all": {}}},
}

sse := {
	"address": "module.observability.aws_s3_bucket_server_side_encryption_configuration.log_archive",
	"type": "aws_s3_bucket_server_side_encryption_configuration",
	"change": {"actions": ["create"], "after": {}},
}

test_encrypted_bucket_is_allowed if {
	count(enc_findings) == 0 with input as plan([bucket, sse])
}

test_bucket_without_sse_is_denied if {
	count(enc_findings) == 1 with input as plan([bucket])
}

test_public_access_block_disabled_is_denied if {
	r := {
		"address": "module.observability.aws_s3_bucket_public_access_block.log_archive",
		"type": "aws_s3_bucket_public_access_block",
		"change": {"actions": ["create"], "after": {
			"block_public_acls": true,
			"block_public_policy": false,
			"ignore_public_acls": true,
			"restrict_public_buckets": true,
		}},
	}
	count(enc_findings) == 1 with input as plan([r])
}

test_storage_account_without_https_is_denied if {
	r := {
		"address": "module.access_control.azurerm_storage_account.security",
		"type": "azurerm_storage_account",
		"change": {"actions": ["create"], "after": {
			"enable_https_traffic_only": false,
			"tags": {},
		}},
	}
	count(enc_findings) == 1 with input as plan([r])
}
