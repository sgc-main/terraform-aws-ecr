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