# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- AWS modules: Aurora PostgreSQL, Redshift, S3 Data Lake, Glue ETL, MSK Kafka, and VPC networking.
- Azure modules: CosmosDB, Synapse Analytics, ADLS Gen2, Data Factory, Event Hubs (Kafka), and VNet networking.
- GCP modules: CloudSQL PostgreSQL, BigQuery, GCS Data Lake, Dataflow, Pub/Sub (Kafka), and VPC networking.
- Shared modules: cross-cloud governance (KMS, Purview) and streaming (MSK Connect, cross-cloud replication).
- Multi-environment support with dev, staging, and production configurations.
- CI/CD pipelines with GitHub Actions for validation, planning, and deployment.
- TFLint configuration with AWS, Azure, and GCP plugins.
- Pre-commit hooks for formatting, validation, and documentation generation.
- Comprehensive documentation and module READMEs.
