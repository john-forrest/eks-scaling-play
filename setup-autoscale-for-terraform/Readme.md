
# Setup Autoscaler

We are going to still use helm to setup the autoscaler since it ties to
the kubernetes requirements. The alternative might be to use resource
aws_autoscaling_group but that is seemingly intended for traditional,
non-k8s uses.

Run:

    (assume AWS_PROFILE is setup correct)
    aws eks update-kubeconfig --name MY_CLUSTER
    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    helm upgrade --install autosc-release autoscaler/cluster-autoscaler \
        --namespace kube-system \
        --set 'autoDiscovery.clusterName=MY_CLUSTER' \
        --set awsRegion=eu-west-2
    (where MY_CLUSTER is the name of the cluster from above)