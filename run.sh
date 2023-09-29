#/bin/bash
export KUBE_CONFIG_PATH=~/.kube/config
echo "Hello! I depend on two prequisites you need to setup prior to using me."
echo "Ensure you have set up: "
echo "aws-cli"
echo "kubectl"
echo "vault"

TASK=$1

DoVaultGHA() {
    echo "Setting up vault for GHA..."
    echo "Ignore 'already exists' errors, operations are not idempotent."
    echo
    vault auth enable --path=jwt-gha jwt

    vault write auth/jwt-gha/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com" \
    default_role="nil"

    vault write auth/jwt-gha/role/gha @gha_role.json

    # Only read /ping/* vault paths
    vault policy write gha gha_policy.policy

    echo "Vault is set up."
    echo "Verifying..."

    vault read auth/jwt-gha/role/gha
    if [ $? -ne 0 ]; then
        echo "ERROR - Vault returned a non-Zero exit code"
        exit 1
    fi
}

DoVaultK8s() {
    echo "This requires that you've run terraform and scaffolded your infra. If you haven't this will fail."
    echo "Setting up vault for kubernetes..."

    # Note: You might need to modify these for --context if you have many contexts or havent set a default with kubectl
    export ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"
    echo "Issuer: $ISSUER"

    curl $ISSUER/.well-known/openid-configuration
    if [ $? -ne 0 ]; then
        echo "ERROR - A get of the ISSUER URL failed. Kubernetes may not be up and reachable from here."
        exit 1
    fi
    
    kubectl create clusterrolebinding oidc-reviewer  \
    --clusterrole=system:service-account-issuer-discovery \
    --group=system:unauthenticated

    vault auth enable --path=jwt-ping jwt
    vault write auth/jwt-ping/config oidc_discovery_url="${ISSUER}"

    # Note: The policy here should be app specific but to save time we are recycling the gha policy as it would be identical
    vault write auth/jwt-ping/role/ping \
    role_type="jwt" \
    bound_audiences="https://kubernetes.default.svc" \
    user_claim="sub" \
    bound_subject="system:serviceaccount:ping-app:vault-auth" \
    policies="gha, default" \
    ttl="1h"

    vault read auth/jwt-ping/role/ping
    if [ $? -ne 0 ]; then
        echo "ERROR - Failed to validate role."
        exit 1
    fi
}

DoTerraform() {
    terraform init
    terraform workspace new dev
    terraform workspace select dev
    terraform plan
    terraform apply
    if [ $? -ne 0 ]; then
        echo "ERROR - Terraform apply broke."
        echo "This is often expected in a brand new AWS account. The fix: "
        echo "1. Set up kubectl locally, now that you have a cluster." 
        echo "2. Try running this again in 5 minutes."
        exit 1
    fi
}

# Check if required environment variables are set
if [ -z "$VAULT_ADDR" ] || [ -z "$VAULT_NAMESPACE" ] || [ -z "$VAULT_TOKEN" ] || [ -z "$AWS_DEFAULT_REGION" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Usage: Please set the following environment variables:"
    echo "  - VAULT_ADDR"
    echo "  - VAULT_NAMESPACE"
    echo "  - VAULT_TOKEN"
    echo "  - AWS_DEFAULT_REGION"
    echo "  - AWS_SECRET_ACCESS_KEY"
    echo "  - AWS_ACCESS_KEY_ID"
    exit 1
else
    case "$TASK" in
        "vault-gha")
            DoVaultGHA
            ;;
        "terraform")
            DoTerraform
            ;;
        "vault-k8s")
            DoVaultK8s
            ;;
        *)
            echo "Usage:"
            echo "Run me with a parameter:"
            echo "vault-gha terraform vault-k8s"
            echo 
            ;;
    esac
fi
