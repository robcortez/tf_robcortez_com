resource "aws_route53_zone" "public" {
  name = "${var.domain}"
}

resource "aws_route53_zone" "dev" {
  name = "${format("dev.%s", var.domain)}"
  tags = {
    environment = "dev"
  }
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

resource "aws_route53_record" "dev-ns" {
  zone_id = "${aws_route53_zone.public.zone_id}"
  name    = "${format("dev.%s", var.domain)}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}",
  ]
}

resource "aws_route53_record" "dev-wildcard" {
  zone_id = "${aws_route53_zone.dev.zone_id}"
  name    = "${format("*.dev.%s", var.domain)}"
  type    = "CNAME"
  ttl     = "30"

  # tunnel.<domain> is auto-updated by local cronjob on vpn server
  # TODO: ugly - change to A record and have script update this as well
  records = [
    "${format("tunnel.%s", var.domain)}"
  ]
}
