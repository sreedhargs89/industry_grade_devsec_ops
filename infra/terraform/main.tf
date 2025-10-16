provider "aws" {
  region = var.region
}

module "network" {
  source             = "../../modules/network"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  tags               = var.tags
}

module "nodes" {
  source                 = "../../modules/nodes"
  vpc_id                 = module.network.vpc_id
  subnet_id              = module.network.public_subnet_id
  key_name               = var.key_name
  instance_type          = "t3.medium"
  ami_id                 = var.ami_id
  control_plane_count    = 1
  worker_count           = 2
  tags                   = var.tags
}