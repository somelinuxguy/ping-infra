variable "oidc_arn" {
  type        = string
  description = "the ARN of the OIDC created with the EKS cluster"
}
variable "account_id" {
  type        = string
  description = "Account ID number"
}
variable "region" {
  type        = string
  description = "AWS Region"
}