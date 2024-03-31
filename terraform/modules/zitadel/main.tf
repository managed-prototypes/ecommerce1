terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.36.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_pat
}

data "digitalocean_kubernetes_cluster" "primary" {
  name = var.cluster_name
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.primary.endpoint
  token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate)
  token                  = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.primary.endpoint
    token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
}

# Reference: https://github.com/zitadel/zitadel-charts/tree/main/examples/1-postgres-insecure
# 
# When done:
# Open https://ecommerce1-auth.prototyping.quest
# Username: zitadel-admin@zitadel.ecommerce1-auth.prototyping.quest
# Password: Password1!


resource "helm_release" "postgres" {
  name       = "db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.10.0"
  timeout    = 900 # seconds
  values = [
    "${file("${path.module}/postgres-values.yaml")}"
  ]
}

resource "helm_release" "zitadel" {
  depends_on = [helm_release.postgres]
  name       = "zitadel-service"
  repository = "https://charts.zitadel.com"
  chart      = "zitadel"
  version    = "7.11.0"
  timeout    = 900 # seconds
  values = [
    "${file("${path.module}/zitadel-values.yaml")}"
  ]
}