terraform {
    backend "s3" {
        key = "managed_node_group_tfstate/terraform.tfstate"
    }
}
