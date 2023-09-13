## A GitOps Project

# Requirements
1. We must not store secrets anywhere but Vault. No pipeline exposure.
1. We must use terraform to build the basic environment. (IaC)
1. We must trigger an app deployment via GitOps (a merge to a repository)
1. We must not store infrastructure configuration (k8s manifests) with the application code. We are allowed to store application specific things with the app code (like Datadog monitors)
1. It's not done unless it is tested, and monitored

Start with setting up Vault at Hashicorp, makes it easier if they manage it for us!

Done. Here is our vault public URL
https://vault-cluster-public-vault-aa91234.2f79cd88.z1.hashicorp.cloud:8200

Now let's export the env vars we need in our local shell. (These aren't real, don't get too excited hacker)

```
export VAULT_TOKEN="hvs.CAESIDpAF_CvHpDEx2cy5ROFNBYjJaTWFsMFpUZnNndFBr6666T1UuUDQ0eTUQ6QE"
export VAULT_ADDR="https://vault-cluster-public-vault-aa971234.2f79cd88.z1.hashicorp.cloud:8200"
export VAULT_NAMESPACE="admin"

vault secrets list -detailed
```
If you get output listing your default vault paths, then you know you're all set.

---

Now we need to set up an AUTH method for github to use, in order for GHA to pull secrets from vault.

This will enable the jwt auth method, and then configure it for github as our issuer and our OIDC service. Then we'll need to build a role with certain configuration on it to allow our repos to assume this role when github actions is running. That role needs access to our specific vault paths, so don't forget a policy. Here we named it gha and default, so that needs to be setup properly.

TODO:  script this. Even though this repo is meant to be manually run to lay the foundations, there's no good reason the below could not be flipped in to some TF or even just a bash script. Also that sub string is insecure but this is a demo so... we'll leave it alone because you are still limited by the policy to only read "ping" from vault.

```
vault auth enable --path=jwt-gha jwt

vault write auth/jwt-gha/config \
oidc_discovery_url="https://token.actions.githubusercontent.com" \
bound_issuer="https://token.actions.githubusercontent.com" \
default_role="nil"

vault write auth/jwt-gha/role/gha -<<EOF
{
"role_type": "jwt",
"bound_subject": "",
"bound_claims": {
"sub": ["repo:somelinuxguy/*:ref:refs/*"]
},
"bound_claims_type": "glob",
"bound_audiences": "https://github.com/somelinuxguy",
"user_claim": "workflow",
"policies": "gha, default",
"ttl": "1h"
}
EOF

# Only read /ping/* vault paths
vault policy write gha - <<EOF
path "/ping/*" {
  capabilities = ["read"]
}
EOF
```

Cool. Let's move on to the Terraform. We need an environment to target so let's build it. This assumes you have an AWS account set up already, and really the only manual things you need to do here is make an account with keys for Terraform to use AND set up an S3 bucket for it to store remote state in (since that's a best practice and local state is the devil).

```
export AWS_ACCESS_KEY_ID="AKIAZJW4JI64P12345"
export AWS_SECRET_ACCESS_KEY="12343Dp0O751Wy/zJLJLYehYQLw8q5tl12345678"
export AWS_DEFAULT_REGION=us-east-1

aws sts get-caller-identity
{
    "UserId": "AIDAZJW4JI64NT1234567",
    "Account": "639338666666",
    "Arn": "arn:aws:iam::639338666666:user/terryform"
}
```

Nice. So that all works and we verified the account.

Moving on... let's write a bunch of Terraform. We need the following:
VPC - a network
Subnets in the VPC - we'll use the standard 3 - public, private, storage
IGW - we want public to get to the internet
NATGW - we want private to get to the internet
ECR - need a place to put docker images
EKS - need a place for the docker images to run
EKS - once EKS exists, we need some stuff inside it, like an ingress controller. This is tricky so let's terraform it instead and leave nothing to chance eh?

Our manifests for kubernetes applications are going in the ping-gitops repo.

---
How do we apply ingress controllers with Helm, to a cluster that we are building at the same time?
This is probably going to crash, because it needs to be run twice. Once to build the cluster, and once to apply the helm charts for ingress controller. But remember, you need kubectl set up to run helm. Do you have kubectl installed and configured with your current AWS credentials, for a cluster that doesnt exist yet?!  Woops

So after the first run do this:
```
aws eks update-kubeconfig --region us-east-1 --name sect-dev --alias sect

Added new context sect to /Users/zombie/.kube/config
```

You'll also get this:
 Error: The configmap "aws-auth" does not exist

This is a known problem and the terraform fix (from the huge post in Github issues) is to just run `export KUBE_CONFIG_PATH=~/.kube/config; terraform plan; terraform apply` again and you're usually fine. I just did.

Let's test:
```
[blah blah blah]
module.ingress.helm_release.aws_lb_controler: Creation complete after 11s [id=aws-load-balancer-controller]

Apply complete! Resources: 1 added, 8 changed, 0 destroyed.
```
Hey cool. It completed. Let's verify!

```
kubectl get pods -n kube-system --context sect
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-6896d945d7-hwxx7   1/1     Running   0          2m29s
aws-load-balancer-controller-6896d945d7-rnshp   1/1     Running   0          2m29s
aws-node-7bzvm                                  1/1     Running   0          38m
aws-node-qwj7w                                  1/1     Running   0          38m
coredns-79df7fff65-rhr65                        1/1     Running   0          44m
coredns-79df7fff65-ztt5n                        1/1     Running   0          44m
kube-proxy-2zl9p                                1/1     Running   0          39m
kube-proxy-jfxs2                                1/1     Running   0          39m

kubectl logs aws-load-balancer-controller-6896d945d7-hwxx7 -n kube-system
{"level":"info","ts":"2023-09-12T20:36:25Z","msg":"version","GitVersion":"v2.6.0","GitCommit":"b805cc2327d00dde47f7e254843a6e234fab74f7","BuildDate":"2023-08-10T17:39:08+0000"}
{"level":"info","ts":"2023-09-12T20:36:25Z","logger":"controller-runtime.metrics","msg":"Metrics server is starting to listen","addr":":8080"}
{"level":"info","ts":"2023-09-12T20:36:25Z","logger":"setup","msg":"adding health check for controller"}
```

Nice! We appear to be set up.

Let's GHA this repo! Just kidding. This repo is for laying foundations and should be run manually. Your app on the other hand, should be pipelined and automated. Now that you have a working AWS infrastructure, let's move on to the app.