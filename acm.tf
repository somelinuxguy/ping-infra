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

# --
# Right now, I use NameCheap but I'm placing this here from the terraform docs
# for easy reference.
# --
# data "aws_route53_zone" "sect" {
#   name         = "sect.net"
#   private_zone = false
# }

# resource "aws_route53_record" "sect" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.sect.zone_id
# }

# resource "aws_acm_certificate_validation" "sect" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.sect : record.fqdn]
# }