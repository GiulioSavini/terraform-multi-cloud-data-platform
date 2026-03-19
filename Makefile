.PHONY: help init plan apply destroy fmt validate lint security test clean docker-build docker-run

SHELL := /bin/bash
ENV ?= dev
AWS_REGION ?= eu-west-1
AZURE_REGION ?= westeurope
GCP_REGION ?= europe-west1
TF_DIR := environments/$(ENV)
DOCKER_IMAGE := terraform-data-platform
DOCKER_TAG := latest

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m

help: ## Show this help message / Mostra questo messaggio di aiuto
	@echo -e "$(GREEN)Terraform Multi-Cloud Data Platform$(NC)"
	@echo ""
	@echo "Usage: make <target> [ENV=dev|stg|prd]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

init: ## Initialize Terraform for the specified environment
	@echo -e "$(GREEN)Initializing Terraform for $(ENV)...$(NC)"
	cd $(TF_DIR) && terraform init -upgrade

plan: ## Generate and show an execution plan
	@echo -e "$(GREEN)Planning Terraform for $(ENV)...$(NC)"
	cd $(TF_DIR) && terraform plan -var-file=terraform.tfvars -out=tfplan

apply: ## Apply the planned changes
	@echo -e "$(GREEN)Applying Terraform for $(ENV)...$(NC)"
	cd $(TF_DIR) && terraform apply tfplan

apply-auto: ## Apply changes with auto-approve (use with caution)
	@echo -e "$(RED)Auto-applying Terraform for $(ENV)...$(NC)"
	cd $(TF_DIR) && terraform apply -var-file=terraform.tfvars -auto-approve

destroy: ## Destroy all resources (DANGEROUS)
	@echo -e "$(RED)Destroying Terraform resources for $(ENV)...$(NC)"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || exit 1
	cd $(TF_DIR) && terraform destroy -var-file=terraform.tfvars -auto-approve

fmt: ## Format Terraform files recursively
	@echo -e "$(GREEN)Formatting Terraform files...$(NC)"
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	@echo -e "$(GREEN)Validating Terraform for $(ENV)...$(NC)"
	cd $(TF_DIR) && terraform validate

lint: ## Run tflint on all modules
	@echo -e "$(GREEN)Running tflint...$(NC)"
	@find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do \
		echo "Linting $$dir"; \
		tflint --chdir=$$dir || true; \
	done

security: ## Run security scans (tfsec + checkov)
	@echo -e "$(GREEN)Running tfsec...$(NC)"
	tfsec . --minimum-severity MEDIUM
	@echo -e "$(GREEN)Running checkov...$(NC)"
	checkov -d . --quiet --compact

test: ## Run all checks (fmt, validate, lint, security)
	@$(MAKE) fmt
	@$(MAKE) validate
	@$(MAKE) lint
	@$(MAKE) security

clean: ## Remove Terraform cache and plan files
	@echo -e "$(YELLOW)Cleaning Terraform cache...$(NC)"
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true

output: ## Show Terraform outputs for the specified environment
	@echo -e "$(GREEN)Outputs for $(ENV):$(NC)"
	cd $(TF_DIR) && terraform output

state-list: ## List resources in Terraform state
	cd $(TF_DIR) && terraform state list

console: ## Open Terraform console
	cd $(TF_DIR) && terraform console

graph: ## Generate resource dependency graph
	cd $(TF_DIR) && terraform graph | dot -Tpng > graph.png
	@echo "Graph saved to $(TF_DIR)/graph.png"

docker-build: ## Build the Docker workspace image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-run: ## Run the Docker workspace
	docker run -it --rm \
		-v $(PWD):/workspace \
		-v ~/.aws:/root/.aws:ro \
		-v ~/.azure:/root/.azure:ro \
		-v ~/.config/gcloud:/root/.config/gcloud:ro \
		-w /workspace \
		$(DOCKER_IMAGE):$(DOCKER_TAG) bash

terragrunt-init: ## Initialize with Terragrunt
	cd $(TF_DIR) && terragrunt init

terragrunt-plan: ## Plan with Terragrunt
	cd $(TF_DIR) && terragrunt plan

terragrunt-apply: ## Apply with Terragrunt
	cd $(TF_DIR) && terragrunt apply
