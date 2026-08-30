package lib

import rego.v1

# Shared helpers for the policy set. Every policy evaluates the JSON produced by
#   tofu show -json plan.tfplan
# so `resource_changes` is the only entry point.

# Resources the plan will create or update. Deletions carry no configuration to
# assert on, and no-ops were already accepted by a previous run.
changed contains r if {
	r := input.resource_changes[_]
	r.change.actions[_] in {"create", "update"}
}

after(r) := r.change.after

# Tag map, whichever spelling the provider uses. AWS and Azure use `tags`, GCP
# uses `labels`, and AWS additionally exposes `tags_all` with provider-level
# default tags folded in — that is the one worth asserting on.
tags(r) := t if {
	t := r.change.after.tags_all
	t != null
}

tags(r) := t if {
	not r.change.after.tags_all
	t := r.change.after.tags
	t != null
}

tags(r) := t if {
	not r.change.after.tags_all
	not r.change.after.tags
	t := r.change.after.labels
	t != null
}

has_tags(r) if {
	tags(r)
}
