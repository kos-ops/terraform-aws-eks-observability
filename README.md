# terraform-aws-eks-observability
Reusable Terraform module for enabling observability in AWS EKS clusters. Provisions and configures Fluent Bit for log collection (integrated with CloudWatch), Prometheus for metrics, and Grafana for visualization, following best practices and supporting flexible customization.

<!-- BEGIN_TF_DOCS -->
## Contents
- [Description](#description)
- [Dependencies](#dependencies)
- [Resources](#resources)
- [Modules](#modules)
- [Inputs](#inputs)
- [Outputs](#outputs)


## Description
Reusable EKS observability module that installs and configures the full monitoring and logging stack:

- **Prometheus** — metrics collection via Helm chart with persistent TSDB storage; optional subcharts: kube-state-metrics, node-exporter, alertmanager, pushgateway
- **Grafana** — dashboards and visualization with Prometheus datasource; optionally exposed via Gateway API HTTPRoute or any other mechanism (ALB Ingress, Istio, etc.) through `grafana_values_override`
- **Fluent Bit** — DaemonSet-based log shipping to CloudWatch Logs (application, dataplane, and host logs)
- **IAM roles** — IRSA-based roles for Prometheus (EBS snapshots) and Fluent Bit (CloudWatch Logs)

Both Prometheus and Grafana support `*_values_override` inputs to pass arbitrary Helm values (tolerations, nodeSelector, additional config, etc.) without changing the module.

### Grafana access

By default the module does not create any ingress resources. To expose Grafana:

**Gateway API (HTTPRoute):**
```terraform
create_grafana_httproute    = true
grafana_hostname            = "grafana.example.com"
grafana_gateway_name        = "my-gateway"
grafana_gateway_namespace   = "ingress-gateway"
grafana_gateway_section_name = "https"
```

**AWS ALB Ingress / any other mechanism** — use `grafana_values_override`:
```terraform
create_grafana_httproute = false

grafana_values_override = {
  service = { type = "NodePort" }
  ingress = {
    enabled          = true
    ingressClassName = "alb"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    hosts = ["grafana.example.com"]
  }
}
```


## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.grafana_httproute](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_cluster_role.fluent_bit_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.fluent_bit_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.fluent_bit_cluster_info](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.fluent_bit_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_daemonset.fluent_bit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_namespace.amazon_cloudwatch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.fluent_bit_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.fluent_bit_allow_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fluent_bit_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.prometheus_allow_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.prometheus_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |


## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_fluent_bit_role"></a> [fluent\_bit\_role](#module\_fluent\_bit\_role) | ../modules/iam | n/a |
| <a name="module_prometheus_role"></a> [prometheus\_role](#module\_prometheus\_role) | ../modules/iam | n/a |


## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_aws_for_fluent_bit_version"></a> [aws\_for\_fluent\_bit\_version](#input\_aws\_for\_fluent\_bit\_version) | Version of the AWS for Fluent Bit image to use | `string` | `"3.2.4"` |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a |
| <a name="input_create_grafana_httproute"></a> [create\_grafana\_httproute](#input\_create\_grafana\_httproute) | Whether to create an HTTPRoute resource for Grafana (Gateway API). Disable if using Ingress or other routing. | `bool` | `false` |
| <a name="input_fluent_bit_ci_version"></a> [fluent\_bit\_ci\_version](#input\_fluent\_bit\_ci\_version) | CI\_VERSION env var value for Fluent Bit | `string` | `"k8s/1.3.41"` |
| <a name="input_fluent_bit_config_files"></a> [fluent\_bit\_config\_files](#input\_fluent\_bit\_config\_files) | Map of filename to content for Fluent Bit ConfigMap (e.g. fluent-bit.conf, application-log.conf, ...) | `map(string)` | n/a |
| <a name="input_fluent_bit_http_port"></a> [fluent\_bit\_http\_port](#input\_fluent\_bit\_http\_port) | HTTP server port for Fluent Bit metrics | `string` | `"2020"` |
| <a name="input_fluent_bit_http_server"></a> [fluent\_bit\_http\_server](#input\_fluent\_bit\_http\_server) | Enable HTTP server for Fluent Bit metrics (On/Off) | `string` | `"On"` |
| <a name="input_fluent_bit_image_pull_policy"></a> [fluent\_bit\_image\_pull\_policy](#input\_fluent\_bit\_image\_pull\_policy) | Image pull policy for Fluent Bit container | `string` | `"Always"` |
| <a name="input_fluent_bit_read_head"></a> [fluent\_bit\_read\_head](#input\_fluent\_bit\_read\_head) | Read log files from head on startup (On/Off) | `string` | `"Off"` |
| <a name="input_fluent_bit_read_tail"></a> [fluent\_bit\_read\_tail](#input\_fluent\_bit\_read\_tail) | Read log files from tail on startup (On/Off) | `string` | `"On"` |
| <a name="input_fluent_bit_resources_limits_cpu"></a> [fluent\_bit\_resources\_limits\_cpu](#input\_fluent\_bit\_resources\_limits\_cpu) | CPU limit for Fluent Bit container | `string` | `"100m"` |
| <a name="input_fluent_bit_resources_limits_memory"></a> [fluent\_bit\_resources\_limits\_memory](#input\_fluent\_bit\_resources\_limits\_memory) | Memory limit for Fluent Bit container | `string` | `"200Mi"` |
| <a name="input_fluent_bit_resources_requests_cpu"></a> [fluent\_bit\_resources\_requests\_cpu](#input\_fluent\_bit\_resources\_requests\_cpu) | CPU request for Fluent Bit container | `string` | `"50m"` |
| <a name="input_fluent_bit_resources_requests_memory"></a> [fluent\_bit\_resources\_requests\_memory](#input\_fluent\_bit\_resources\_requests\_memory) | Memory request for Fluent Bit container | `string` | `"100Mi"` |
| <a name="input_fluent_bit_role_name"></a> [fluent\_bit\_role\_name](#input\_fluent\_bit\_role\_name) | IAM role name for Fluent Bit | `string` | `"fluent-bit-role"` |
| <a name="input_grafana_admin_password_key"></a> [grafana\_admin\_password\_key](#input\_grafana\_admin\_password\_key) | Key in the Kubernetes secret that holds the Grafana admin password | `string` | `"admin-password"` |
| <a name="input_grafana_admin_secret_name"></a> [grafana\_admin\_secret\_name](#input\_grafana\_admin\_secret\_name) | Name of the Kubernetes secret containing Grafana admin credentials | `string` | `"grafana-admin"` |
| <a name="input_grafana_admin_user_key"></a> [grafana\_admin\_user\_key](#input\_grafana\_admin\_user\_key) | Key in the Kubernetes secret that holds the Grafana admin username | `string` | `"admin-user"` |
| <a name="input_grafana_atomic"></a> [grafana\_atomic](#input\_grafana\_atomic) | If true, Helm rolls back on failed deploy | `bool` | `true` |
| <a name="input_grafana_chart_version"></a> [grafana\_chart\_version](#input\_grafana\_chart\_version) | Grafana Helm chart version | `string` | `"10.5.15"` |
| <a name="input_grafana_gateway_name"></a> [grafana\_gateway\_name](#input\_grafana\_gateway\_name) | Name of the Gateway resource for Grafana HTTPRoute. This is used in the Grafana configuration to set the root URL and is required if create_grafana_httproute is true. | `string` | `"calico-gateway"` |
| <a name="input_grafana_gateway_namespace"></a> [grafana\_gateway\_namespace](#input\_grafana\_gateway\_namespace) | Namespace of the Gateway resource for Grafana HTTPRoute. This is used in the Grafana configuration to set the root URL and is required if create_grafana_httproute is true. | `string` | `"ingress-gateway"` |
| <a name="input_grafana_gateway_section_name"></a> [grafana\_gateway\_section\_name](#input\_grafana\_gateway\_section\_name) | Section name on the Gateway for Grafana HTTPRoute. This is an example value; update it to match your cluster's Gateway configuration if create_grafana_httproute is true. | `string` | `"https"` |
| <a name="input_grafana_hostname"></a> [grafana\_hostname](#input\_grafana\_hostname) | Public hostname for Grafana (e.g. grafana.example.com). This is used in the Grafana configuration to set the root URL and is required if create_grafana_httproute is true. | `string` | `null` |
| <a name="input_grafana_persistence_enabled"></a> [grafana\_persistence\_enabled](#input\_grafana\_persistence\_enabled) | Enable persistent storage for Grafana | `bool` | `true` |
| <a name="input_grafana_storage_class"></a> [grafana\_storage\_class](#input\_grafana\_storage\_class) | StorageClass for Grafana persistent volume. Empty string uses the cluster default StorageClass. | `string` | `""` |
| <a name="input_grafana_storage_size"></a> [grafana\_storage\_size](#input\_grafana\_storage\_size) | PV size for Grafana data | `string` | `"10Gi"` |
| <a name="input_grafana_timeout"></a> [grafana\_timeout](#input\_grafana\_timeout) | Helm release timeout for Grafana (seconds) | `number` | `600` |
| <a name="input_grafana_values_override"></a> [grafana\_values\_override](#input\_grafana\_values\_override) | Override values for Grafana Helm chart (use yamlencode-compatible map) | `any` | `{}` |
| <a name="input_prometheus_alertmanager_enabled"></a> [prometheus\_alertmanager\_enabled](#input\_prometheus\_alertmanager\_enabled) | Enable Alertmanager subchart | `bool` | `false` |
| <a name="input_prometheus_atomic"></a> [prometheus\_atomic](#input\_prometheus\_atomic) | If true, Helm rolls back on failed deploy | `bool` | `true` |
| <a name="input_prometheus_chart_version"></a> [prometheus\_chart\_version](#input\_prometheus\_chart\_version) | Prometheus Helm chart version | `string` | `"29.2.1"` |
| <a name="input_prometheus_kube_state_metrics_enabled"></a> [prometheus\_kube\_state\_metrics\_enabled](#input\_prometheus\_kube\_state\_metrics\_enabled) | Enable kube-state-metrics subchart | `bool` | `true` |
| <a name="input_prometheus_node_exporter_enabled"></a> [prometheus\_node\_exporter\_enabled](#input\_prometheus\_node\_exporter\_enabled) | Enable prometheus-node-exporter subchart | `bool` | `true` |
| <a name="input_prometheus_persistence_enabled"></a> [prometheus\_persistence\_enabled](#input\_prometheus\_persistence\_enabled) | Enable persistent storage for Prometheus TSDB | `bool` | `true` |
| <a name="input_prometheus_pushgateway_enabled"></a> [prometheus\_pushgateway\_enabled](#input\_prometheus\_pushgateway\_enabled) | Enable prometheus-pushgateway subchart | `bool` | `false` |
| <a name="input_prometheus_retention"></a> [prometheus\_retention](#input\_prometheus\_retention) | Prometheus data retention period | `string` | `"15d"` |
| <a name="input_prometheus_role_name"></a> [prometheus\_role\_name](#input\_prometheus\_role\_name) | IAM role name for Prometheus | `string` | `"prometheus-role"` |
| <a name="input_prometheus_storage_class"></a> [prometheus\_storage\_class](#input\_prometheus\_storage\_class) | StorageClass for Prometheus persistent volume. Empty string uses the cluster default StorageClass. | `string` | `""` |
| <a name="input_prometheus_storage_size"></a> [prometheus\_storage\_size](#input\_prometheus\_storage\_size) | PV size for Prometheus TSDB | `string` | `"50Gi"` |
| <a name="input_prometheus_timeout"></a> [prometheus\_timeout](#input\_prometheus\_timeout) | Helm release timeout for Prometheus (seconds) | `number` | `600` |
| <a name="input_prometheus_values_override"></a> [prometheus\_values\_override](#input\_prometheus\_values\_override) | Override values for Prometheus Helm chart (use yamlencode-compatible map) | `any` | `{}` |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to the resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_namespace"></a> [cloudwatch\_namespace](#output\_cloudwatch\_namespace) | Name of the amazon-cloudwatch namespace |
| <a name="output_fluent_bit_role_arn"></a> [fluent\_bit\_role\_arn](#output\_fluent\_bit\_role\_arn) | ARN of the Fluent Bit IAM role |
| <a name="output_monitoring_namespace"></a> [monitoring\_namespace](#output\_monitoring\_namespace) | Name of the monitoring namespace |
| <a name="output_prometheus_role_arn"></a> [prometheus\_role\_arn](#output\_prometheus\_role\_arn) | ARN of the Prometheus IAM role |

<!-- END_TF_DOCS -->
