module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "sect-${terraform.workspace}"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      version = "v1.9.3-eksbuild.5"
    }
    kube-proxy = {
      version = "v1.25.11-eksbuild.1"
    }
    vpc-cni = {
      version = "v1.13.2-eksbuild.1"
    }
  }

  vpc_id     = aws_vpc.sect.id
  subnet_ids = local.subnets["private"]

  manage_aws_auth_configmap = true

  #   Dont need you right now. Sorry devops.
  #   aws_auth_roles = [
  #     {
  #       rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DevOps"
  #       username = "devops"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terryform"
      username = "terryform"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "${terraform.workspace}"
    Terraform   = "true"
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small", "t3.medium"]
  }

  eks_managed_node_groups = {
    nodegroup1 = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    },
  }
}
