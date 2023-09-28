resource "aws_acm_certificate" "cert" {
  domain_name       = "sect.net"
  validation_method = "DNS"
  subject_alternative_names = ["ping.sect.net", "splunge.sect.net"]

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}