module "eks" {
  source  = "terraform-aws-modules/eks/aws" // this is defines the path the code defintion of the eks resources
  version = "~> 21.0" // this is the version of the module (the collective related resouces) 

  name               = var.cluster_name //the name that identity the cluster
  kubernetes_version = var.kubernetes_version //the version of kubernetes

  # Optional
  endpoint_public_access = true //not sure what this does

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true  // couldnt tell you what this does either 

  compute_config = { //not sure again
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc.vpc_id  //takes out put of the vpc id from vpc module 
  subnet_ids = module.vpc.private_subnets //takes output of the subet id of he vpc module


}