module "ecr_replication" {
  source = "../../"

  repositories           = ["app1", "app2"]
  tags                   = { environment = "dev" }
  create_repos           = true

  account_id             = "111111111111"
  peer_account_ids       = []
  replication_regions    = ["us-west-2", "eu-west-1"]
  destination_regions    = []
  create_registry_policy = false
  replication_id         = "source"
}