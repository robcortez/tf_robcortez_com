data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = "${aws_s3_bucket.bucket.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

resource "aws_s3_bucket_policy" "redirect_to_www" {
  bucket = "${aws_s3_bucket.redirect_to_www.id}"
  policy = "${data.aws_iam_policy_document.redirect_to_www.json}"
}

data "aws_iam_policy_document" "redirect_to_www" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.redirect_to_www.arn}/*"]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.redirect_to_www.arn}"]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = [
      "route53:ListHostedZones",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "cloudwatch:PutMetricData",
      "acm:ListCertificates"
    ]
    resources = ["*"]

  }

  statement {
    actions   = [
      "sns:Publish",
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "acm:ImportCertificate",
      "acm:DescribeCertificate"
    ]
    resources = [
      "${aws_sns_topic.alerts.arn}",
      "arn:aws:route53:::hostedzone/${aws_route53_zone.public.zone_id}",
      "arn:aws:route53:::change/*",
      "arn:aws:acm:us-east-1:${var.aws_account_no}:certificate/*"
    ]
  }

  statement {
    actions   = [
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.certs.arn}"
    ]

  statement {
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.certs.arn}/*"
    ]

  }

}

resource "aws_iam_policy" "lambda_policy" {
  name   = "certbot-lambda"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}

resource "aws_iam_role" "lambda_role" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}
