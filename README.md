# Cluster Watch

## Overview

A production-style Kubernetes platform on Amazon EKS, built with Terraform, GitOps (ArgoCD), and full CI/CD automation. The platform hosts a Python/Flask monitoring dashboard that queries the Kubernetes API to report the live health of every major component in the cluster.

This project was built to demonstrate platform engineering, not just application deployment — the goal was a reusable, secure, observable foundation that any application could run on, with security and automation baked into every layer.

## Architecture
<img width="1741" height="1165" alt="architecture" src="https://github.com/user-attachments/assets/9c3118ba-f4a5-4209-b57e-5755cabe66dc" />




- **VPC**: Multi-AZ (3 AZs), public/private subnet segmentation
- **Worker nodes**: Private subnets, no public IPs
- **Ingress**: NGINX Ingress Controller behind an internet-facing NLB
- **TLS**: cert-manager + Let's Encrypt, DNS-01 validation via Route 53
- **DNS**: external-dns automatically syncs Ingress hostnames to Route 53
- **GitOps**: ArgoCD continuously reconciles cluster state against this Git repo
- **Monitoring**: Prometheus + Grafana

## Tools Used

- **Terraform** — Infrastructure as Code (VPC, EKS, ECR, IAM, IRSA), remote state in S3 with DynamoDB locking
- **Helm** — Kubernetes package manager for all platform tooling
- **NGINX Ingress Controller** — traffic routing
- **cert-manager** — automated TLS certificate provisioning
- **external-dns** — automatic Route 53 record management
- **ArgoCD** — GitOps continuous deployment
- **Prometheus + Grafana** — metrics collection and visualisation
- **GitHub Actions** — CI/CD (two separate pipelines, OIDC authentication)
- **Amazon ECR** — container image registry
- **Python/Flask** — the Cluster Watch monitoring app
- **Checkov + tfsec** — Terraform security scanning
- **Grype** — container image vulnerability scanning
- **pre-commit** — local validation before code reaches the pipeline

## The App

A Flask app that queries the Kubernetes API from inside the cluster to report live status (Healthy / Degraded / Unknown) for NGINX, cert-manager, external-dns, ArgoCD, Prometheus, and Grafana.

- RBAC-scoped ServiceAccount — `get` and `list` only on Deployments, nothing else
- `/health` endpoint for liveness/readiness probes
- HPA configured to scale 1–3 replicas on CPU utilisation

## CI/CD

Two independent pipelines, both authenticating to AWS via **OIDC federation** — no static credentials anywhere.

**App pipeline** (triggers on changes to `app/`)
- Builds the Docker image
- Scans it with Grype
- Pushes to ECR, tagged with the run number
- Updates the image tag in the Kubernetes manifest and commits back to Git
- ArgoCD detects the change and rolls out the new version automatically

**Infra pipeline** (triggers on changes to `terraform/`)
- Pull requests → `terraform plan`, Checkov, tfsec
- Push to `main` → `plan` job, then `apply` job (behind a manual approval gate)

## Security

- OIDC authentication for both CI/CD and in-cluster AWS access (IRSA) — no static credentials
- Non-root containers, dropped Linux capabilities, seccomp profiles
- NetworkPolicy restricting inbound traffic to only the NGINX Ingress Controller namespace
- EKS secrets encryption at rest (KMS-backed `encryption_config`)
- Least-privilege RBAC on the app's ServiceAccount
- Checkov and tfsec scanning on every Terraform change; pre-commit hooks catch formatting and secret issues before they reach the pipeline

**Known, accepted trade-offs** (documented deliberately, not oversights):
- EKS API endpoint is public — required for GitHub Actions and local `kubectl` access without a bastion/VPN; access is still gated by IAM authentication and cluster access entries, not open to the internet
- Worker node security group allows unrestricted egress — needed for ECR/AWS API access; in production this would be scoped to specific AWS service CIDRs
- Control plane logging and VPC Flow Logs are not enabled — deferred due to added CloudWatch cost for a portfolio project; the value of enabling them (auditability of API access and network traffic) is understood

## Real Challenges Solved

- **OIDC auth failing with a correct-looking config** — GitHub had introduced an immutable subject claim format for newer repos, adding numeric IDs to the `sub` claim. The trust policy needed to match the new format exactly.
- **ArgoCD stuck in a crash loop** — a bad manifest crashed the controller; fixing it didn't help because the controller kept restarting into the same cached broken state before it could pull the fix. Fixed by deleting and re-bootstrapping the Application object.
- **A Helm chart silently ignoring correct values** — ArgoCD's Ingress kept rendering a placeholder domain despite the right values being received. The chart had two separate hostname fields, and an empty one was overriding the populated one.
- **A tangled partial-destroy state** — a lost connection mid-`destroy` orphaned a state lock and left the cluster's KMS key mid-deletion while the cluster itself was still active, blocking normal teardown. Resolved by manually deleting the EKS cluster via the AWS CLI before retrying `destroy`.

## Bootstrapping

A handful of one-time manual steps are required to break circular dependencies inherent to any fully automated system:

1. **S3 backend** (bucket + DynamoDB table) must exist before Terraform can use it as a backend — created manually once.
2. **GitHub OIDC IAM role** must exist before the CI/CD pipeline can authenticate to run `terraform apply` — created manually once, since the pipeline that would normally create it needs it to already exist.
3. **ArgoCD Application object** must be applied once via `kubectl` after the cluster and ArgoCD itself exist — this tells the already-running ArgoCD what to watch. After this, all future deployments are fully automated.
4. **ClusterIssuer** must be applied once per cluster — it does not survive cluster destruction/recreation, unlike everything managed through the GitOps loop.

## Cleanup

```bash
bash scripts/cleanup.sh
```

Deletes Kubernetes-managed resources (which own external AWS resources like load balancers, invisible to Terraform state), empties ECR, then runs `terraform destroy`.
