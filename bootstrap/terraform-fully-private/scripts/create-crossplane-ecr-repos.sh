bin/bash

AWS_REGION='us-east-1'
ECR_URL=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]').dkr.ecr.$AWS_REGION.amazonaws.com

#login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

aws ecr create-repository --repository-name crossplane-contrib/provider-helm --region ${AWS_REGION}
aws ecr create-repository --repository-name crossplane-contrib/provider-kubernetes --region ${AWS_REGION}
aws ecr create-repository --repository-name crossplane/crossplane --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-apigateway --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-cloudwatch --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-cloudwatchlogs --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-dynamodb --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-ec2 --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-eks --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-elasticache --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-iam --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-kms --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-lambda --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-rds --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-s3 --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-sns --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-sqs --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-aws-vpc --region ${AWS_REGION}
aws ecr create-repository --repository-name upbound/provider-family-aws --region ${AWS_REGION}
