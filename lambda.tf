resource "null_resource" "build_lambda" {
  triggers {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "${path.module}/src/build.sh"
    interpreter = ["bash", "-c"]
  }
}


resource "aws_lambda_function" "certbot" {
  filename          = "${path.module}/files/certbot-lambda.zip"
  function_name     = "certbot-lambda"
  role              = "${aws_iam_role.lambda_role.arn}"
  handler           = "main.handler"
  source_code_hash  = "${filebase64sha256("${path.module}/files/certbot-lambda.zip")}"
  runtime           = "python3.7"
  timeout           = 60
  description       = "Renew Let's Encrypt wildcard cert and import new cert to ACM"

  environment {
    variables = {
      LETSENCRYPT_DOMAINS = "${var.domain},*.${var.domain}"
      LETSENCRYPT_EMAIL = "${var.email}"
      NOTIFICATION_SNS_ARN = "${aws_sns_topic.alerts.arn}"
      SENTRY_DSN = "${var.certbot_sentry_dsn}"
    }
  }
}


# Timer that runs every 12 hours
resource "aws_cloudwatch_event_rule" "certbot_timer_rule" {
  name                = "certbot_timer"
  schedule_expression = "cron(0 */12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "certbot_timer_target" {
  rule = "${aws_cloudwatch_event_rule.certbot_timer_rule.name}"
  arn  = "${aws_lambda_function.certbot.arn}"
}

# Give cloudwatch permission to invoke the function
resource "aws_lambda_permission" "permission" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.certbot.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.certbot_timer_rule.arn}"
}
