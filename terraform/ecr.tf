module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.c_repo

  # repository_read_write_access_arns = ["arn:aws:iam::460576937871:role/github-actions-role"]
  repository_lifecycle_policy = jsonencode({ // this is the versioning policy that keeps 30 images only in the Ecr contianer
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