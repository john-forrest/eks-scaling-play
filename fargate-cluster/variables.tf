
variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "k8s_version" {
  type        = string
  default     = "1.31"
  description = "Version of kubernetes to use for cluster"
}

variable "nodegroup_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 type for created nodegroup"
}