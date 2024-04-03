resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  depends_on = [kubernetes_namespace.traefik]
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "26.0.0"
  namespace  = "traefik"
  timeout    = 900 # seconds
}

resource "kubectl_manifest" "ingress_others" {
  depends_on = [helm_release.traefik]
  yaml_body  = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: applications-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    cert-manager.io/cluster-issuer: clusterissuer
spec:
  rules:
    - host: ${local.auth_fqdn}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: zitadel-service
                port:
                  number: 8080
  tls:
    - secretName: zitadel-cert
      hosts:
        - ${local.auth_fqdn}
YAML
}

data "kubernetes_service_v1" "traefik" {
  depends_on = [helm_release.traefik]
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }
}

resource "digitalocean_record" "zitadel" {
  domain = var.base_domain
  type   = "A"
  name   = var.auth_subdomain
  value  = data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip
}
