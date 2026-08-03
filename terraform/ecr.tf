module "ecr" {
  source = "terraform-aws-modules/ecr/aws" // this is the blue print, its a written defination of the ecr 

  repository_name = var.c_repo  // this is the name of the ecr contianer were the images will be stored

  # repository_read_write_access_arns = ["arn:aws:iam::460576937871:role/github-actions-role"] //this is the iam role that get gives ecr read access.
  repository_lifecycle_policy = jsonencode({ // this is the versioning policy that keeps 30 images only in the ecr contianer 
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  
}