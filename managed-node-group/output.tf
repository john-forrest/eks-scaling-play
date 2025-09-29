
output "autoscaler_role_arn" {
  description = "ARN of role we add for the autoscaler"
  value       = aws_iam_role.autoscaler_role.arn
}

output "autoscaler_role_name" {
  description = "Name of role we add for the autoscaler"
  value       = aws_iam_role.autoscaler_role.name
}
