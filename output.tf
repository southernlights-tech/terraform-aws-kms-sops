# Aggregated output following southernlights-tech module convention
# Outputs consumed by other modules via terraform_remote_state data source
output "outputs" {
  description = "Map of KMS key outputs for consumption by dependent modules"
  value = {
    key_id               = aws_kms_key.kms_key.key_id
    key_arn              = aws_kms_key.kms_key.arn
    alias_name           = aws_kms_alias.kms_alias.name
    alias_arn            = aws_kms_alias.kms_alias.arn
    alias_target_key_arn = aws_kms_alias.kms_alias.target_key_arn
    key_is_enabled       = aws_kms_key.kms_key.is_enabled
  }
}
