output "state_bucket_name" {
  description = "Name of the primary Terraform state bucket."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the primary Terraform state bucket."
  value       = aws_s3_bucket.state.arn
}

output "replica_bucket_name" {
  description = "Name of the replica state bucket."
  value       = aws_s3_bucket.replica.id
}

output "kms_key_arn" {
  description = "KMS key ARN used by the primary state bucket. Pass this as kms_key_id in the S3 backend."
  value       = aws_kms_key.state.arn
}

output "region" {
  description = "Region of the primary state bucket."
  value       = var.aws_region
}

output "replica_region" {
  description = "Region of the replica state bucket."
  value       = var.replica_region
}
