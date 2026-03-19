# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in this project, please report it responsibly.

### How to Report

1. **Do not** open a public issue for security vulnerabilities.
2. Email your findings to the repository maintainer.
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours.
- **Assessment**: We will assess the vulnerability and determine its severity within 5 business days.
- **Resolution**: We will work on a fix and aim to release a patch within 30 days of confirmation.
- **Disclosure**: We will coordinate with you on public disclosure timing.

## Security Best Practices

When using this project, follow these security best practices:

### State Management

- Always use remote state backends with encryption enabled.
- Enable state locking to prevent concurrent modifications.
- Restrict access to state files as they may contain sensitive data.

### Secrets Management

- Never commit secrets, API keys, or credentials to version control.
- Use cloud-native secret management services (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).
- Pass sensitive values via environment variables or a secrets manager, never in `.tfvars` files committed to the repository.

### Access Control

- Follow the principle of least privilege for all IAM roles and policies.
- Use separate credentials for each environment (dev, staging, production).
- Enable MFA for all cloud provider accounts.
- Regularly rotate access keys and credentials.

### Network Security

- Use private endpoints wherever possible.
- Restrict security group and firewall rules to the minimum required access.
- Enable VPC flow logs and network monitoring.
- Use encryption in transit (TLS) for all data transfers.

### Encryption

- Enable encryption at rest for all storage resources.
- Use customer-managed keys (CMK) for sensitive workloads.
- Rotate encryption keys according to your organization's policy.

### Monitoring and Auditing

- Enable cloud provider audit logging (CloudTrail, Azure Activity Log, GCP Audit Logs).
- Set up alerts for suspicious activity.
- Regularly review access logs and permissions.

## Terraform-Specific Security

- Pin provider versions to avoid unexpected changes.
- Review `terraform plan` output before applying changes.
- Use `checkov` or `tfsec` for static analysis of Terraform configurations.
- Implement policy-as-code with Sentinel or OPA.
