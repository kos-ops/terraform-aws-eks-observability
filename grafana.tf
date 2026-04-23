locals {
  grafana_default_values = {
    admin = {
      existingSecret = var.grafana_admin_secret_name
      userKey        = var.grafana_admin_user_key
      passwordKey    = var.grafana_admin_password_key
    }

    service = {
      type = "ClusterIP"
      port = 3000
    }

    persistence = {
      enabled      = var.grafana_persistence_enabled
      size         = var.grafana_storage_size
      storageClass = var.grafana_storage_class
    }

    resources = {
      requests = {
        cpu    = "100m"
        memory = "256Mi"
      }
      limits = {
        cpu    = "200m"
        memory = "512Mi"
      }
    }

    datasources = {
      "datasources.yaml" = {
        apiVersion = 1
        datasources = [
          {
            name      = "Prometheus"
            type      = "prometheus"
            url       = "http://prometheus-server.monitoring.svc.cluster.local"
            access    = "proxy"
            isDefault = true
          }
        ]
      }
    }
  }
}

####################################################################################################
# Grafana (helm)
####################################################################################################

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  atomic     = var.grafana_atomic
  timeout    = var.grafana_timeout

  values = [
    yamlencode(local.grafana_default_values),
    yamlencode(var.grafana_values_override)
  ]

  depends_on = [helm_release.prometheus]
}

####################################################################################################
# Grafana HTTPRoute → Gateway Api
####################################################################################################

resource "kubectl_manifest" "grafana_httproute" {
  count = var.create_grafana_httproute ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }

    spec = {
      parentRefs = [{
        name        = var.grafana_gateway_name
        namespace   = var.grafana_gateway_namespace
        sectionName = var.grafana_gateway_section_name
      }]
      hostnames = [var.grafana_hostname]
      rules = [{
        backendRefs = [{
          name = "grafana"
          port = 3000
        }]
      }]
    }
  })

  depends_on = [helm_release.grafana]
}
