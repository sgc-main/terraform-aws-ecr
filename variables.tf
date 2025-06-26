variable "replication_id" {
  description = "Either 'source' or 'destination'"
  type        = string
}
variable "peer_account_id" {
  description = "Destination AWS Account ID for replication"
  type        = string
  default     = null
}
variable "repositories" {
  description = "List of ECR repo names"
  type        = list(string)
}
variable "tags" {
  description = "Tags for ECR repo"
  type        = map(string)
  default     = {}
}
variable "lifecycle_policy" {
  description = "Optional lifecycle policy JSON"
  type        = string
  default     = null
}
variable "replication_regions" {
  description = "Regions to replicate to (in-account, optional)"
  type        = list(string)
  default     = []
}
variable "destination_regions" {
  description = "Regions to replicate to in peer account (cross-account, optional)"
  type        = list(string)
  default     = []
}
variable "create_repos" {
  description = "Should create repositories?"
  type        = bool
  default     = true
}

variable "create_registry_policy" {
  description = "Should create registry policy for cross-account replication?"
  type        = bool
  default     = true
}

variable "account_id" {
  description = "This account's AWS account ID"
  type        = string
  default     = null
}