package main

import data.lib
import rego.v1

# IAM-02 -- Public ingress is declared explicitly and reviewable.
#
# Ingress open to the internet is legitimate on a public load balancer and
# almost never legitimate anywhere else. The rule's own description is what
# distinguishes the two, which is why the convention is enforced, not suggested.

public_cidrs := {"0.0.0.0/0", "::/0"}

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_vpc_security_group_ingress_rule"
	a := lib.after(r)
	a.cidr_ipv4 in public_cidrs
	not contains(lower(object.get(a, "description", "")), "internet")
	msg := sprintf("IAM-02: %s allows ingress from %s but its description does not identify it as an intentional public endpoint. Public ingress belongs on load balancers and must say so.", [r.address, a.cidr_ipv4])
}

# Traffic reaching an instance tier directly from the internet is a finding
# regardless of description: it must arrive through the load balancer.
deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_vpc_security_group_ingress_rule"
	a := lib.after(r)
	a.cidr_ipv4 in public_cidrs
	contains(lower(r.address), "instance")
	msg := sprintf("IAM-02: %s exposes an instance security group directly to %s. Instances must only accept traffic from the load balancer security group.", [r.address, a.cidr_ipv4])
}

# NET-01 -- All networks emit flow logs.
deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_vpc"
	not flow_log_planned
	msg := sprintf("NET-01: %s is created without any aws_flow_log in the same plan. Set flow_logs_enabled on the networking context.", [r.address])
}

flow_log_planned if {
	r := lib.changed[_]
	r.type == "aws_flow_log"
}
