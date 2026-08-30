package main

import data.lib
import rego.v1

# IAM-03 / NET-03 -- data at rest is encrypted and buckets are never public.

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_s3_bucket"
	not sse_configured_for(r.address)
	msg := sprintf("IAM-03: %s has no aws_s3_bucket_server_side_encryption_configuration in this plan. Unencrypted object storage fails CIS 2.1.1 and ISO 27001 A.8.24.", [r.address])
}

# The SSE resource shares the bucket's logical name, which is the only link
# available in plan JSON -- `bucket` is often an unresolved reference at plan
# time, so matching on it would produce false positives.
sse_configured_for(bucket_address) if {
	r := lib.changed[_]
	r.type == "aws_s3_bucket_server_side_encryption_configuration"
	logical_name(r.address) == logical_name(bucket_address)
}

logical_name(address) := name if {
	parts := split(address, ".")
	name := parts[count(parts) - 1]
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_s3_bucket_public_access_block"
	a := lib.after(r)
	some setting in ["block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"]
	a[setting] == false
	msg := sprintf("IAM-03: %s sets %s to false. All four public access block settings must remain true.", [r.address, setting])
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "azurerm_storage_account"
	a := lib.after(r)
	a.enable_https_traffic_only == false
	msg := sprintf("NET-03: %s permits plaintext HTTP. Storage accounts must enforce HTTPS (ISO 27001 A.8.24, SOC 2 CC6.7).", [r.address])
}
