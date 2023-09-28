module "ingress" {
  source     = "./modules/k8s"
  oidc_arn   = module.eks.oidc_provider_arn
  account_id = data.aws_caller_identity.current.account_id
  region     = var.region
}