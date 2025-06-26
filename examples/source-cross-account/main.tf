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