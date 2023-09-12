resource "aws_ecr_repository" "sect-ecr" {
  for_each = local.ecr_repos
  name     = each.key
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "sect-lifecycle-policy" {
  for_each   = local.ecr_repos
  repository = each.key
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire images older than 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_repository_policy" "sect-repo-policy" {
  depends_on = [aws_ecr_repository.sect-ecr]
  for_each   = local.ecr_repos
  repository = each.key
  policy = templatefile("${path.module}/ecr_policy.json.tfpl", {
    account_id = data.aws_caller_identity.current.account_id
  })
}