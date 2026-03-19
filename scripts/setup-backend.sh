#!/usr/bin/env bash
# =============================================================================
# setup-backend.sh - Data Platform
# Creates remote state backends
# Usage: ./scripts/setup-backend.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
PROJECT="data-platform"
GREEN='\033[0;32m'
NC='\033[0m'

AWS_REGION=$(aws configure get region 2>/dev/null || echo "eu-west-1")
BUCKET="${PROJECT}-tfstate-${ENV}"
TABLE="${PROJECT}-tflock-${ENV}"

echo "Creating S3 bucket: $BUCKET"
if ! aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  aws s3api create-bucket --bucket "$BUCKET" --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption --bucket "$BUCKET" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
  aws s3api put-public-access-block --bucket "$BUCKET" \
    --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
fi
echo -e "${GREEN}S3 bucket ready${NC}"

echo "Creating DynamoDB table: $TABLE"
if ! aws dynamodb describe-table --table-name "$TABLE" &>/dev/null; then
  aws dynamodb create-table --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST --region "$AWS_REGION"
fi
echo -e "${GREEN}DynamoDB table ready${NC}"

echo -e "\n${GREEN}Backend ready for: $ENV${NC}"
