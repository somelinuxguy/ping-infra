#/bin/bash
export KUBE_CONFIG_PATH=~/.kube/config
echo "Hello! I depend on two prequisites you need to setup prior to using me."
echo "Ensure you have set up: "
echo "aws-cli"
echo "kubectl"
echo "vault"

# Check if required environment variables are set
if [ -z "$VAULT_ADDR" ] || [ -z "$VAULT_NAMESPACE" ] || [ -z "$VAULT_TOKEN" ] || [ -z "$AWS_DEFAULT_REGION" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Usage: Please set the following environment variables:"
    echo "  - VAULT_ADDR"
    echo "  - VAULT_NAMESPACE"
    echo "  - VAULT_TOKEN"
    echo "  - AWS_DEFAULT_REGION"
    echo "  - AWS_SECRET_ACCESS_KEY"
    echo "  - AWS_ACCESS_KEY_ID"
else
    DoTheThing
fi

DoTheThing() {
    vault auth enable --path=jwt-gha jwt

    vault write auth/jwt-gha/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com" \
    default_role="nil"

    vault write auth/jwt-gha/role/gha -policy=@gha_role.json

    # Only read /ping/* vault paths
    vault policy write gha -policy=gha_policy.policy

    #now apply terraform from the main directory.
    terraform workspace select dev
    terraform plan
    terraform apply
    echo "Sleeping for 5 minutes to let EKS finish..."
    # strange as it seems, it takes time for EKS to finish building
    # sleep 300
    
    #now apply terraform from the ingress
    #I hate this work around... find a better way
    # cd ingress 
    # terraform workspace select dev
    # terraform plan
    # terraform apply
  }