#/bin/bash
export KUBE_CONFIG_PATH=~/.kube/config
echo "Hello! I depend on two prequisites you need to setup prior to using me."
echo "Ensure you have set up: "
echo "aws-cli"
echo "kubectl"
echo "vault"

TASK=$1

DoVault() {
    echo "Setting up vault for GHA..."
    vault auth enable --path=jwt-gha jwt

    vault write auth/jwt-gha/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com" \
    default_role="nil"

    vault write auth/jwt-gha/role/gha -policy=@gha_role.json

    # Only read /ping/* vault paths
    vault policy write gha -policy=@gha_policy.policy

    echo "Vault is set up."
    echo "Verifying..."

    vault read auth/jwt-gha/role/gha
    if [ $? -ne 0 ]; then
        echo "ERROR - Vault returned a non-Zero exit code"
        exit 1
    fi
}

DoTerraform() {
    terraform init
    terraform workspace select dev
    terraform plan
    terraform apply
    if [ $? -ne 0 ]; then
        echo "ERROR - Vault returned a non-Zero exit code"
        echo "This is often expected in a brand new AWS account. The fix: Try running it again in 5 minutes."
        exit 1
    fi

    # apply terraform for an ingress controller
    # TODO - I hate this work around... find a better way
    # cd ingress 
    # terraform workspace select dev
    # terraform plan
    # terraform apply
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
        "vault")
            DoVault
            ;;
        "terraform")
            DoTerraform
            ;;
        *)
            echo "Usage -"
            echo "Run me with a parameter like 'run.sh vault' or 'run.sh terraform'"
            echo 
            ;;
    esac
fi
