#!/usr/bin/env bash
# =============================================================================
# destroy-all.sh
# Safely destroys all infrastructure with confirmations
# Usage: ./scripts/destroy-all.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   DESTROY ALL INFRASTRUCTURE                ║${NC}"
echo -e "${RED}║   Environment: $ENV                            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

if [ "$ENV" = "prd" ]; then
  echo -e "${RED}⚠️  WARNING: You are about to destroy PRODUCTION!${NC}"
  echo -e "${RED}   This action is IRREVERSIBLE.${NC}"
  echo ""
  read -p "Type 'DESTROY-PRODUCTION' to confirm: " CONFIRM
  if [ "$CONFIRM" != "DESTROY-PRODUCTION" ]; then
    echo "Aborted."
    exit 1
  fi
else
  read -p "Are you sure you want to destroy $ENV? (yes/no): " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
  fi
fi

echo ""
echo -e "${YELLOW}Starting destruction of $ENV environment...${NC}"
echo ""

cd "environments/$ENV"

# Show what will be destroyed
echo "--- Resources to be destroyed ---"
terraform plan -destroy -var-file=terraform.tfvars -no-color 2>/dev/null | grep "will be destroyed" | head -20 || true
echo ""

read -p "Proceed with destroy? (yes/no): " FINAL_CONFIRM
if [ "$FINAL_CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

# Run destroy
terraform destroy -var-file=terraform.tfvars -auto-approve

echo ""
echo -e "${GREEN}✅ Environment $ENV has been destroyed.${NC}"
echo ""
echo "Note: Remote state backends (S3/Azure Storage/GCS) are NOT deleted."
echo "To clean those up, run the cloud provider CLIs manually."
