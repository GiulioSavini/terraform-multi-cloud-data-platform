package main

import rego.v1

plan(resources) := {"resource_changes": resources}

log_group(days, env) := {
	"address": "module.observability.aws_cloudwatch_log_group.app",
	"type": "aws_cloudwatch_log_group",
	"change": {"actions": ["create"], "after": {
		"retention_in_days": days,
		"tags": {"Environment": env},
	}},
}

log_findings contains m if {
	some m in deny
	startswith(m, "LOG-01")
}

test_365_days_in_production_is_allowed if {
	count(log_findings) == 0 with input as plan([log_group(365, "prd")])
}

test_90_days_in_dev_is_allowed if {
	count(log_findings) == 0 with input as plan([log_group(90, "dev")])
}

test_30_days_is_below_the_floor if {
	count(log_findings) == 1 with input as plan([log_group(30, "dev")])
}

test_90_days_in_production_is_denied if {
	count(log_findings) == 1 with input as plan([log_group(90, "prd")])
}

test_never_expire_is_allowed if {
	count(log_findings) == 0 with input as plan([log_group(0, "prd")])
}

test_missing_retention_is_denied if {
	r := {
		"address": "module.observability.aws_cloudwatch_log_group.app",
		"type": "aws_cloudwatch_log_group",
		"change": {"actions": ["create"], "after": {"tags": {"Environment": "dev"}}},
	}
	count(log_findings) == 1 with input as plan([r])
}
