output "events_topic_id" { value = google_pubsub_topic.events.id }
output "metrics_topic_id" { value = google_pubsub_topic.metrics.id }
output "dead_letter_topic_id" { value = google_pubsub_topic.dead_letter.id }
