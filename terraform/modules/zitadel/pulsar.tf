

resource "kubernetes_namespace" "pulsar" {
  metadata {
    name = "pulsar"
  }
}

resource "helm_release" "pulsar" {
  depends_on = [kubernetes_namespace.pulsar]
  name       = "pulsar"
  repository = "https://pulsar.apache.org/charts"
  chart      = "pulsar"
  version    = "3.3.1"
  namespace  = "pulsar"
  timeout    = 900 # seconds

  set {
    name  = "volumes.persistence"
    value = "true"
  }
  # to ensure pods of the same component can run on different nodes
  set {
    name  = "affinity.anti_affinity"
    value = "true"
  }
  set { 
    name = "components.zookeeper" 
    value = "true"
  }
  set { 
    name = "components.bookkeeper" 
    value = "true"
  }
  set { 
    name = "components.autorecovery" 
    value = "true"
  }
  set { 
    name = "components.broker" 
    value = "true"
  }
  set { 
    name = "components.functions" 
    value = "true"
  }
  set { 
    name = "components.proxy" 
    value = "true"
  }
  set { 
    name = "components.toolset" 
    value = "true"
  }
  set { 
    name = "components.pulsar_manager" 
    value = "true"
  }
  set { 
    name = "monitoring.prometheus" 
    value = "true"
  }
  set { 
    name = "monitoring.grafana" 
    value = "true"
  }

}