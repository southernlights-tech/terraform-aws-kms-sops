# Complete example: KMS module with all optional parameters
# This demonstrates all available configuration options for production environments

module "kms_sops" {
  source = "../.."

  # Required: Environment and naming configuration
  environment      = "prod"
  kms_alias_prefix = "sops"
  description      = "SOPS encryption key for GitOps secrets (Production)"

  # Optional: KMS key configuration
  deletion_window_in_days = 30
  enable_key_rotation     = true

  # Required: IAM principal access configuration
  # Root account with emergency administrative access
  enable_iam_principals = [
    "arn:aws:iam::123456789012:root"
  ]

  # Admin principals: Terraform automation and DevOps administration roles
  admin_principals = [
    "arn:aws:iam::123456789012:role/terraform-state-role",
    "arn:aws:iam::123456789012:role/devops-admin-role"
  ]

  # User principals: Flux CD for secret decryption and operator role for encryption
  users_principals = [
    "arn:aws:iam::123456789012:role/service-role/k3s-SSMRole-prod",
    "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Operators_b871fb38d0a5a948",
    "arn:aws:iam::123456789012:role/service-role/app-service-role"
  ]

  # Optional: AWS service principals that require KMS grants
  attachers_principals = [
    "arn:aws:iam::123456789012:role/aws-service-role/s3.amazonaws.com/AWSServiceRoleForS3"
  ]

  # Optional: Custom tags for the KMS key and alias
  tags = {
    Purpose    = "SOPS encryption for GitOps secrets"
    CostCenter = "Infrastructure"
    Owner      = "DevOps Team"
  }

  additional_tags = {
    Compliance = "SOC2"
  }
}

# Output: Individual KMS key attributes
output "key_id" {
  description = "KMS key identifier (UUID)"
  value       = module.kms_sops.outputs.key_id
}

output "key_arn" {
  description = "KMS key Amazon Resource Name (ARN)"
  value       = module.kms_sops.outputs.key_arn
}

output "alias_name" {
  description = "KMS alias name for human-readable reference"
  value       = module.kms_sops.outputs.alias_name
}

output "alias_arn" {
  description = "KMS alias Amazon Resource Name (ARN)"
  value       = module.kms_sops.outputs.alias_arn
}

output "all_outputs" {
  description = "All KMS module outputs as a map"
  value       = module.kms_sops.outputs
}
