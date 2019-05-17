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

  aliases = [
    "www.${var.domain}"
  ]

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

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/"
    error_caching_min_ttl = 100
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
    minimum_protocol_version = "TLSv1.1_2016"
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

resource "aws_cloudfront_distribution" "redirect" {
  origin {
    domain_name = "${aws_s3_bucket.redirect_to_www.website_endpoint}"
    origin_id = "S3-${var.domain}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  aliases = ["${var.domain}"]

  enabled = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain}"

    "forwarded_values" {
      "cookies" {
        forward = "none"
      }
      query_string = false
    }

    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    max_ttl = 31536000
    default_ttl = 86400
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.wildcard.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    "geo_restriction" {
      restriction_type = "none"
    }
  }
}

