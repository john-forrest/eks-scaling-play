
output "autoscaler_role_arn" {
  description = "ARN of role we add for the autoscaler"
  value       = module.cluster_autoscaler_irsa.iam_role_arn
}

output "autoscaler_role_name" {
  description = "Name of role we add for the autoscaler"
  value       = module.cluster_autoscaler_irsa.iam_role_name
}
