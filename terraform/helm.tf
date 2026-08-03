resource "helm_release" "nginx_ingress" {  //
  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  create_namespace = true
  namespace = "nginx-ingress"
}

resource "helm_release" "argocd" { 
  name       = "argo-helm"
  repository = "https://argoproj.github.io/argo-helm"  
  chart      = "argo-cd"
  create_namespace = true 
  namespace = "argocd" 
  depends_on = [helm_release.nginx_ingress]
  values = [file("${path.module}/../helm-values/argocd.yaml")] 

}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  create_namespace = true
  namespace= "cert-manager"
  values = [file("${path.module}/../helm-values/cert-manager.yaml")]

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.cert_manager_irsa.iam_role_arn
      
    }
    ,
    {
      name = "installCRDs"
      value = "true"
    }

   
]
}


  resource "helm_release" "prometheus" {
  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  create_namespace = true
  namespace = "monitoring"
  values = [file("${path.module}/../helm-values/prometheus.yaml")]

  }
  
  
  resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  create_namespace = true
  namespace = "external-dns"
  values = [file("${path.module}/../helm-values/external-dns.yaml")]
 
 
 set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.external_dns_irsa.iam_role_arn
    }
 
  ]
  }
 