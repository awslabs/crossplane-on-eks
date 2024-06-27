#!/bin/bash

AWS_REGION='us-east-1'
ECR_URL=$(aws sts get-caller-identity --output json | jq -r ".Account" | tr -d '[:space:]').dkr.ecr.$AWS_REGION.amazonaws.com

#login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

# Choose to use ${PROGRAM} or podman. Syntax is the same.
#PROGRAM=podman
PROGRAM=docker

# Pull Images with pull trough cache
#alb controller
${PROGRAM} pull ${ECR_URL}/ecr/eks/aws-load-balancer-controller:v2.7.1
#metrics-server
${PROGRAM} pull ${ECR_URL}/k8s/metrics-server/metrics-server:v0.7.0
#gatekeeper
${PROGRAM} pull ${ECR_URL}/docker-hub/curlimages/curl:7.83.1
${PROGRAM} pull ${ECR_URL}/docker-hub/openpolicyagent/gatekeeper-crds:v3.16.3
${PROGRAM} pull ${ECR_URL}/docker-hub/openpolicyagent/gatekeeper:v3.16.3
#argo
${PROGRAM} pull ${ECR_URL}/docker-hub/library/haproxy:2.9.4-alpine
${PROGRAM} pull ${ECR_URL}/docker-hub/library/redis:7.2.4-alpine
${PROGRAM} pull ${ECR_URL}/quay/argoproj/argocd:v2.11.2
${PROGRAM} pull ${ECR_URL}/docker-hub/dexidp/dex:v2.38.0
#prometheus
${PROGRAM} pull ${ECR_URL}/docker-hub/curlimages/curl:7.85.0
${PROGRAM} pull ${ECR_URL}/k8s/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
${PROGRAM} pull ${ECR_URL}/quay/kiwigrid/k8s-sidecar:1.24.6
${PROGRAM} pull ${ECR_URL}/quay/prometheus-operator/prometheus-operator:v0.66.0
${PROGRAM} pull ${ECR_URL}/quay/prometheus-operator/prometheus-config-reloader:v0.66.0
${PROGRAM} pull ${ECR_URL}/quay/prometheus/alertmanager:v0.25.0
${PROGRAM} pull ${ECR_URL}/quay/prometheus/prometheus:v2.45.0
${PROGRAM} pull ${ECR_URL}/quay/prometheus/node-exporter:v1.6.0
${PROGRAM} pull ${ECR_URL}/k8s/kube-state-metrics/kube-state-metrics:v2.9.2
${PROGRAM} pull ${ECR_URL}/docker-hub/grafana/grafana:10.0.2
