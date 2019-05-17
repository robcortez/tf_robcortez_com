resource "aws_route53_zone" "public" {
  name = "${var.domain}"
}

# TODO: Add record for CloudFront distro once it is provisioned

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.public.zone_id}"
  name    = "www.robcortez.com"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex" {
  zone_id = "${aws_route53_zone.public.zone_id}"
  name    = "robcortez.com"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect.hosted_zone_id}"
    evaluate_target_health = true
  }
}
