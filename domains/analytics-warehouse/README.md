# Bounded context: analytics-warehouse

Owns the stores analysts query: Redshift, Synapse, BigQuery.

## Reads analytics, never writes raw

This context reads the **analytics** zone of the data lake. Writing to raw or
curated is `domains/data-pipeline`'s job. The separation is what keeps a bad
query or a mistaken `CREATE TABLE AS` from corrupting source data that nothing
else can reconstruct.

## Invariants

1. **AWS needs the analytics zone ARN.** Redshift Spectrum's external schema
   resolves to nothing without it — and it fails silently at query time, not
   at apply time.
2. **Azure Synapse is backed by the lake's storage account**, not a second one.
3. **Credentials are referenced, never published.**
