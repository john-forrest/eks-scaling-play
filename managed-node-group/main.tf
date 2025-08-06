
provider "aws" {
  region = var.region
}

locals {
  app_labels = {
    application                                                 = "nginx"
    "k8s.io/cluster-autoscaler/enabled"                         = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"             = "true"
    "k8s.io/cluster-autoscaler/node-template/label/application" = "nginx"
  }
}

# Identify cluster subnets so we can create a fargate pool below

data "aws_eks_cluster" "my_cluster" {
  name = var.cluster_name
}

data "aws_subnets" "my_cluster" {
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.my_cluster.vpc_config[0].vpc_id]
  }
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version         = "21.0.7"

  name               = var.nodegroup_name
  cluster_name       = var.cluster_name
  kubernetes_version = data.aws_eks_cluster.my_cluster.version

  subnet_ids = data.aws_subnets.my_cluster.ids

  cluster_service_cidr = data.aws_eks_cluster.my_cluster.kubernetes_network_config[0].service_ipv4_cidr

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  # cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  # vpc_security_group_ids            = [module.eks.node_security_group_id]

  // Note: `disk_size`, and `remote_access` can only be set when using the EKS managed node group default launch template
  // This module defaults to providing a custom launch template to allow for custom security groups, tag propagation, etc.
  // use_custom_launch_template = false
  // disk_size = 50
  //
  //  # Remote access cannot be specified with a launch template
  //  remote_access = {
  //    ec2_ssh_key               = module.key_pair.key_pair_name
  //    source_security_group_ids = [aws_security_group.remote_access.id]
  //  }

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.micro"]
  capacity_type  = "SPOT"
  use_custom_launch_template = false

  labels = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    application = "nginx"
  }

  taints = {
    dedicated = {
      key    = "dedicated"
      value  = "gpuGroup"
      effect = "NO_SCHEDULE"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    "k8s.io/cluster-autoscaler/enabled"                         = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"             = "true"
    "k8s.io/cluster-autoscaler/node-template/label/application" = "nginx"
  }
}

#data "aws_autoscaling_group" "eks_managed_node_group" {
#  for_each = module.eks_managed_node_group.node_group_autoscaling_group_names
#  name = each.value
#}
#
#resource "aws_autoscaling_group_tag" "eks_managed_node_group" {
#  for_each = flatten([
#    for autoscaling_group_name in module.eks_managed_node_group.node_group_autoscaling_group_names : [
#      for app_label_key, app_label_value in local.app_labels : {
#        autoscaling_group_name = autoscaling_group_name
#        key = app_label_key
#        value = app_label_value
#      }
#    ]
#  ])
#
# autoscaling_group_name = each.value.autoscaling_group_name
#
#  tag {
#    key   = each.value.key
#    value = each.value.value
#
#    propagate_at_launch = false
#  }
#}