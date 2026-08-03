terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.52.0"
     
  }
  helm = {
      source = "hashicorp/helm"
      version = "~> 3.2.0"
 
    }
    
  }
  backend "s3" {
  bucket         = "gutama-terraform-state-eu-west-2"
  key            = "cluster-watch/terraform.tfstate"
  region         = "eu-west-2"
  dynamodb_table = "s3-lock"
}
}
  provider "aws" {
  region = var.aws_region
   default_tags {
    tags = local.common_tags
}
  }

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode( module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}



