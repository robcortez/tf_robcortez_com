# Cert needs to exist - run lambda code locally to provision
data "aws_acm_certificate" "wildcard" {
  domain       = "*.${var.domain}"
}
