# Initial terrform state

There is a chicken-and-egg issue to starting to use Terraform, at least on AWS.
Terraform uses a state file to work, and preferably that state file should be
on AWS itself so that we can maintain the environment wherever. However first
time around that state file does not exist - we are to create it. For real,
we might want to have separate statefiles for the cluster and the nodegroup,
because different people may have the rights to set them up - all depends.
However for the particular scenario we are going to setup one state s3
bucket - we can use different keys to distinguish the different deployments.

The approach used is partly based on the scheme 
[here](https://github.com/john-forrest/aws-get-started-terraform/tree/initial/0a-pizza-networking-remote-state).

However since that was done, AWS has deprecated the use on a dynamodb
table to act as a lock so this is an update of that approach.

As a simplification, we assumes AWS is accessed via the default profile
in your AWS configuration. Also I've frozen the region to eu-west-2 (London) -
normally this would be a parameter set somewhere.

Having said that, the fact we use S3 introduces an extra complexity. It would
be highly convenient if we could use a fixed name for the S3 bucket such as
"basestate-tfstate". However, S3 buckets need to have a unique name, independent
of the account, so this is not really feasible. Instead, standard practice is
to add a random number to the bucket name. 

As said in the original...

There is a certain amount of "chicken and egg" going on here. We want to store the state
centrally but we can only do so once the bucket and lock have been created, and can only
do that once this has run! The approach is thus:

- Run terraform init, plan and apply as normal.
- Record the output (need in further networking configs that will use s3 backend)
- Rename/copy backend.tf.forlater to backend.tf
- Run:

        terraform init -backend-config="bucket=S3_BUCKET" -backend-config="region=eu-west-2" -backend-config="use_lockfile=true"

(substituting S3_BUCKET with the output recorded above).

From this point, the state data will be in S3. Note there is an argument for adding all those config variables to backend.tf so they are consistent. Also .terraform.lock.hcl should probably be added to git for real, were we wanted to maintain the setup. In this situation, where the instructions are intended to work from clean, this has been skipped.

These resources, in particular the S3 bucket, should not be destroyed. Thus "force_destroy" is set to false.

(The latter point is true until we try and destroy the whole. Then just comment that setting out.)

