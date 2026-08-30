package main

import data.lib
import rego.v1

# TAG-01 -- Every resource carries owner, cost centre and data classification.
#
# Compliance evidence is gathered by querying tags. A resource missing these is
# invisible to an audit even when it is correctly configured, so this is a hard
# failure rather than a warning.

mandatory_keys := [
	"LandingZone",
	"Environment",
	"BoundedContext",
	"Owner",
	"CostCenter",
	"DataClassification",
	"ManagedBy",
]

# Resource types that genuinely cannot carry tags. Keeping this list explicit
# and short is deliberate: forgetting an entry produces a false positive a
# human notices, whereas a broad wildcard silently exempts real resources.
untaggable := {
	"aws_iam_role_policy",
	"aws_iam_role_policy_attachment",
	"aws_iam_instance_profile",
	"aws_vpc_security_group_ingress_rule",
	"aws_vpc_security_group_egress_rule",
	"aws_s3_bucket_lifecycle_configuration",
	"aws_s3_bucket_server_side_encryption_configuration",
	"aws_s3_bucket_public_access_block",
	"aws_s3_bucket_versioning",
	"aws_route_table_association",
	"aws_autoscaling_policy",
	"terraform_data",
	"random_password",
	"random_id",
	"random_string",
}

deny contains msg if {
	r := lib.changed[_]
	not untaggable[r.type]
	t := lib.tags(r)
	key := mandatory_keys[_]
	not t[key]
	msg := sprintf("TAG-01: %s is missing the mandatory tag %q. Derive tags from platform/tagging rather than writing them inline.", [r.address, key])
}

deny contains msg if {
	r := lib.changed[_]
	not untaggable[r.type]
	not lib.has_tags(r)
	msg := sprintf("TAG-01: %s carries no tags at all. Every resource must be attributable to an owner.", [r.address])
}
