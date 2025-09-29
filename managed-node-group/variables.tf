
variable "cluster_name" {
  type        = string
  description = "Cluster name to deploy to"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "nodegroup_name" {
  type        = string
  default     = "ng-application"
  description = "Name to give nodegroup - should be unique"
}

variable "nodegroup_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 type for created nodegroup"
}

variable "oidc_provider" {
  type        = string
  description = "oidc provider for cluster"
}

variable "autoscaler_namespace" {
  type        = string
  description = "namespace we add autoscaler to"
  default     = "kube-system"
}

variable "service_account" {
  type        = string
  description = "name of account for autoscalers - must agree with params to helm but note prefix automatically added"
  default     = "autosc-release-aws-cluster-autoscaler"
}
