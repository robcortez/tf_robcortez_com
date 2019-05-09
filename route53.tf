resource "aws_route53_zone" "public" {
  name = "${var.domain}"
}

# TODO: Add record for CloudFront distro once it is provisioned
