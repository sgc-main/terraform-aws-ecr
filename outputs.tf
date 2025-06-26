output "repository_urls" {
  description = "Map of each created ECR repository name to its URL."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of each created ECR repository name to its ARN."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}

output "lifecycle_policy_repos" {
  description = "List of repositories with a lifecycle policy attached."
  value = [for policy in aws_ecr_lifecycle_policy.this : policy.repository]
}

output "replication_configuration" {
  description = "Details of the replication configuration, if created."
  value = aws_ecr_replication_configuration.this
}

output "registry_policy" {
  description = "The registry policy applied to this ECR registry (if any)."
  value = try(aws_ecr_registry_policy.allow_replication[0].policy, null)
}