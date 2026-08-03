module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = var.vpc_cidr
 

  azs = var.availablity_zone
  private_subnets = var.private_sub
  public_subnets  = var.public_sub

  enable_nat_gateway = true
  

  
}