# Bounded context: data-lake

Owns object storage and its zoning: **raw**, **curated**, **analytics**.

## The zone vocabulary is the contract

Consumers ask for a zone. They never construct a bucket or container name
themselves, and they never assume a naming convention. That is what lets the
underlying storage be renamed, re-regioned or replaced without touching the
pipelines that read it.

```hcl
zones = {
  aws = { raw = "...", curated = "...", analytics = "..." }
}
```

## Invariants

1. **Every lake is encrypted with a customer-managed key.** The key is
   published so downstream contexts can be granted use of it rather than
   copying data out to somewhere unencrypted.
2. **Nothing here is public.** Storage sits behind the private fabric from
   `domains/networking`.
