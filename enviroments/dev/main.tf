terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "visit-link-tf-state-bucket-dev"
    key            = "tf-infra/terraform.tfstate"
    dynamodb_table = "visit-link-tf-state-locking-dev"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Environment = local.environment
      project     = local.project_name
    }
  }
}

module "tf-state" {
  source = "../../modules/state"

  bucket_name    = "visit-link-tf-state-bucket-dev"
  dynamodb_table = "visit-link-tf-state-locking-dev"
}

module "network" {
  source = "../../modules/network"

  env          = local.environment
  project_name = local.project_name
  az_count     = 2
}

module "repository" {
  source = "../../modules/repository"

  project_name = local.project_name
}

module "db" {
  source = "../../modules/db"

  env                            = local.environment
  project_name                   = local.project_name
  vpc_id                         = module.network.vpc_id
  subnet_ids                     = module.network.private_subnet.ids
  from_subnet_cidr_blocks        = module.network.private_subnet.cidr_blocks
  bastion_host_subnet_cidr_block = module.network.public_subnet.cidr_blocks[0]
  bastion_host_subnet_id         = module.network.public_subnet.ids[0]
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "${local.project_name}-bucket-${local.environment}"
  tags = {
    Environment = "dev"
  }
}

module "service" {
  source = "../../modules/services"

  env                 = local.environment
  project_name        = local.project_name
  vpc_id              = module.network.vpc_id
  alb_subnet_ids      = module.network.public_subnet.ids
  ecs_subnet_ids      = module.network.private_subnet.ids
  service_image_uri   = module.repository.service_image_uri
  admin_web_image_uri = module.repository.admin_web_image_uri
  region              = local.region
  database_url        = module.db.database_url
}
