# Bounded context: operational-store

Owns the transactional stores applications write to: Aurora, Cosmos DB,
Cloud SQL.

Distinct from `domains/analytics-warehouse`, which owns the stores analysts
query. Different access patterns, different retention, and a very different
blast radius when something goes wrong.

## Credentials are referenced, never published

`credential_references` gives the location of a secret, not its value.
Publishing the secret would copy it into the state file of every consumer;
publishing the reference means each consumer resolves it at run time under its
own identity.

## Invariants

1. **No well-known administrative usernames.** `admin`, `root`, `sa` and
   `postgres` are rejected: the username is the half of a credential pair that
   never gets rotated.
2. **Every store sits on the private fabric.** A cloud in scope must exist in
   `networks`.
3. **Cloud SQL needs the network id** for private service access, not a subnet.
