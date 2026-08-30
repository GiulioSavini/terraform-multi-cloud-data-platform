# Bounded context: stream-ingestion

Owns the event backbone: MSK, Event Hubs, Pub/Sub, and optionally the
connectors that mirror topics between clouds.

## Invariants

1. **Event Hubs needs a capture destination.** Without one, events past the
   retention window are gone, and nothing warns you until someone asks for
   last month's data.
2. **Cross-cloud replication requires both AWS and Azure.** The mirror has no
   second endpoint otherwise.
3. **`brokers` is sensitive.** Bootstrap strings for Event Hubs carry a shared
   access key.

## Replication is not free

Mirroring doubles egress cost and introduces an ordering guarantee the source
brokers do not make: a consumer reading the mirror can see events in a
different order from a consumer reading the source. Enable it only when a
consumer genuinely cannot reach the source cloud.
