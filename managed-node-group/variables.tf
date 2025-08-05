
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
