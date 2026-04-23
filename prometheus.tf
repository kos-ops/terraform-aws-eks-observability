locals {
  prometheus_default_values = {
    server = {
      retention = var.prometheus_retention
      
      serviceAccount = {
        create = true
        name   = "prometheus-server"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.prometheus_role.role_arn
        }
      }

      persistentVolume = {
        enabled      = var.prometheus_persistence_enabled
        size         = var.prometheus_storage_size
        storageClass = var.prometheus_storage_class
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }

    "kube-state-metrics" = {
      enabled = var.prometheus_kube_state_metrics_enabled
    }

    alertmanager = {
      enabled = var.prometheus_alertmanager_enabled
    }

    "prometheus-node-exporter" = {
      enabled = var.prometheus_node_exporter_enabled
    }

    "prometheus-pushgateway" = {
      enabled = var.prometheus_pushgateway_enabled
    }
  }
}

####################################################################################################
# IAM role for Prometheus (EBS volumes for TSDB)
####################################################################################################

module "prometheus_role" {
  source = "../iam"

  role_name                   = var.prometheus_role_name
  external_assume_role_policy = data.aws_iam_policy_document.prometheus_allow_assume_role.json
  create_role_policy          = true
  role_policy                 = data.aws_iam_policy_document.prometheus_policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "prometheus_allow_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_id}:sub"
      values   = ["system:serviceaccount:monitoring:prometheus-server"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_id}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "prometheus_policy" {
  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeSnapshots",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

##################################################
# Prometheus server (helm)
##################################################

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  atomic     = var.prometheus_atomic
  timeout    = var.prometheus_timeout

  values = [
  yamlencode(local.prometheus_default_values),
  yamlencode(var.prometheus_values_override)
]

  depends_on = [module.prometheus_role]
}
