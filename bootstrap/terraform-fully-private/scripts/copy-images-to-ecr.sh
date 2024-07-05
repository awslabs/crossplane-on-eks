#!/bin/bash

AWS_REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]')
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

PROGRAM=crane 

PACKAGES=(
    "crossplane/crossplane:v1.16.0"
    "crossplane-contrib/provider-helm:v0.18.1"
    "crossplane-contrib/provider-kubernetes:v0.13.0"
    "upbound/provider-aws-apigateway:v1.6.0"
    "upbound/provider-aws-cloudwatch:v1.6.0"
    "upbound/provider-aws-cloudwatchlogs:v1.6.0"
    "upbound/provider-aws-dynamodb:v1.6.0"
    "upbound/provider-aws-ec2:v1.6.0"
    "upbound/provider-aws-eks:v1.6.0"
    "upbound/provider-aws-elasticache:v1.6.0"
    "upbound/provider-aws-iam:v1.6.0"
    "upbound/provider-aws-kms:v1.6.0"
    "upbound/provider-aws-lambda:v1.6.0"
    "upbound/provider-aws-rds:v1.6.0"
    "upbound/provider-aws-s3:v1.6.0"
    "upbound/provider-aws-sns:v1.6.0"
    "upbound/provider-aws-sqs:v1.6.0"
    "upbound/provider-aws-vpc:v1.6.0"
    "upbound/provider-aws-cloudfront:v1.6.0"
    "upbound/provider-family-aws:v1.6.0"
)

aws ecr get-login-password --region $AWS_REGION | crane auth login --username AWS --password-stdin $ECR_URL

for pkg in "${PACKAGES[@]}"; do
    if [ "$PROGRAM" == "crane" ]; then
        crane copy xpkg.upbound.io/${pkg} ${ECR_URL}/${pkg}
    else
        echo "Unsupported program: $PROGRAM"
        exit 1
    fi
done
