# terraform-multi-cloud-data-platform

A data platform across AWS, Azure and GCP, organised as **bounded contexts**
rather than as a pile of provider modules.

[![CI](https://github.com/GiulioSavini/terraform-multi-cloud-data-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/GiulioSavini/terraform-multi-cloud-data-platform/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Why it is laid out this way

The tree used to be `modules/aws/aurora`, `modules/azure/cosmosdb`,
`modules/gcp/bigquery` — organised by vendor, which makes the cloud the primary
axis and the problem being solved a secondary one. Here the **domain is the
axis** and the provider is an implementation detail private to the context.

```
domains/<context>/
    contract.tf      the public interface and its invariants
    outputs.tf       what the context publishes
    README.md        the invariants, written down
    aws/ azure/ gcp/ adapters, private to the context
```

`scripts/check-boundaries.sh` fails CI if a context is consumed through one of
its adapters instead of its contract.

### The contexts and how data moves through them

| Context | Owns |
|---|---|
| [`networking`](domains/networking) | The private fabric every store sits on |
| [`data-lake`](domains/data-lake) | Object storage, zoned raw / curated / analytics |
| [`operational-store`](domains/operational-store) | Transactional stores applications write to |
| [`stream-ingestion`](domains/stream-ingestion) | The event backbone, and cross-cloud mirroring |
| [`analytics-warehouse`](domains/analytics-warehouse) | The stores analysts query |
| [`data-pipeline`](domains/data-pipeline) | Movement and transformation |
| [`data-governance`](domains/data-governance) | The cross-cloud catalog and classification |

The write path is deliberately narrow:

- **`data-pipeline` is the only context that writes raw and curated.**
- **`analytics-warehouse` reads analytics and never writes the lake.**
- Applications write to `operational-store`; pipelines read from it.

That is what makes lineage answerable and keeps a bad query from corrupting
source data nothing else can reconstruct.

## Zones, not bucket names

Consumers ask the lake for a **zone**. They never reconstruct a bucket name from
a naming convention — the convention changes, the pipeline keeps running, and it
writes somewhere that does not exist.

```hcl
zones = { aws = { raw = "...", curated = "...", analytics = "..." } }
```

## Credentials are referenced, never published

Contexts publish `credential_references` — the ARN or path where a secret lives,
not the secret. Publishing the value would copy it into the state file of every
consumer; publishing the reference means each consumer resolves it at run time
under its own identity.

## Compliance

Controls are declared in [`compliance/controls`](compliance/controls) and mapped
to **CIS Benchmarks, ISO 27001 Annex A, SOC 2 TSC and NIS2**, leaning towards
inventory, classification, encryption and lineage — which is where a data audit
actually looks. Each control names the context that implements it and the
contract output that evidences it.

Enforcement is in two places: preconditions inside each context, and rego
evaluated by conftest against plan JSON in
[`compliance/policies`](compliance/policies). The policies have 23 unit tests of
their own; `make policy` runs them.

`terraform output compliance_evidence` returns the control values read from the
contracts.

## CI

`fmt`, `validate` across all fourteen roots, context boundaries, **provider pin
agreement**, policy unit tests, `tflint`, and a Trivy config scan. Every job can
fail the build.

The provider-pin check exists because this repository once pinned
`hashicorp/google` at `~> 5.0` in seven modules and `~> 6.0` in seven others,
with `azurerm` split the same way between 3.x and 4.x. No root could resolve
both, so every example failed at `terraform init`. That check makes the drift
visible in review instead of fatal at init.

## What this repository is not

It is a **reference platform**, not a product. It has never been applied against
a billing account by its author — every check in CI is static: format, validate,
lint, policy unit tests, misconfiguration scanning. Nothing here has been proven
against live cloud APIs, and applying it will cost a significant amount of money
(MSK, Redshift and Synapse in particular).

## License

MIT — see [LICENSE](LICENSE).
