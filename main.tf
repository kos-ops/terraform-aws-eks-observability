####################################################################################################
#
# EKS Observability module
#
# Provisions Prometheus, Grafana, and Fluent Bit logging on an EKS cluster.
# See README.md for full documentation.
#
####################################################################################################

####################################################################################################
# Namespaces
####################################################################################################

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
    labels = {
      name = "amazon-cloudwatch"
    }
  }
}
