terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Locals block to build the dynamic destinations map
locals {
  replication_destinations = flatten([
    length(var.replication_regions) > 0 && var.account_id != null ? [
      for region in var.replication_regions : {
        region      = region
        registry_id = var.account_id
      }
    ] : [],
    length(var.destination_regions) > 0 && var.peer_account_id != null ? [
      for region in var.destination_regions : {
        region      = region
        registry_id = var.peer_account_id
      }
    ] : []
  ])
}

resource "aws_ecr_repository" "this" {
  for_each = var.create_repos ? toset(var.repositories) : []
  name     = each.key
  tags     = var.tags
  provider = aws
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = var.create_repos && var.lifecycle_policy != null ? aws_ecr_repository.this : {}
  repository = each.value.name
  policy     = var.lifecycle_policy
  provider   = aws
}

resource "aws_ecr_repository_policy" "replication_policy" {
  for_each = var.replication_id == "destination" && var.create_repos ? aws_ecr_repository.this : {}
  repository = each.value.name
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid      = "AllowReplication"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.peer_account_id}:root"
        }
        Action = [
          "ecr:ReplicateImage"
        ]
      }
    ]
  })
  provider = aws
}

resource "aws_ecr_registry_policy" "allow_replication" {
  for_each = var.replication_id == "destination" && var.create_registry_policy ? {"registrypolicy" = true} : {}
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid: "AllowReplicationFromSource",
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${var.peer_account_id}:root"
        },
        Action: [
           "ecr:CreateRepository",
           "ecr:ReplicateImage"
        ]
        Resource: "arn:aws:ecr:*:${var.account_id}:repository/*"
      }
    ]
  })
  provider = aws
}

resource "aws_ecr_replication_configuration" "this" {
  for_each = length(local.replication_destinations) == 0 || var.replication_id == "destination" ? {} : { "replication" = local.replication_destinations }
  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = each.value
        content {
          region      = destination.value.region
          registry_id = destination.value.registry_id
        }
      }
    }
  }
  provider = aws
}