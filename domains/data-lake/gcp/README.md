# data-lake / gcp adapter

**This is a private adapter of the `data-lake` bounded context. Do not source it
directly.**

It translates the `data-lake` contract into gcp resources, and its interface
tracks the provider rather than the domain — it will change when the provider
does, without a major version bump, because nothing outside the context is
supposed to depend on it.

Consume [`domains/data-lake`](../) instead. `scripts/check-boundaries.sh` fails CI
if this directory is sourced from outside its own context.

If you need something this adapter exposes and the contract does not, add it to
the contract.
