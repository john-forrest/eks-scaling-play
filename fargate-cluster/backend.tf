terraform {
    backend "s3" {
        key = "fargate_cluster_tfstate/terraform.tfstate"
    }
}
