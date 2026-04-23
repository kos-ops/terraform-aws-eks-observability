####################################################################################################
# Configmap fluent-bit-cluster-info
####################################################################################################

resource "kubernetes_config_map" "fluent_bit_cluster_info" {
  metadata {
    name      = "fluent-bit-cluster-info"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  data = {
    "cluster.name" = var.cluster_name
    "http.server"  = var.fluent_bit_http_server
    "http.port"    = var.fluent_bit_http_port
    "read.head"    = var.fluent_bit_read_head
    "read.tail"    = var.fluent_bit_read_tail
    "logs.region"  = local.region
  }
}

####################################################################################################
# IAM role for the fluent-bit service account
####################################################################################################

module "fluent_bit_role" {
  source = "../iam"

  role_name                   = var.fluent_bit_role_name
  external_assume_role_policy = data.aws_iam_policy_document.fluent_bit_allow_assume_role.json
  create_role_policy          = true
  role_policy                 = data.aws_iam_policy_document.fluent_bit_policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "fluent_bit_allow_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_id}:sub"

      values = [
        "system:serviceaccount:${kubernetes_namespace.amazon_cloudwatch.metadata[0].name}:fluent-bit"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_id}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "fluent_bit_policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:GetParameter"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"]
  }
}

####################################################################################################
# Service account fluent-bit
####################################################################################################

resource "kubernetes_service_account" "fluent_bit_service_account" {
  automount_service_account_token = true

  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.fluent_bit_role.role_arn
    }
  }

  depends_on = [
    module.fluent_bit_role
  ]
}

####################################################################################################
# Cluster role fluent-bit-role with cluster role binding
####################################################################################################

resource "kubernetes_cluster_role" "fluent_bit_role" {
  metadata {
    name = "fluent-bit-role"
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/logs", "nodes", "nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "fluent_bit_cluster_role_binding" {
  metadata {
    name = "fluent-bit-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fluent-bit-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "fluent-bit"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
}

####################################################################################################
# ConfigMap fluent-bit-config
####################################################################################################

resource "kubernetes_config_map" "fluent_bit_config" {
  metadata {
    name      = "fluent-bit-config"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    labels = {
      k8s-app = "fluent-bit"
    }
  }

  data = var.fluent_bit_config_files
}

####################################################################################################
# DaemonSet fluent-bit
####################################################################################################

resource "kubernetes_daemonset" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    labels = {
      k8s-app                         = "fluent-bit"
      version                         = "v1"
      "kubernetes.io/cluster-service" = "true"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "fluent-bit"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app                         = "fluent-bit"
          version                         = "v1"
          "kubernetes.io/cluster-service" = "true"
        }
      }

      spec {
        container {
          name              = "fluent-bit"
          image             = "public.ecr.aws/aws-observability/aws-for-fluent-bit:${var.aws_for_fluent_bit_version}"
          image_pull_policy = var.fluent_bit_image_pull_policy

          resources {
            limits = {
              cpu    = var.fluent_bit_resources_limits_cpu
              memory = var.fluent_bit_resources_limits_memory
            }
            requests = {
              cpu    = var.fluent_bit_resources_requests_cpu
              memory = var.fluent_bit_resources_requests_memory
            }
          }

          env {
            name = "AWS_REGION"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "logs.region"
              }
            }
          }

          env {
            name = "CLUSTER_NAME"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "cluster.name"
              }
            }
          }

          env {
            name = "HTTP_SERVER"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.server"
              }
            }
          }

          env {
            name = "HTTP_PORT"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.port"
              }
            }
          }

          env {
            name = "READ_FROM_HEAD"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.head"
              }
            }
          }

          env {
            name = "READ_FROM_TAIL"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.tail"
              }
            }
          }

          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          env {
            name  = "CI_VERSION"
            value = var.fluent_bit_ci_version
          }

          volume_mount {
            name       = "fluentbitstate"
            mount_path = "/var/fluent-bit/state"
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
            read_only  = true
          }

          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          volume_mount {
            name       = "fluent-bit-config"
            mount_path = "/fluent-bit/etc/"
          }

          volume_mount {
            name       = "runlogjournal"
            mount_path = "/run/log/journal"
            read_only  = true
          }

          volume_mount {
            name       = "dmesg"
            mount_path = "/var/log/dmesg"
            read_only  = true
          }
        }

        termination_grace_period_seconds = 10
        host_network                     = "true"
        dns_policy                       = "ClusterFirstWithHostNet"

        volume {
          name = "fluentbitstate"
          host_path {
            path = "/var/fluent-bit/state"
          }
        }

        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volume {
          name = "fluent-bit-config"
          config_map {
            name = "fluent-bit-config"
          }
        }

        volume {
          name = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }

        volume {
          name = "dmesg"
          host_path {
            path = "/var/log/dmesg"
          }
        }

        service_account_name = "fluent-bit"

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}
