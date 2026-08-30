# ------------------------------------------------------------------------------
# Control catalog
#
# Maps each control this platform claims to the bounded context that implements
# it and the contract output that evidences it. The catalog is data; enforcement
# lives in compliance/policies and in the preconditions inside each context.
#
# Data platforms carry more regulatory weight than most infrastructure: the
# controls below lean towards inventory, classification, encryption and lineage,
# which is where a data audit actually looks.
# ------------------------------------------------------------------------------

locals {
  controls = {
    "NET-01" = {
      statement = "No data store is reachable from the internet; all sit on private subnets."
      context   = "networking"
      evidence  = "networks"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 5.x Networking"
        iso27001 = "A.8.20 Network security, A.8.22 Segregation of networks"
        soc2     = "CC6.6 Boundary protection"
        nis2     = "Art. 21(2)(d)"
      }
    }

    "LAKE-01" = {
      statement = "Every lake zone is encrypted with a customer-managed key."
      context   = "data-lake"
      evidence  = "encryption_keys"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 2.1.1 Object storage encryption"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.1 Logical access"
        nis2     = "Art. 21(2)(h) Cryptography"
      }
    }

    "LAKE-02" = {
      statement = "Storage is zoned raw / curated / analytics, and consumers address zones rather than bucket names."
      context   = "data-lake"
      evidence  = "zones"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.5.9 Inventory of assets, A.5.12 Classification of information"
        soc2     = "CC3.2 Risk identification"
        nis2     = "Art. 21(2)(a) Risk analysis"
      }
    }

    "STORE-01" = {
      statement = "Store credentials are referenced, never published into consumer state."
      context   = "operational-store"
      evidence  = "credential_references"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 1.x"
        iso27001 = "A.5.17 Authentication information"
        soc2     = "CC6.1"
        nis2     = "Art. 21(2)(i) Access control"
      }
    }

    "STORE-02" = {
      statement = "No well-known administrative usernames on transactional stores."
      context   = "operational-store"
      evidence  = "endpoints"
      severity  = "high"
      frameworks = {
        cis      = "CIS 1.x Identity"
        iso27001 = "A.5.16 Identity management"
        soc2     = "CC6.1"
        nis2     = "Art. 21(2)(i)"
      }
    }

    "WH-01" = {
      statement = "The warehouse reads the analytics zone only; it never writes raw or curated."
      context   = "analytics-warehouse"
      evidence  = "workload_identities"
      severity  = "high"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.3 Information access restriction"
        soc2     = "CC6.3 Least privilege"
        nis2     = "Art. 21(2)(i)"
      }
    }

    "STR-01" = {
      statement = "Streamed events are captured to durable storage before the retention window closes."
      context   = "stream-ingestion"
      evidence  = "brokers"
      severity  = "high"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.13 Information backup"
        soc2     = "A1.2 Availability"
        nis2     = "Art. 21(2)(c) Business continuity"
      }
    }

    "STR-02" = {
      statement = "Messages at rest are encrypted with a customer-managed key."
      context   = "stream-ingestion"
      evidence  = "encryption_keys"
      severity  = "high"
      frameworks = {
        cis      = "CIS 2.x"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.1"
        nis2     = "Art. 21(2)(h)"
      }
    }

    "PIPE-01" = {
      statement = "Only pipeline identities may write the raw and curated zones."
      context   = "data-pipeline"
      evidence  = "pipeline_identities"
      severity  = "critical"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.3 Information access restriction, A.8.4 Access to source code"
        soc2     = "CC6.3 Least privilege"
        nis2     = "Art. 21(2)(i)"
      }
    }

    "PIPE-02" = {
      statement = "Pipeline workers run on the private network, never with public addresses."
      context   = "data-pipeline"
      evidence  = "pipeline_identities"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x"
        iso27001 = "A.8.20 Network security"
        soc2     = "CC6.6"
        nis2     = "Art. 21(2)(d)"
      }
    }

    "GOV-01" = {
      statement = "A cross-cloud catalog records what data exists and how it is classified."
      context   = "data-governance"
      evidence  = "catalog"
      severity  = "high"
      frameworks = {
        cis      = "—"
        iso27001 = "A.5.9 Inventory of assets, A.5.12 Classification of information"
        soc2     = "CC3.2 Risk identification"
        nis2     = "Art. 21(2)(a) Risk analysis"
      }
    }

    "GOV-02" = {
      statement = "Catalog identities are read-only."
      context   = "data-governance"
      evidence  = "governance_identities"
      severity  = "high"
      frameworks = {
        cis      = "CIS 1.x"
        iso27001 = "A.5.15 Access control"
        soc2     = "CC6.3 Least privilege"
        nis2     = "Art. 21(2)(i)"
      }
    }

    "TAG-01" = {
      statement = "Every resource carries owner, cost centre and data classification."
      context   = "platform/tagging"
      evidence  = "mandatory_keys"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.5.9 Inventory of assets"
        soc2     = "CC3.2"
        nis2     = "Art. 21(2)(a)"
      }
    }
  }

  frameworks = ["cis", "iso27001", "soc2", "nis2"]
}
