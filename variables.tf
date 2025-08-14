# Core inputs
variable "repositories" {
  description = "List of ECR repository names to create/manage."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to all repositories."
  type        = map(string)
  default     = {}
}


variable "lifecycle_policy" {
  description = "Optional ECR lifecycle policy JSON string. Set null to disable."
  type        = string
  default     = null
}

variable "create_repos" {
  description = "Whether to create/manage repositories in this account/region."
  type        = bool
  default     = true
}

# Replication identity/context
variable "replication_id" {
  description = "Module context: 'source' or 'destination'."
  type        = string
}

# Account IDs
variable "account_id" {
  description = "This (current) AWS account ID."
  type        = string
}

variable "peer_account_ids" {
  description = "List of peer AWS account IDs (sources for destination, or destinations for source)."
  type        = list(string)
  default     = []
}

# Regions
variable "replication_regions" {
  description = "Regions to replicate to within the SAME account (in-account cross-region, optional)."
  type        = list(string)
  default     = []
}

variable "destination_regions" {
  description = "Regions to replicate to in PEER accounts (cross-account)."
  type        = list(string)
  default     = []
}

# Destination registry policy (cross-account)
variable "create_registry_policy" {
  description = "Create registry-level policy to allow cross-account replication (destination only)."
  type        = bool
  default     = true
}
