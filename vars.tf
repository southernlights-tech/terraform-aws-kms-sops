## KMS Key Configuration Variables

variable "environment" {
  description = "Environment name (e.g., 'dev', 'staging', 'prod')"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
}

# FIX #3: Renamed from "name" to "kms_alias_prefix" for improved clarity
variable "kms_alias_prefix" {
  description = "Prefix for KMS alias (e.g., 'sops', 'secrets', 'data')"
  type        = string
  default     = "sops"
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
}

variable "deletion_window_in_days" {
  description = "KMS key deletion window in days (7-30)"
  type        = number
  default     = 30
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days for safety."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation (recommended for production)"
  type        = bool
  default     = true
}

## IAM Principal Configuration Variables

variable "enable_iam_principals" {
  description = "List of IAM principal ARNs with full KMS permissions (typically AWS root account)"
  type        = list(string)
  validation {
    condition     = length(var.enable_iam_principals) > 0
    error_message = "At least one enable_iam_principals value must be specified (e.g., AWS root account)."
  }
}

variable "admin_principals" {
  description = "List of IAM principal ARNs with administrative permissions (key administrators and Terraform roles)"
  type        = list(string)
  validation {
    condition     = length(var.admin_principals) > 0
    error_message = "At least one admin_principals must be specified (e.g., Terraform automation role)."
  }
}

variable "users_principals" {
  description = "List of IAM principal ARNs with user permissions (encrypt, decrypt, and generate data keys)"
  type        = list(string)
  validation {
    condition     = length(var.users_principals) > 0
    error_message = "At least one users_principals must be specified (e.g., application role, Flux CD, operators)."
  }
}

variable "attachers_principals" {
  description = "List of IAM principal ARNs that can create and revoke KMS grants (e.g., AWS services)"
  type        = list(string)
  default     = []
}

## Tags

variable "tags" {
  description = "Tags to apply to the KMS key and alias resources"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}
