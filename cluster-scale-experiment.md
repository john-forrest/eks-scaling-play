# Experiment with scripted cluster autoscaler

## The requirement

The wish is that we can setup an environment to run the "hpa-php-apache + load" environment
on a k8s cluster just by scripting (except perhaps the load generator). When the loading starts,
the number of pods should increase as required. When the load is turned off, it should
decrease. The apache pods should run on their own t3.micro-based nodegroup. This should
have min 1. (Stretch goal, the nodegroup has min size 0 and should have no associated nodes
until the apache deployment is made)

## Some notes

* The cluster scaler deployments need at least 600m so won't run on a t3.micro node. Need to
at least allocated t3.small (the exercise before was m5.large)
* Assume we will use taint and toleration wrt to the new nodegroup.
* The deployment for the autoscaler in instructions to date seems finickity in that the
deployment script (so far https://raw.githubusercontent.com/kubernetes/autoscaler/refs/heads/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml) requires manual edit following deployment. Ideally want helm chart
but even then it requires knowledge of the current kubenetes version and the latest
deployment image for that.

## Basic Approach

* Want cluster with managed nodes for the system pods, including autoscalers. Must
be at least "small" - so use t3.small. Make "managed" for good measure but not sure required.
* Create managed nodegroup for the app running t3.mobile. "ng-nginx"


## Possible script

    eksctl create cluster --name eksctl-test --nodegroup-name ng-default --node-type t3.small --nodes 2 --managed --asg-access
(don't use config file because that creates two cloudformation jobs and the delete does not work.
Note --asg-access required to run autoscaler on ng-default)

    eksctl create nodegroup -f eks-create-app-ng.yml
(Note min and desired size are 0, so should be no nodes until we create the application pods)

    helm repo add autoscaler https://kubernetes.github.io/autoscaler
    helm upgrade --install autosc-release autoscaler/cluster-autoscaler \
        --namespace kube-system \
        --set 'autoDiscovery.clusterName=eksctl-test' \
        --set awsRegion=eu-west-2

kubectl apply -f hpa-php-apache.yaml
(when we did orig, just with toleration and not affinity, it ran the first pod on ng-default.
Added affinity at which point it said it did not have a valid node to run on. Ended up disabling
taing on the nodegroup)

Run:

    kubectl get hpa

Wait until the pod Target CPU stops showing "unknown"

Then do the:

    kubectl run -i --tty --rm load-generator --image=busybox sh
    while sleep 0.01; do wget -q -O- http://php-apache; done

    kubectl get hpa
    kubectl get nodes -l application=nginx
    kubectl get pods -l run=php-apache
    eksctl get nodegroup --cluster eksctl-test

(Eventually settle down with 4 php-apache nodes and 2 of the app/ng-application pods)

Afterwards:
1. Cntrl-C the busybox
2. hpa usage should drop to 0%
3. Eventually number of pods should drop to 1
4. Wait 10 min or so
5. The number of app nodes will also drop to 1

## Alternative (Terraform)

At my current work, the policy is to setup infrastructure using terraform where possible -
give or take kubernetes stuff, if you count that, where we use helm. Essentially the
additional requirement is to use terraform instead of ekctl in the above.

I am going to add an additional requirement that the terraform is split into two parts:
"cluster" and "node group". These basically correspond to the "eksctl create cluster"
and "eksctl create nodegroup" steps above. It ought to be possible to do this in one
stage using terraform, but the assumption is that the cluster might be created by
a different team than wants to setup the nodes for the application, who may have different
access rights. For this reason, each will have its own independent terraform state -
in a proper scenario, that would have differing access rights but not bothering with
that bit here.

The initial requirement for both is to setup some terraform state environments. Having
said the above, to simplify things I will use a single s3 bucket to hold the state of
both cluster and node group, but with different keys - just to make things easier.
Setting up the first remote state environment is always slightly tricky. See
[cluster-remote-state](cluster-remote-state/Readme.md) for how it is done.

