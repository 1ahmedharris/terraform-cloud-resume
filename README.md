## **Terraform AWS Cloud Resume** <samp><img src="cloud1.ico" width="34" height="32" border="20"/></samp>

Live Demo: [ahmedharrisdevops.com](https://ahmedharrisdevops.com) 

This repo is my AWS Cloud Resume infrastructure configured in Terraform.

* Cloud: AWS, Route 53, CloudFront, S3, Lamba, DynamoDB, CloudWatch
* Version Control: Git
* CI/CD Pipepline: GitHub Actions

<pre>
**Architecture** 
* route53.tf      Configures Route 53 DNS management, custom domains, directing traffic to CloudFront CDN.
* cloudfront.tf   Provisions CloudFront distribution to serve S3 website content.
* s3.tf           Creates S3 bucket to host Cloud Resume website content.
* lambda.tf       Configures Python Lambda function, IAM roles and permissions, to update DynamoDB visitor count.
* dynamodb.tf     Provisions DynamoDB table to store website visitor count.
</pre>

