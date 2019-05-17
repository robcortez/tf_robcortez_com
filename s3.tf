resource "aws_s3_bucket" "bucket" {
  bucket = "${format("%s.%s.%s", var.bucket_prefix, var.environment, var.domain)}"
  acl = "private"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "redirect_to_www" {
  bucket = "${var.domain}"

  website {
    redirect_all_requests_to = "https://www.${var.domain}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

