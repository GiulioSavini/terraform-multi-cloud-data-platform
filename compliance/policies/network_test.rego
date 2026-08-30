package main

import rego.v1

plan(resources) := {"resource_changes": resources}

vpc_with_flow_log := [
	{
		"address": "module.aws.aws_vpc.main",
		"type": "aws_vpc",
		"change": {"actions": ["create"], "after": {"tags_all": {}}},
	},
	{
		"address": "module.aws.aws_flow_log.main",
		"type": "aws_flow_log",
		"change": {"actions": ["create"], "after": {"tags_all": {}}},
	},
]

ingress(address, cidr, description) := {
	"address": address,
	"type": "aws_vpc_security_group_ingress_rule",
	"change": {"actions": ["create"], "after": {"cidr_ipv4": cidr, "description": description}},
}

test_public_ingress_on_alb_with_clear_description_is_allowed if {
	r := ingress("module.access_control.aws_vpc_security_group_ingress_rule.alb_https", "0.0.0.0/0", "HTTPS from internet")
	count({m | some m in deny; startswith(m, "IAM-02")}) == 0 with input as plan([r])
}

test_public_ingress_without_description_is_denied if {
	r := ingress("module.access_control.aws_vpc_security_group_ingress_rule.alb_https", "0.0.0.0/0", "allow all")
	count({m | some m in deny; startswith(m, "IAM-02")}) == 1 with input as plan([r])
}

test_public_ingress_to_instance_tier_is_always_denied if {
	r := ingress("module.access_control.aws_vpc_security_group_ingress_rule.instance_ssh", "0.0.0.0/0", "SSH from internet")
	count({m | some m in deny; startswith(m, "IAM-02")}) == 1 with input as plan([r])
}

test_scoped_ingress_is_allowed if {
	r := ingress("module.access_control.aws_vpc_security_group_ingress_rule.office", "203.0.113.0/24", "office range")
	count({m | some m in deny; startswith(m, "IAM-02")}) == 0 with input as plan([r])
}

test_ipv6_public_ingress_is_caught if {
	r := {
		"address": "module.access_control.aws_vpc_security_group_ingress_rule.v6",
		"type": "aws_vpc_security_group_ingress_rule",
		"change": {"actions": ["create"], "after": {"cidr_ipv4": "::/0", "description": "open"}},
	}
	count({m | some m in deny; startswith(m, "IAM-02")}) == 1 with input as plan([r])
}

test_vpc_with_flow_log_is_allowed if {
	count({m | some m in deny; startswith(m, "NET-01")}) == 0 with input as plan(vpc_with_flow_log)
}

test_vpc_without_flow_log_is_denied if {
	count({m | some m in deny; startswith(m, "NET-01")}) == 1 with input as plan([vpc_with_flow_log[0]])
}
