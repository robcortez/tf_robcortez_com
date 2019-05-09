resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = "${format("%s.%s.%s.s3.amazonaws.com", var.bucket_prefix, var.environment, var.domain)}"
    origin_id   = "${format("%s.%s.%s", var.bucket_prefix, var.environment, var.domain)}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  comment             = "robcortez.com: ${var.environment} env"
  default_root_object = "index.html"

  aliases = ["${var.cname_alias}"]

   default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${format("%s.%s.%s", var.bucket_prefix, var.environment, var.domain)}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Environment = "${var.environment}"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1"
    acm_certificate_arn = "${data.aws_acm_certificate.wildcard.arn}"
    ssl_support_method = "sni-only"
  }

  tags {
    Environment = "${var.environment}"
  }

}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "robcortez.com: ${var.environment} env"
}

