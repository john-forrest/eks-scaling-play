
# Managed Node Group

This is the equivalent of the [eks-create-app-ng.yml]
(../../eks-create-app-ng.yml) file in the original. The requirement
is to create a managed node group that we can then associated an
autoscaler with. This is based on the example given in the
associated official module - [see here](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group).

Note: we are going to supply some parameters, like the cluster, as
normal "variables". Given it is terraform, we could read them from
the backend s3 bucket of the fargate-cluster layer. However by not
doing so, this layer could work (say) with a cluster created using
eksctl.

To use run:

    echo "cluster_name = \"MY_CLUSTER\"" > tfvars.tfvars
    echo "oidc_provider = \"OIDC_PROVIDER\"" >> tfvars.tfvars
(substituting MY_CLUSTER to the cluster name generated under fargate-cluster,
and OIDC_PROVIDER is the oidc provider setting also generated there)

and then:

    terraform init -backend-config="bucket=S3_BUCKET" -backend-config="region=eu-west-2" -backend-config="use_lockfile=true"
    terraform plan -out plan.out -var-file tfvars.tfvars
(substituting S3_BUCKET with the value from cluster-remote-state).

Then apply as usual.

At the end:

    terraform output --raw autoscaler_role_arn

shows the IAM role we've created - used below.

Note:
- The iam_role creation has been added here for convenience.
Arguably it should be in a separate terraform "module".

### Destryction

At end:

    terraform destroy -var-file=tfvars.tfvars


