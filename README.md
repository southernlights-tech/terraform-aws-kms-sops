# Terraform AWS KMS SOPS Module

Terraform module for AWS KMS key management and encryption for SOPS (Secrets OPerationS) secret management in GitOps workflows.

## Features

- ✅ **KMS Key Management** - Create and manage AWS KMS keys with automatic key rotation
- ✅ **SOPS Integration** - Pre-configured for SOPS secret encryption and decryption
- ✅ **4-Statement RBAC Policy** - Granular access control (root, admin, users, attachers)
- ✅ **Multi-Environment Support** - Single module for dev, staging, and production environments
- ✅ **Automatic Key Rotation** - Annual rotation enabled by default (no additional cost)
- ✅ **Deletion Protection** - 30-day grace period prevents accidental key deletion
- ✅ **Reusable** - Consistent with southernlights-tech module standards

## Quick Usage

### Minimal Example (Development)

```hcl
module "kms_sops" {
  source = "github.com/southernlights-tech/terraform-aws-kms-sops"

  environment           = "dev"
  kms_alias_prefix      = "sops"
  description           = "SOPS encryption key for GitOps secrets"
  
  enable_iam_principals = ["arn:aws:iam::123456789012:root"]
  admin_principals      = ["arn:aws:iam::123456789012:role/terraform"]
  users_principals      = ["arn:aws:iam::123456789012:role/flux-cd-role"]
}
```

### Complete Example (Production with All Options)

```hcl
module "kms_sops" {
  source = "github.com/southernlights-tech/terraform-aws-kms-sops"

  environment             = "prod"
  kms_alias_prefix        = "sops"
  description             = "SOPS encryption key for GitOps secrets (Production)"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  enable_iam_principals = ["arn:aws:iam::123456789012:root"]
  admin_principals      = [
    "arn:aws:iam::123456789012:role/terraform",
    "arn:aws:iam::123456789012:role/devops"
  ]
  users_principals = [
    "arn:aws:iam::123456789012:role/flux-cd-role",
    "arn:aws:iam::123456789012:role/app-service-role"
  ]
  attachers_principals = [
    "arn:aws:iam::123456789012:role/aws-service-role"
  ]
  
  tags = {
    CostCenter = "Infrastructure"
    Owner      = "DevOps Team"
  }
}
```

## KMS Key Policy (4 Statements)

### Statement 1: Enable IAM User Permissions
- **Principal**: AWS root account
- **Permissions**: `kms:*` (full admin)
- **Purpose**: Account-level emergency access

### Statement 2: Allow Key Administrators
- **Principal**: Admin roles (Terraform, DevOps)
- **Permissions**: Create, Describe, Enable, List, Put, Update, Revoke, Disable, Get, Delete, TagResource, ScheduleKeyDeletion, RotateKeyOnDemand
- **Purpose**: Terraform automation, key management, rotation

### Statement 3: Allow Use of Key
- **Principal**: User roles (Flux CD, applications, operators)
- **Permissions**: Encrypt, Decrypt, ReEncrypt, GenerateDataKey, DescribeKey
- **Purpose**: SOPS encryption/decryption, application usage

### Statement 4: Allow Attachment of Persistent Resources
- **Principal**: AWS services (optional)
- **Permissions**: CreateGrant, ListGrants, RevokeGrant
- **Condition**: `kms:GrantIsForAWSResource = true`
- **Purpose**: AWS service grants (S3, DynamoDB, Lambda, etc.)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Environment name (dev, staging, prod) | `string` | - | yes |
| `description` | Description of the KMS key | `string` | - | yes |
| `kms_alias_prefix` | Prefix for KMS alias (e.g., 'sops', 'secrets') | `string` | `"sops"` | no |
| `deletion_window_in_days` | KMS key deletion window in days (7-30) | `number` | `30` | no |
| `enable_key_rotation` | Enable automatic key rotation | `bool` | `true` | no |
| `enable_iam_principals` | IAM principals with full KMS permissions (root account) | `list(string)` | - | yes |
| `admin_principals` | IAM principals with administrative permissions | `list(string)` | - | yes |
| `users_principals` | IAM principals with user permissions (encrypt/decrypt) | `list(string)` | - | yes |
| `attachers_principals` | IAM principals that can create/revoke grants | `list(string)` | `[]` | no |
| `tags` | Tags to apply to KMS key | `map(string)` | `{}` | no |
| `additional_tags` | Additional tags to merge | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `outputs` | Map containing all KMS key outputs (key_id, key_arn, alias_name, alias_arn, etc.) |

### Output Map Details

```hcl
outputs = {
  key_id               = "12345678-1234-1234-1234-123456789012"
  key_arn              = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  alias_name           = "alias/sops-dev"
  alias_arn            = "arn:aws:kms:us-east-1:123456789012:alias/sops-dev"
  alias_target_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  key_is_enabled       = true
}
```

## Usage Examples

See `examples/minimal/main.tf` and `examples/complete/main.tf` for full working examples.

## Troubleshooting

### Permission Denied Errors

```bash
# Verify your principal is authorized
aws sts get-caller-identity

# Check key policy
aws kms get-key-policy \
  --key-id alias/sops-dev \
  --policy-name default \
  --region us-east-1
```

### KMS Key Not Found

```bash
# List all keys
aws kms list-keys --region us-east-1

# Describe specific key
aws kms describe-key --key-id alias/sops-dev
```

## Module Requirements

- **Terraform**: >= 1.0
- **AWS Provider**: >= 5.0
- **AWS Account**: Access to create KMS keys and manage IAM policies

## License

Apache License 2.0 - See LICENSE file for details

## Related Documentation

- [AWS KMS Documentation](https://docs.aws.amazon.com/kms/)
- [SOPS (Secrets OPerationS)](https://github.com/mozilla/sops)
- [Terraform AWS Provider - KMS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
