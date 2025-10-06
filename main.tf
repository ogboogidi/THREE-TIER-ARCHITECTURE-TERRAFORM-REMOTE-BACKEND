provider "aws" {
  region = "us-east-2"
}


module "vpc" {
  source = "./modules/vpc"
  tags = local.apci_tags
  vpc_cidr_block = var.vpc_cidr_block
  frontend_subnet_cidr_block = var.frontend_subnet_cidr_block
  availability_zone = var.availability_zone
  apci_backend_cidr_block = var.apci_backend_cidr_block
  database_cidr_block = var.database_cidr_block
}