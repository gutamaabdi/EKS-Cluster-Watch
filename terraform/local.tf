locals {
  common_tags = {
    Environment = var.environment
    Project     = var.cluster_name
    ManagedBy   = "terraform"
  }


}# trigger infra pipeline test
