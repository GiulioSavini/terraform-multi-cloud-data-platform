# Contributing to Terraform Multi-Cloud Data Platform

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

1. Check the [issue tracker](../../issues) to see if the bug has already been reported.
2. If not, open a new issue using the **Bug Report** template.
3. Include as much detail as possible: Terraform version, provider versions, error messages, and steps to reproduce.

### Suggesting Features

1. Check the [issue tracker](../../issues) for existing feature requests.
2. Open a new issue using the **Feature Request** template.
3. Describe the use case and expected behavior.

### Submitting Changes

1. Fork the repository.
2. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/my-feature
   ```
3. Make your changes following the coding standards below.
4. Commit your changes with a descriptive message:
   ```bash
   git commit -m "Add support for feature X"
   ```
5. Push to your fork and open a Pull Request against `main`.

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [TFLint](https://github.com/terraform-linters/tflint)
- [terraform-docs](https://github.com/terraform-docs/terraform-docs)
- [pre-commit](https://pre-commit.com/)

### Local Development

```bash
# Install pre-commit hooks
pre-commit install

# Format code
terraform fmt -recursive

# Validate modules
terraform validate

# Run linting
tflint --init
tflint
```

## Coding Standards

### Terraform Style

- Use `snake_case` for all resource names, variables, and outputs.
- Include descriptions for all variables and outputs.
- Use type constraints on all variables.
- Group related resources in logically named files (`main.tf`, `variables.tf`, `outputs.tf`).
- Tag all resources with at minimum: `project`, `environment`, and `managed_by`.

### Module Structure

Each module must contain:

- `main.tf` - Primary resource definitions
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value declarations
- `versions.tf` - Provider and Terraform version constraints
- `README.md` - Module documentation with usage examples

### Commit Messages

- Use the present tense ("Add feature" not "Added feature").
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
- Reference issues and pull requests where appropriate.

### Pull Requests

- Fill out the Pull Request template completely.
- Ensure all CI checks pass before requesting review.
- Keep PRs focused on a single change.
- Update documentation for any changed behavior.

## Testing

- Validate all modules with `terraform validate`.
- Run `terraform plan` against example configurations.
- Ensure `tflint` passes with no errors.
- Test across all supported cloud providers when applicable.

## Documentation

- Update module READMEs when changing inputs, outputs, or behavior.
- Use `terraform-docs` to regenerate documentation tables.
- Keep the CHANGELOG updated following [Keep a Changelog](https://keepachangelog.com/) format.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
