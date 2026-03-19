output "events_topic_id" {
  description = "Events topic ID"
  value       = google_pubsub_topic.events.id
}

output "metrics_topic_id" {
  description = "Metrics topic ID"
  value       = google_pubsub_topic.metrics.id
}

output "commands_topic_id" {
  description = "Commands topic ID"
  value       = google_pubsub_topic.commands.id
}

output "dead_letter_topic_id" {
  description = "Dead letter topic ID"
  value       = google_pubsub_topic.dead_letter.id
}

output "topic_ids" {
  description = "Map of all topic IDs"
  value = {
    events      = google_pubsub_topic.events.id
    metrics     = google_pubsub_topic.metrics.id
    commands    = google_pubsub_topic.commands.id
    dead_letter = google_pubsub_topic.dead_letter.id
  }
}
