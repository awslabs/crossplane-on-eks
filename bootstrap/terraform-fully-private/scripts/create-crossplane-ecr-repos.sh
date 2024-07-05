#!/bin/bash

AWS_REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]')
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

# Define the list of repositories
REPOSITORIES=(
    "crossplane-contrib/provider-helm"
    "crossplane-contrib/provider-kubernetes"
    "crossplane/crossplane"
    "upbound/provider-aws-apigateway"
    "upbound/provider-aws-cloudwatch"
    "upbound/provider-aws-cloudwatchlogs"
    "upbound/provider-aws-dynamodb"
    "upbound/provider-aws-ec2"
    "upbound/provider-aws-eks"
    "upbound/provider-aws-elasticache"
    "upbound/provider-aws-iam"
    "upbound/provider-aws-kms"
    "upbound/provider-aws-lambda"
    "upbound/provider-aws-rds"
    "upbound/provider-aws-s3"
    "upbound/provider-aws-sns"
    "upbound/provider-aws-sqs"
    "upbound/provider-aws-vpc"
    "upbound/provider-family-aws"
)

# Loop through each repository and create it
for repo in "${REPOSITORIES[@]}"; do
    aws ecr create-repository --repository-name ${repo} --region ${AWS_REGION}
done
