
# Setup Autoscaler

We are going to still use helm to setup the autoscaler since it ties to
the kubernetes requirements. (The alternative might be to use resource
aws_autoscaling_group but that is seemingly intended for traditional,
non-k8s uses.)

Run:

    (assume AWS_PROFILE is setup correct)
    aws eks update-kubeconfig --name MY_CLUSTER
    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    helm upgrade --install autosc-release autoscaler/cluster-autoscaler \
        --namespace kube-system \
        --set 'autoDiscovery.clusterName=MY_CLUSTER' \
        --set awsRegion=eu-west-2 \
        --set image.tag=IMAGE_TAG \
        --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=MY_ROLE \
        --set rbac.serviceAccount.serviceAccount.name=autoscaler-service-account \
        --set rbac.serviceAccount.serviceAccount.create=true
    (where MY_CLUSTER is the name of the cluster from above,
     for IMAGE_TAG see below,
     and MY_ROLE is the iam role from above)

For IMAGE_TAG it is necessary to do some detective work. Look
on the [releases](https://github.com/kubernetes/autoscaler/releases)
page for the github repo. Look for the latest one that corresponds
to the version of kubernetes used in the cluster - e.g. for
1.31 we look for the latest v1.31.x. Use that.

Warning:
- Because this is added to the kube-system namespace, other helm commands
need to quote that, thus:

        helm get values autosc-release --namespace=kube-system

At end, the uninstall operation seimilarly looks like:

        helm uninstall autosc-release --namespace=kube-system


