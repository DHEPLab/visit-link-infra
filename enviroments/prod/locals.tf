locals {
  project_name   = "visit-link"
  environment    = "prod"
  region         = "us-east-1"
  backend_bucket = "${local.project_name}-tf-state-bucket-${local.environment}"
  backend_lock   = "${local.project_name}-tf-state-locking-${local.environment}"
}