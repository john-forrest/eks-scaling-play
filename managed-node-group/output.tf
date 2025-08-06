
output "autoscaler_role_arn" {
  description = "ARN of role we add for the autoscaler"
  value       = aws_iam_role.tf_autoscale_role.arn
}

