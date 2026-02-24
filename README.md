# terraform-aws-kms-sops

Terraform module for AWS KMS key management and encryption for SOPS (Secrets OPerationS) secret management in GitOps workflows.

## Features

- KMS Key Management with automatic annual rotation
- SOPS integration for secret encryption and decryption
- 4-statement RBAC policy for granular access control
- Multi-environment support (dev, staging, prod)
- 30-day deletion protection window
- Consistent with southernlights-tech module standards

## Quick Start

```hcl
module "kms_sops" {
  source = "github.com/southernlights-tech/terraform-aws-kms-sops"

  environment           = "dev"
  description           = "SOPS encryption key"
  
  enable_iam_principals = ["arn:aws:iam::123456789012:root"]
  admin_principals      = ["arn:aws:iam::123456789012:role/terraform"]
  users_principals      = ["arn:aws:iam::123456789012:role/flux-cd"]
}
```

## Documentation

See the examples directory for complete usage examples.
