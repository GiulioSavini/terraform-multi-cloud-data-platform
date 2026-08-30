# Bounded context: data-governance

Owns the cross-cloud view: the catalog, data classification, and the keys and
roles that make access auditable.

## One adapter, and it is cross-cloud

Governance covering a single provider is not governance. A catalog listing one
of three clouds is worse than no catalog at all, because it reports full
coverage of a platform it only half sees. The context therefore refuses to
apply with fewer than two clouds in scope.

## Read-only by design

`governance_identities` are scanning identities. A catalog that can write is a
catalog that can destroy what it indexes, and the whole value of the catalog is
that it is a trustworthy record of what exists.

## Compliance

| Control | Framework | Evidence |
|---|---|---|
| Data inventory and classification | ISO 27001 A.5.9, A.5.12; NIS2 Art. 21(2)(a) | `catalog` |
| Customer-managed encryption keys | CIS 2.x, ISO 27001 A.8.24, SOC 2 CC6.1 | `encryption_keys` |
| Auditable, least-privilege catalog access | SOC 2 CC6.1, ISO 27001 A.5.15 | `governance_identities` |
