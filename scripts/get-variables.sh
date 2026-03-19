#!/usr/bin/env bash
# =============================================================================
# get-variables.sh - Data Platform
# Auto-discovers cloud variables and generates terraform.tfvars
# Usage: ./scripts/get-variables.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "=============================================="
echo "  Auto-discovering variables for: $ENV"
echo "=============================================="

# Discover cloud configs
AWS_REGION=$(aws configure get region 2>/dev/null || echo "eu-west-1")
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null || echo "CHANGE_ME")
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv 2>/dev/null || echo "CHANGE_ME")
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "CHANGE_ME")
GCP_REGION=$(gcloud config get-value compute/region 2>/dev/null || echo "europe-west1")

echo -e "${CYAN}AWS:${NC}   $AWS_REGION"
echo -e "${CYAN}Azure:${NC} $AZURE_SUBSCRIPTION_ID"
echo -e "${CYAN}GCP:${NC}   $GCP_PROJECT_ID"

# Sizing per environment
case $ENV in
  dev)
    AURORA_INSTANCE="db.t3.medium"; AURORA_COUNT=1
    REDSHIFT_TYPE="dc2.large"; REDSHIFT_NODES=1
    MSK_TYPE="kafka.t3.small"; MSK_BROKERS=2
    COSMOS_THROUGHPUT=1000
    SYNAPSE_SKU="DW100c"
    CLOUDSQL_TIER="db-f1-micro"
    ;;
  stg)
    AURORA_INSTANCE="db.r6g.large"; AURORA_COUNT=2
    REDSHIFT_TYPE="ra3.xlplus"; REDSHIFT_NODES=2
    MSK_TYPE="kafka.m5.large"; MSK_BROKERS=3
    COSMOS_THROUGHPUT=4000
    SYNAPSE_SKU="DW200c"
    CLOUDSQL_TIER="db-custom-2-8192"
    ;;
  prd)
    AURORA_INSTANCE="db.r6g.xlarge"; AURORA_COUNT=3
    REDSHIFT_TYPE="ra3.xlplus"; REDSHIFT_NODES=4
    MSK_TYPE="kafka.m5.2xlarge"; MSK_BROKERS=3
    COSMOS_THROUGHPUT=10000
    SYNAPSE_SKU="DW500c"
    CLOUDSQL_TIER="db-custom-4-16384"
    ;;
esac

TFVARS_FILE="environments/$ENV/terraform.tfvars"

cat > "$TFVARS_FILE" << EOF
# Auto-generated on $(date -Iseconds)
project     = "data-platform"
environment = "$ENV"

# AWS
aws_region       = "$AWS_REGION"
aurora_instance  = "$AURORA_INSTANCE"
aurora_count     = $AURORA_COUNT
redshift_type    = "$REDSHIFT_TYPE"
redshift_nodes   = $REDSHIFT_NODES
msk_type         = "$MSK_TYPE"
msk_brokers      = $MSK_BROKERS

# Azure
azure_subscription_id = "$AZURE_SUBSCRIPTION_ID"
azure_tenant_id       = "$AZURE_TENANT_ID"
azure_location        = "westeurope"
cosmos_throughput     = $COSMOS_THROUGHPUT
synapse_sku           = "$SYNAPSE_SKU"
synapse_password      = "CHANGE_ME_strong_password_123!"

# GCP
gcp_project_id  = "$GCP_PROJECT_ID"
gcp_region      = "$GCP_REGION"
cloudsql_tier   = "$CLOUDSQL_TIER"
EOF

echo -e "\n${GREEN}Generated: $TFVARS_FILE${NC}"
echo -e "Review and update ${YELLOW}CHANGE_ME${NC} values, especially synapse_password."
echo "Next: cd environments/$ENV && terraform init && terraform plan"
