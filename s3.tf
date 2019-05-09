resource "aws_s3_bucket" "bucket" {
  bucket = "${format("%s.%s.%s", var.bucket_prefix, var.environment, var.domain)}"
  acl = "private"

  tags = {
    Environment = "${var.environment}"
  }
}

