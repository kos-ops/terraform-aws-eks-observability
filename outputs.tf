output "monitoring_namespace" {
  description = "Name of the monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "cloudwatch_namespace" {
  description = "Name of the amazon-cloudwatch namespace"
  value       = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
}

output "prometheus_role_arn" {
  description = "ARN of the Prometheus IAM role"
  value       = module.prometheus_role.role_arn
}

output "fluent_bit_role_arn" {
  description = "ARN of the Fluent Bit IAM role"
  value       = module.fluent_bit_role.role_arn
}
