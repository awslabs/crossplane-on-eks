#!/bin/bash

AWS_REGION='us-east-1'
ECR_URL=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]').dkr.ecr.$AWS_REGION.amazonaws.com

# Choose to use docker or podman. Syntax is the same.
#PROGRAM=podman
PROGRAM=docker 

# login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

# pull images locally
${PROGRAM} pull xpkg.upbound.io/crossplane/crossplane:v1.16.0
${PROGRAM} pull xpkg.upbound.io/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} pull xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-apigateway:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudwatch:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudwatchlogs:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-dynamodb:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-ec2:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-eks:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-elasticache:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-iam:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-kms:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-lambda:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-rds:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-s3:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-sns:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-sqs:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-vpc:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudfront:v1.6.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-family-aws:v1.6.0

# tag images
${PROGRAM} tag xpkg.upbound.io/crossplane/crossplane:v1.16.0 ${ECR_URL}/crossplane/crossplane:v1.16.0
${PROGRAM} tag xpkg.upbound.io/crossplane-contrib/provider-helm:v0.13.0 ${ECR_URL}/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} tag xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.13.0 ${ECR_URL}/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-apigateway:v1.6.0 ${ECR_URL}/upbound/provider-aws-apigateway:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-cloudwatch:v1.6.0 ${ECR_URL}/upbound/provider-aws-cloudwatch:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-cloudwatchlogs:v1.6.0 ${ECR_URL}/upbound/provider-aws-cloudwatchlogs:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-dynamodb:v1.6.0 ${ECR_URL}/upbound/provider-aws-dynamodb:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-ec2:v1.6.0 ${ECR_URL}/upbound/provider-aws-ec2:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-eks:v1.6.0 ${ECR_URL}/upbound/provider-aws-eks:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-elasticache:v1.6.0 ${ECR_URL}/upbound/provider-aws-elasticache:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-iam:v1.6.0 ${ECR_URL}/upbound/provider-aws-iam:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-kms:v1.6.0 ${ECR_URL}/upbound/provider-aws-kms:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-lambda:v1.6.0 ${ECR_URL}/upbound/provider-aws-lambda:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-rds:v1.6.0 ${ECR_URL}/upbound/provider-aws-rds:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-s3:v1.6.0 ${ECR_URL}/upbound/provider-aws-s3:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-sns:v1.6.0 ${ECR_URL}/upbound/provider-aws-sns:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-sqs:v1.6.0 ${ECR_URL}/upbound/provider-aws-sqs:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-vpc:v1.6.0 ${ECR_URL}/upbound/provider-aws-vpc:v1.6.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-family-aws:v1.6.0 ${ECR_URL}/upbound/provider-family-aws:v1.6.0

# push to ecr
${PROGRAM} push ${ECR_URL}/crossplane/crossplane:v1.16.0
${PROGRAM} push ${ECR_URL}/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} push ${ECR_URL}/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-apigateway:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-cloudwatch:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-cloudwatchlogs:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-dynamodb:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-ec2:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-eks:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-elasticache:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-iam:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-kms:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-lambda:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-rds:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-s3:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-sns:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-sqs:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-aws-vpc:v1.6.0
${PROGRAM} push ${ECR_URL}/upbound/provider-family-aws:v1.6.0
