## **Terraform AWS Cloud Resume** <samp><img src="cloud1.ico" width="24" height="22" border="10"/></samp>

Check it out here: [ahmedharrisdevops.com](https://ahmedharrisdevops.com) 

This repo is my AWS Cloud Resume infrastructure written in Terraform.

* Cloud: AWS, Route 53, CloudFront, S3, Lamba, DynamoDB, CloudWatch
* Version Control: Git
* CI/CD: GitHub Actions

## **Architecture** 
* route53.tf Configures DNS management & custom domains within Route 53, directing traffic to CloudFront CDN.
* cloudfront.tf Provisions CloudFront distribution to serve S3 website content.
* s3.tf Creates S3 bucket to host Cloud Resume website content.
* lambda.tf Configures Python Lambda function, IAM roles and permissions, to update DynamoDB visitor count.
* dynamodb.tf Provisions DynamoDB table to store website visitor count.


