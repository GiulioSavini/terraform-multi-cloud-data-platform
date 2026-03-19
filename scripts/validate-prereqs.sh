#!/usr/bin/env bash
# =============================================================================
# validate-prereqs.sh
# Checks that all required tools are installed and configured
# Usage: ./scripts/validate-prereqs.sh
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

check_command() {
  local cmd=$1
  local min_version=${2:-""}
  local install_hint=${3:-""}

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$($cmd --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "${GREEN}[OK]${NC} $cmd found: $version"
  else
    echo -e "${RED}[MISSING]${NC} $cmd not found"
    [ -n "$install_hint" ] && echo -e "         Install: ${YELLOW}$install_hint${NC}"
    ERRORS=$((ERRORS + 1))
  fi
}

check_auth() {
  local provider=$1
  local check_cmd=$2
  local login_hint=$3

  echo -n "  Checking $provider authentication... "
  if eval "$check_cmd" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${RED}NOT AUTHENTICATED${NC}"
    echo -e "         Run: ${YELLOW}$login_hint${NC}"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=============================================="
echo "  Prerequisite Validation"
echo "=============================================="
echo ""

echo "--- Required Tools ---"
check_command "terraform"    "" "https://developer.hashicorp.com/terraform/install"
check_command "aws"          "" "pip install awscli"
check_command "az"           "" "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
check_command "gcloud"       "" "https://cloud.google.com/sdk/docs/install"
check_command "git"          "" "sudo apt install git"

echo ""
echo "--- Optional Tools ---"
check_command "tflint"       "" "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
check_command "tfsec"        "" "brew install tfsec"
check_command "checkov"      "" "pip install checkov"
check_command "infracost"    "" "https://www.infracost.io/docs/#quick-start"
check_command "terragrunt"   "" "https://terragrunt.gruntwork.io/docs/getting-started/install/"
check_command "pre-commit"   "" "pip install pre-commit"
check_command "jq"           "" "sudo apt install jq"

echo ""
echo "--- Cloud Authentication ---"
check_auth "AWS"   "aws sts get-caller-identity"                    "aws configure"
check_auth "Azure" "az account show"                                "az login"
check_auth "GCP"   "gcloud auth application-default print-access-token" "gcloud auth application-default login"

echo ""
echo "--- Terraform Version Check ---"
if command -v terraform &>/dev/null; then
  TF_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1 | grep -oP '\d+\.\d+\.\d+')
  MAJOR=$(echo "$TF_VERSION" | cut -d. -f1)
  MINOR=$(echo "$TF_VERSION" | cut -d. -f2)
  if [ "$MAJOR" -ge 1 ] && [ "$MINOR" -ge 9 ]; then
    echo -e "${GREEN}[OK]${NC} Terraform $TF_VERSION >= 1.9.0"
  else
    echo -e "${RED}[ERROR]${NC} Terraform $TF_VERSION < 1.9.0 required"
    ERRORS=$((ERRORS + 1))
  fi
fi

echo ""
echo "=============================================="
if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}$ERRORS issue(s) found. Fix them before proceeding.${NC}"
  exit 1
else
  echo -e "${GREEN}All checks passed! You're ready to deploy.${NC}"
  exit 0
fi
