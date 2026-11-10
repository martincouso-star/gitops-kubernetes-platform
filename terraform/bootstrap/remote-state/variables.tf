variable "aws_region" {
  description = "Region for the primary state bucket."
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "Region for the cross-region replica of the state bucket."
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete the buckets even when they contain objects. Leave false."
  type        = bool
  default     = false
}
