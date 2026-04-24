####################################################################################################
# General
####################################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the resources"
  type        = map(string)
  default     = {}
}

####################################################################################################
# Prometheus
####################################################################################################

variable "prometheus_role_name" {
  description = "IAM role name for Prometheus"
  type        = string
  default     = "prometheus-role"
}

variable "prometheus_chart_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "29.2.1"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "PV size for Prometheus TSDB"
  type        = string
  default     = "50Gi"
}

variable "prometheus_atomic" {
  description = "If true, Helm rolls back on failed deploy"
  type        = bool
  default     = true
}

variable "prometheus_timeout" {
  description = "Helm release timeout for Prometheus (seconds)"
  type        = number
  default     = 600
}

variable "prometheus_values_override" {
  description = "Override values for Prometheus Helm chart (use yamlencode-compatible map)"
  type        = any
  default     = {}
}

variable "prometheus_persistence_enabled" {
  description = "Enable persistent storage for Prometheus TSDB"
  type        = bool
  default     = true
}

variable "prometheus_storage_class" {
  description = "StorageClass for Prometheus persistent volume. Empty string uses the cluster default StorageClass."
  type        = string
  default     = ""
}

variable "prometheus_kube_state_metrics_enabled" {
  description = "Enable kube-state-metrics subchart"
  type        = bool
  default     = true
}

variable "prometheus_alertmanager_enabled" {
  description = "Enable Alertmanager subchart"
  type        = bool
  default     = false
}

variable "prometheus_node_exporter_enabled" {
  description = "Enable prometheus-node-exporter subchart"
  type        = bool
  default     = true
}

variable "prometheus_pushgateway_enabled" {
  description = "Enable prometheus-pushgateway subchart"
  type        = bool
  default     = false
}

####################################################################################################
# Grafana
####################################################################################################

variable "grafana_chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "10.5.15"
}
variable "grafana_atomic" {
  description = "If true, Helm rolls back on failed deploy"
  type        = bool
  default     = true
}

variable "grafana_timeout" {
  description = "Helm release timeout for Grafana (seconds)"
  type        = number
  default     = 600
}

variable "grafana_values_override" {
  description = "Override values for Grafana Helm chart (use yamlencode-compatible map)"
  type        = any
  default     = {}
}

variable "grafana_admin_secret_name" {
  description = "Name of the Kubernetes secret containing Grafana admin credentials"
  type        = string
  default     = "grafana-admin"
}

variable "grafana_admin_user_key" {
  description = "Key in the Kubernetes secret that holds the Grafana admin username"
  type        = string
  default     = "admin-user"
}

variable "grafana_admin_password_key" {
  description = "Key in the Kubernetes secret that holds the Grafana admin password"
  type        = string
  default     = "admin-password"
}

variable "grafana_persistence_enabled" {
  description = "Enable persistent storage for Grafana"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "PV size for Grafana data"
  type        = string
  default     = "10Gi"
}

variable "grafana_storage_class" {
  description = "StorageClass for Grafana persistent volume. Empty string uses the cluster default StorageClass."
  type        = string
  default     = ""
}

variable "create_grafana_httproute" {
  description = "Whether to create an HTTPRoute resource for Grafana (Gateway API). Disable if using Ingress or other routing."
  type        = bool
  default     = false
}

variable "grafana_gateway_name" {
  description = "Name of the Gateway resource for Grafana HTTPRoute. This is an example value; update it to match your cluster's Gateway configuration if create_grafana_httproute is true."
  type        = string
  default     = "calico-gateway"
}

variable "grafana_gateway_namespace" {
  description = "Namespace of the Gateway resource for Grafana HTTPRoute. This is an example value; update it to match your cluster's Gateway configuration if create_grafana_httproute is true."
  type        = string
  default     = "ingress-gateway"
}

variable "grafana_gateway_section_name" {
  description = "Section name on the Gateway for Grafana HTTPRoute. This is an example value; update it to match your cluster's Gateway configuration if create_grafana_httproute is true."
  type        = string
  default     = "https"
}

variable "grafana_hostname" {
  description = "Public hostname for Grafana (e.g. grafana.example.com). This is used in the Grafana configuration to set the root URL and is required if create_grafana_httproute is true."
  type        = string
  default     = "grafana.example.com"
}

####################################################################################################
# Fluent Bit
####################################################################################################

variable "fluent_bit_role_name" {
  description = "IAM role name for Fluent Bit"
  type        = string
  default     = "fluent-bit-role"
}

variable "fluent_bit_config_files" {
  description = "Map of filename to content for Fluent Bit ConfigMap (e.g. fluent-bit.conf, application-log.conf, ...). If null, uses built-in defaults."
  type        = map(string)
  default     = null
}

variable "aws_for_fluent_bit_version" {
  description = "Version of the AWS for Fluent Bit image to use"
  type        = string
  default     = "3.2.4"
}

variable "fluent_bit_http_server" {
  description = "Enable HTTP server for Fluent Bit metrics (On/Off)"
  type        = string
  default     = "On"
}

variable "fluent_bit_http_port" {
  description = "HTTP server port for Fluent Bit metrics"
  type        = string
  default     = "2020"
}

variable "fluent_bit_read_head" {
  description = "Read log files from head on startup (On/Off)"
  type        = string
  default     = "Off"
}

variable "fluent_bit_read_tail" {
  description = "Read log files from tail on startup (On/Off)"
  type        = string
  default     = "On"
}

variable "fluent_bit_image_pull_policy" {
  description = "Image pull policy for Fluent Bit container"
  type        = string
  default     = "Always"
}

variable "fluent_bit_ci_version" {
  description = "CI_VERSION env var value for Fluent Bit"
  type        = string
  default     = "k8s/1.3.41"
}

variable "fluent_bit_resources_limits_cpu" {
  description = "CPU limit for Fluent Bit container"
  type        = string
  default     = "100m"
}

variable "fluent_bit_resources_limits_memory" {
  description = "Memory limit for Fluent Bit container"
  type        = string
  default     = "200Mi"
}

variable "fluent_bit_resources_requests_cpu" {
  description = "CPU request for Fluent Bit container"
  type        = string
  default     = "50m"
}

variable "fluent_bit_resources_requests_memory" {
  description = "Memory request for Fluent Bit container"
  type        = string
  default     = "100Mi"
}
