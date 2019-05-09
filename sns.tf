resource "aws_sns_topic" "alerts" {
  name = "alerts"
}

resource "aws_sns_topic_subscription" "alerts" {
  topic_arn = "${aws_sns_topic.alerts.arn}"
  protocol  = "sms"
  endpoint  = "${var.alerts_phone_num}"
}
