resource "aws_cloudwatch_log_group" "certbot" {
  name              = "/aws/lambda/${aws_lambda_function.certbot.function_name}"
  retention_in_days = 14
}
