
variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "k8s_version" {
  type        = string
  default     = "1.31"
  description = "Version of kubernetes to use for cluster"
}

