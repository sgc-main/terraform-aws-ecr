
# Terraform AWS ECR Replication Module

This Terraform module manages AWS Elastic Container Registry (ECR) repositories with advanced support for **cross-region** and **cross-account replication**, including repository lifecycle policies and both repository- and registry-level permissions.

## Features

- Creates one or more ECR repositories with tags.
- Applies optional ECR lifecycle policies.
- Manages repository policies required for cross-account replication.
- Optionally manages registry-level policy for cross-account replication.
- Dynamically generates replication configuration for:
  - In-account (cross-region) replication.
  - Cross-account (to peer AWS account) replication.
- All destinations are automatically calculated from variables—no need to manually enumerate every destination.

## References

- [AWS ECR Cross-Region and Cross-Account Replication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/replication.html)
- [Terraform AWS Provider: ECR Repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)

<!-- BEGIN_TF_DOCS -->
## Examples

### Source Account: Cross-Account Replication

```hcl
module "ecr_replication" {
  source = "./examples/source-cross-account"
}
```

main.tf
```hcl
module "ecr_replication" {
  source = "../../"

  repositories           = ["app1", "app2"]
  tags                   = { environment = "dev" }
  create_repos           = true

  lifecycle_policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images after 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

  account_id             = "111111111111"
  peer_account_id        = "222222222222"
  replication_regions    = []
  destination_regions    = ["us-west-2", "eu-west-1"]
  create_registry_policy = false
  replication_id         = "source"
}
```  


### Destination Account: Cross-Account Replication Setup

```hcl
module "ecr_replication" {
  source = "./examples/destination-cross-account"
}
```

main.tf
```hcl
module "ecr_replication" {
  source = "../../"

  repositories           = ["app1", "app2"]
  tags                   = { environment = "dev" }
  create_repos           = true
  lifecycle_policy       = null
  account_id             = "222222222222"
  peer_account_id        = "111111111111"
  replication_regions    = []
  destination_regions    = []
  create_registry_policy = true
  replication_id         = "destination"
}
```

### In-Account Cross-Region Replication

```hcl
module "ecr_replication" {
  source = "./examples/in-account-cross-region"
}
```

main.tf
```hcl
module "ecr_replication" {
  source = "../../"

  repositories           = ["app1", "app2"]
  tags                   = { environment = "dev" }
  create_repos           = true

  account_id             = "111111111111"
  peer_account_id        = null
  replication_regions    = ["us-west-2", "eu-west-1"]
  destination_regions    = []
  create_registry_policy = false
  replication_id         = "source"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_registry_policy.allow_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
| [aws_ecr_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | This account's AWS account ID | `string` | `null` |
| <a name="input_create_registry_policy"></a> [create\_registry\_policy](#input\_create\_registry\_policy) | Should create registry policy for cross-account replication? | `bool` | `true` |
| <a name="input_create_repos"></a> [create\_repos](#input\_create\_repos) | Should create repositories? | `bool` | `true` |
| <a name="input_destination_regions"></a> [destination\_regions](#input\_destination\_regions) | Regions to replicate to in peer account (cross-account, optional) | `list(string)` | `[]` |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | Optional lifecycle policy JSON | `string` | `null` |
| <a name="input_peer_account_id"></a> [peer\_account\_id](#input\_peer\_account\_id) | Destination AWS Account ID for replication | `string` | `null` |
| <a name="input_replication_id"></a> [replication\_id](#input\_replication\_id) | Either 'source' or 'destination' | `string` | n/a |
| <a name="input_replication_regions"></a> [replication\_regions](#input\_replication\_regions) | Regions to replicate to (in-account, optional) | `list(string)` | `[]` |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of ECR repo names | `list(string)` | n/a |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for ECR repo | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lifecycle_policy_repos"></a> [lifecycle\_policy\_repos](#output\_lifecycle\_policy\_repos) | List of repositories with a lifecycle policy attached. |
| <a name="output_registry_policy"></a> [registry\_policy](#output\_registry\_policy) | The registry policy applied to this ECR registry (if any). |
| <a name="output_replication_configuration"></a> [replication\_configuration](#output\_replication\_configuration) | Details of the replication configuration, if created. |
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | Map of each created ECR repository name to its ARN. |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of each created ECR repository name to its URL. |
<!-- END_TF_DOCS -->