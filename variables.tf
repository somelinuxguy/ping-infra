variable "region" {
  type        = string
  description = "The aws region in which to deploy"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "The environment in which to deploy"
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment) == true
    error_message = "The environment variable must be one of: 'prod', 'staging' or 'dev'"
  }
}

variable "datadog_api_key" {
  type        = string
  description = "The api key to deploy to datadog"
  default     = "8675309jenny"
}

variable "datadog_app_key" {
  type        = string
  description = "The app key to deploy to datadog"
  default     = "TommyTwoTone"
}