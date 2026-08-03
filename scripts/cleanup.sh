#!/bin/bash 
set -e

cd "$(dirname "$0")/.."

# 1. Delete ArgoCD apps
kubectl delete -f argocd/app-argo.yaml --ignore-not-found

# 2. Delete app resources
kubectl delete -f kube-objects/cluster-watch.yaml -n my-app --ignore-not-found


# 5. Delete namespaces
kubectl delete namespace argocd --ignore-not-found
kubectl delete namespace ingress-nginx --ignore-not-found
kubectl delete namespace my-watch --ignore-not-found

# 6. Wait for LB and DNS cleanup
echo "Waiting 60s for AWS resources to clean up..."
sleep 60

# 7. Empty ECR repository
aws ecr batch-delete-image \
  --repository-name eks_ecr \
  --image-ids "$(aws ecr list-images --repository-name eks_ecr --query 'imageIds[*]' --output json)" \
  --region eu-west-2 || true

# 8. Destroy infrastructure (handles Helm releases, EKS, VPC, IAM)
cd terraform
terraform destroy -auto-approve