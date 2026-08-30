package main

import data.lib
import rego.v1

# LOG-01 -- Logs are retained at least 90 days, and 365 in production.
#
# CloudWatch treats retention_in_days = 0 as "never expire", which satisfies
# the floor. Every rule below excludes it explicitly rather than letting the
# numeric comparison flag the most conservative setting there is.

min_retention_days := 90

min_retention_days_prd := 365

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_cloudwatch_log_group"
	a := lib.after(r)
	a.retention_in_days != 0
	a.retention_in_days < min_retention_days
	msg := sprintf("LOG-01: %s retains logs for %d days, below the %d day floor. An incident found after the fact would leave no evidence.", [r.address, a.retention_in_days, min_retention_days])
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_cloudwatch_log_group"
	a := lib.after(r)
	is_production(a)
	a.retention_in_days != 0
	a.retention_in_days < min_retention_days_prd
	msg := sprintf("LOG-01: %s is a production log group retained for only %d days; production requires %d (ISO 27001 A.8.15, NIS2 Art. 21).", [r.address, a.retention_in_days, min_retention_days_prd])
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_cloudwatch_log_group"
	not r.change.after.retention_in_days
	msg := sprintf("LOG-01: %s does not set retention_in_days. Leaving it implicit makes the retention period unauditable.", [r.address])
}

is_production(a) if {
	a.tags.Environment == "prd"
}
