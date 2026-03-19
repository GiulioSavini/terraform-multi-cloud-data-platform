locals {
  name_prefix = "${var.project}-${var.environment}"
  geo_locations = length(var.geo_locations) > 0 ? var.geo_locations : [{ location = var.location, failover_priority = 0 }]
}

resource "azurerm_cosmosdb_account" "main" {
  name                = "${local.name_prefix}-cosmos"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  dynamic "geo_location" {
    for_each = local.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
    }
  }

  is_virtual_network_filter_enabled = true
  public_network_access_enabled     = false

  backup {
    type                = var.environment == "prd" ? "Continuous" : "Periodic"
    interval_in_minutes = var.environment == "prd" ? null : 240
    retention_in_hours  = var.environment == "prd" ? null : 8
    storage_redundancy  = var.environment == "prd" ? null : "Local"
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "${local.name_prefix}-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "events" {
  name                = "events"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = "/eventType"

  indexing_policy {
    indexing_mode = "consistent"
    included_path { path = "/*" }
    excluded_path { path = "/\"_etag\"/?" }
  }

  default_ttl = 2592000 # 30 days

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "analytics" {
  name                = "analytics"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = "/tenantId"

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}
