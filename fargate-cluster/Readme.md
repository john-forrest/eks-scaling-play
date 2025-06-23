
# Fargate cluster

This setup is basically a copy of https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v19.21.0/examples/fargate_profile,
since pruned, but with minor modifications. See [Original_Readme.md](./Original_Readme.md).

Modifications are to pull in the module as normal (not assume in same repo),
to update the kubernetes version used to something still supported,
and to fix the region. Also we want to use s3 for the backend state.

Additionally there is a need to bring the terraform up to date, which is
perhaps not surprising since the current aws module is v20.37.1 and the
example targeted v19.21.0.

To use run:

    terraform init -backend-config="bucket=S3_BUCKET" -backend-config="region=eu-west-2" -backend-config="use_lockfile=true"
(substituting S3_BUCKET with the value from cluster-remote-state).

