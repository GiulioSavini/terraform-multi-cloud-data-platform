package main

import rego.v1

full_tags := {
	"LandingZone": "hybrid",
	"Environment": "prd",
	"BoundedContext": "networking",
	"Owner": "platform-team",
	"CostCenter": "CC-1000",
	"DataClassification": "internal",
	"ManagedBy": "terraform",
}

plan(resources) := {"resource_changes": resources}

# Every policy in this package contributes to `deny`, so a test that counted the
# whole set would also pick up findings from network.rego. Scope to TAG-01.
tag_findings contains m if {
	some m in deny
	startswith(m, "TAG-01")
}

test_tagged_resource_is_allowed if {
	r := {
		"address": "module.aws.aws_vpc.main",
		"type": "aws_vpc",
		"change": {"actions": ["create"], "after": {"tags_all": full_tags}},
	}
	count(tag_findings) == 0 with input as plan([r])
}

test_missing_owner_is_denied if {
	r := {
		"address": "module.aws.aws_vpc.main",
		"type": "aws_vpc",
		"change": {"actions": ["create"], "after": {"tags_all": object.remove(full_tags, {"Owner"})}},
	}
	count(tag_findings) == 1 with input as plan([r])
}

test_untagged_resource_is_denied if {
	r := {
		"address": "module.aws.aws_vpc.main",
		"type": "aws_vpc",
		"change": {"actions": ["create"], "after": {"cidr_block": "10.0.0.0/16"}},
	}
	count(tag_findings) > 0 with input as plan([r])
}

test_untaggable_type_is_exempt if {
	r := {
		"address": "module.aws.aws_iam_role_policy.ec2",
		"type": "aws_iam_role_policy",
		"change": {"actions": ["create"], "after": {}},
	}
	count(tag_findings) == 0 with input as plan([r])
}

test_destroy_is_not_evaluated if {
	r := {
		"address": "module.aws.aws_vpc.main",
		"type": "aws_vpc",
		"change": {"actions": ["delete"], "after": null},
	}
	count(tag_findings) == 0 with input as plan([r])
}

test_gcp_labels_satisfy_the_rule if {
	r := {
		"address": "module.gcp.google_compute_network.main",
		"type": "google_compute_network",
		"change": {"actions": ["create"], "after": {"labels": full_tags}},
	}
	count(tag_findings) == 0 with input as plan([r])
}
