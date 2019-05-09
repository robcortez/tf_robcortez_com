# RobCortez.com Terraform

This will create the following: 

- VPC
- S3 Bucket to store static website files
- CloudFront distribution to serve those files
- Lamdba to automatically renew Let's Encrypt wildcard cert and update ACM
- Resources to monitor it all (CloudWatch logs, SNS topic for text alerts, etc.)
