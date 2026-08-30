# Bounded context: data-pipeline

Owns movement and transformation: Glue, Data Factory, Dataflow.

**This is the only context that writes to the raw and curated zones.**
`analytics-warehouse` reads the analytics zone; applications write to
`operational-store`. Everything that lands in the lake lands through here, which
is what makes lineage answerable.

## The most connected context, on purpose

It reads from the operational stores, writes to the lake, and feeds the
warehouse. Every one of those is passed in as another context's contract rather
than discovered at run time — a pipeline that finds its own inputs is a pipeline
whose blast radius nobody can determine from the code.

Zones are addressed through the `data-lake` contract. Reconstructing a bucket
name from a naming convention is the failure this avoids: the convention changes,
the pipeline keeps running, and it writes to a bucket that does not exist.

## Invariants

1. **AWS pipelines need the lake's KMS key.** Glue cannot read an encrypted lake
   without it, and the failure surfaces at job run time, not at apply time.
2. **Dataflow workers run on the private network.** The default is public IPs.
3. **Every cloud in scope has a destination zone.**
