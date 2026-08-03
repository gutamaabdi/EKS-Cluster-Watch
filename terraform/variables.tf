variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "EKS_cluster"
}
variable "aws_region" {
  type        = string
  description = "the aws region"
  default     = "eu-west-2" 
}

variable "private_sub" {
  type        = list(string)
  description = "this is the private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24" , "10.0.3.0/24"]
}

variable "public_sub" {
  type        = list(string)
  description = "this is the public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "availablity_zone" {
  type        = list(string)
  description = "this is the availablity zones"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "vpc_cidr" {
  type        = string
  description = "this is the vpc cidr"
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  type        = string
  description = "kubernetes version"
  default     = "1.33"
}

variable "environment" {
  type        = string
  description = "environment"
  default     = "dev"
}


variable "c_repo" {
  type        = string
  description = "ECR name"
  default     = "eks_ecr"
}

variable "domain" {
  type = string
  description = "Root domain managed in Route 53"
  default = "gutama-devops-portfolio.link"
}

