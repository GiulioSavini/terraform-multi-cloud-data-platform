#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh - Data Platform
# One-command setup
# Usage: ./scripts/bootstrap.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV=${1:-dev}
cd "$PROJECT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   Data Platform Bootstrap                    ║"
echo "║   Environment: $ENV                            ║"
echo "╚══════════════════════════════════════════════╝"

echo -e "\n📋 Step 1/4: Validating prerequisites..."
bash "$SCRIPT_DIR/validate-prereqs.sh" || exit 1

echo -e "\n🪝 Step 2/4: Setting up pre-commit hooks..."
command -v pre-commit &>/dev/null && pre-commit install || echo "pre-commit not found, skipping"

echo -e "\n🗄️  Step 3/4: Creating remote state backend..."
bash "$SCRIPT_DIR/setup-backend.sh" "$ENV"

echo -e "\n🔍 Step 4/4: Auto-discovering variables..."
bash "$SCRIPT_DIR/get-variables.sh" "$ENV"

cd "deployments/$ENV" && terraform init -upgrade

echo -e "\n╔══════════════════════════════════════════════╗"
echo "║   Bootstrap complete!                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Next: make plan ENV=$ENV"
