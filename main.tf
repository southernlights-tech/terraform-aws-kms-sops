# KMS Key for SOPS encryption and secure secret management
resource "aws_kms_key" "kms_key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  # Standard KMS configuration
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false

  # Key policy with fine-grained RBAC (4 statements for flexibility)
  # FIX #1: Use concat() instead of ternary with null to avoid AWS JSON policy errors
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Statement 1: Enable IAM User Permissions (root account with full admin access)
        {
          Sid    = "Enable IAM User Permissions"
          Effect = "Allow"
          Principal = {
            AWS = var.enable_iam_principals
          }
          Action   = "kms:*"
          Resource = "*"
        },

        # Statement 2: Allow Key Administrators (Terraform automation and DevOps roles)
        {
          Sid    = "Allow access for Key Administrators"
          Effect = "Allow"
          Principal = {
            AWS = var.admin_principals
          }
          Action = [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion",
            "kms:RotateKeyOnDemand"
          ]
          Resource = "*"
        },

        # Statement 3: Allow use of the key (encryption and decryption operations)
        {
          Sid    = "Allow use of the key"
          Effect = "Allow"
          Principal = {
            AWS = var.users_principals
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ],
      # Statement 4: Allow attachment of persistent resources (AWS service grants)
      # Only included if attachers_principals list is not empty
      length(var.attachers_principals) > 0 ? [
        {
          Sid    = "Allow attachment of persistent resources"
          Effect = "Allow"
          Principal = {
            AWS = var.attachers_principals
          }
          Action = [
            "kms:CreateGrant",
            "kms:ListGrants",
            "kms:RevokeGrant"
          ]
          Resource = "*"
          Condition = {
            Bool = {
              "kms:GrantIsForAWSResource" = "true"
            }
          }
        }
      ] : []
    )
  })

  tags = merge(
    {
      Name        = "${var.kms_alias_prefix}-${var.environment}"
      Environment = var.environment
      Component   = "Security"
      ManagedBy   = "Terraform"
    },
    var.tags,
    var.additional_tags
  )
}

# KMS Alias for human-readable key reference
# FIX #2: Use dynamic variables instead of hardcoded alias name for multi-environment reusability
# Pattern: alias/{kms_alias_prefix}-{environment}
# Examples: alias/sops-dev, alias/sops-staging, alias/sops-prod, alias/secrets-prod
resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.kms_alias_prefix}-${var.environment}"
  target_key_id = aws_kms_key.kms_key.key_id
}
