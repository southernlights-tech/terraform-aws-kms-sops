# Minimal example: KMS module for development environment
# This demonstrates the simplest way to use the module with only required inputs

module "kms_sops" {
  source = "../.."

  environment             = "dev"
  kms_alias_prefix        = "sops"
  description             = "SOPS encryption key for GitOps secrets (Development)"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  # AWS account root for emergency access and full administration
  enable_iam_principals = ["arn:aws:iam::123456789012:root"]

  # Terraform automation role for key management and rotation
  admin_principals = [
    "arn:aws:iam::123456789012:role/terraform-state-role"
  ]

  # Flux CD and operators for SOPS encryption and decryption operations
  users_principals = [
    "arn:aws:iam::123456789012:role/service-role/k3s-SSMRole-dev",
    "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Operators_b871fb38d0a5a948"
  ]
}

# Outputs for use in other modules or local reference
output "kms_key_id" {
  description = "KMS key identifier"
  value       = module.kms_sops.outputs.key_id
}

output "kms_key_arn" {
  description = "KMS key Amazon Resource Name"
  value       = module.kms_sops.outputs.key_arn
}

output "kms_alias_name" {
  description = "KMS alias name for human-readable reference"
  value       = module.kms_sops.outputs.alias_name
}
