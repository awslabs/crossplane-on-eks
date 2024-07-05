#!/bin/bash

AWS_REGION='us-east-1'
ACCOUNT_ID=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]')
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

PREFIXES=(
    "crossplane-contrib/"
    "docker-hub/"
    "ecr/"
    "k8s/"
    "quay/"
    "upbound/"
    "crossplane"
)

echo "Running Terraform destroy..."
terraform destroy --auto-approve

REPOS=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text --region ${AWS_REGION})

for repo in ${REPOS}; do
    for prefix in "${PREFIXES[@]}"; do
        if [[ $repo == $prefix* ]]; then
            echo "Deleting repository: ${repo}"
            aws ecr delete-repository --repository-name ${repo} --region ${AWS_REGION} --force
        fi
    done
done
