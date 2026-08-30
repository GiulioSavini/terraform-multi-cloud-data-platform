# Bounded context: networking

Owns the private fabric every data store is placed into.

Nothing in this platform is internet-reachable by design: stores sit on private
subnets and are reached through private endpoints. That makes this context a
prerequisite for every other one.

## Invariants

1. **Address ranges do not overlap.** Cross-cloud replication routes between
   them; overlapping ranges blackhole traffic with no build error.
2. **Every cloud in scope has placement.**
3. **Subnet CIDRs are carved here, not passed in.** Address allocation is a
   single decision at the context boundary.

## Why three non-uniform outputs

`aws_security_groups`, `azure_subnets` and `gcp_network` are deliberately
provider-shaped. The three clouds do not model private access the same way —
AWS uses security groups, Azure uses subnet-scoped private endpoints, GCP uses
private service access — and inventing a common vocabulary would mean
publishing fields that are null two times out of three.
