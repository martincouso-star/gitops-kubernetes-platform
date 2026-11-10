variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs, one per availability zone."
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs, one per availability zone. Used by load balancers."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets. Dev clusters set this to true."
  type        = bool
  default     = false
}

variable "flow_log_retention_in_days" {
  description = "Retention, in days, for the VPC flow log CloudWatch log group."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to VPC resources."
  type        = map(string)
  default     = {}
}
