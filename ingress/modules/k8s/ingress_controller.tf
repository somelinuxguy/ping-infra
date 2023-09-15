resource "aws_iam_policy" "load-balancer-policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for the load balancer controller in EKS"
  policy      = file("${path.module}/ingress_iam_policy.json")
}

resource "aws_iam_role" "load-balancer-controller-role" {
  name        = "AmazonEKSLoadBalancerControllerRole"
  description = "EKS Load Balancer controller role"
  assume_role_policy = templatefile("${path.module}/ingress_role_policy.json.tfpl",
    { oidc_arn = var.oidc_arn, oidc_id = split("/", var.oidc_arn) }
  )
}

resource "aws_iam_role_policy_attachment" "lbattach" {
  role       = aws_iam_role.load-balancer-controller-role.name
  policy_arn = aws_iam_policy.load-balancer-policy.arn
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = "arn:aws:iam::${var.account_id}:role/AmazonEKSLoadBalancerControllerRole"
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "aws_lb_controler" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  set {
    name  = "clusterName"
    value = "module.eks.cluster_name"
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }
}