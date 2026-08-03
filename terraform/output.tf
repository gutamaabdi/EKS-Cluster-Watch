output "cluster_name" {
  value = module.eks.cluster_name
  description = " cluster name"
}

output "OIDC_Provider" {
  value = module.eks.oidc_provider_arn
  description = "provider arn"

}

output "ECR_repo_URL" {
  value = module.ecr.repository_url
  description = "repo url to push image to "

}

output "cert_manager_arn" {
  value = module.cert_manager_irsa.iam_role_arn
  description = "arn for cert manager"

}

output "external_dns_arn" {
  value = module.external_dns_irsa.iam_role_arn
  description = "this the iam role external dns assumes"

}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = " cluster endpoints"
}