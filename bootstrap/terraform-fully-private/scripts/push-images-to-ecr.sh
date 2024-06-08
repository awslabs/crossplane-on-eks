#!/bin/bash

AWS_REGION='us-east-1'
AWS_ACCOUNT_ID=''

# Choose to use docker or podman. Syntax is the same.
#PROGRAM=podman
PROGRAM=docker 

${PROGRAM} pull docker.io/openpolicyagent/gatekeeper-crds:v3.16.3
${PROGRAM} pull docker.io/openpolicyagent/gatekeeper:v3.16.3
${PROGRAM} pull quay.io/argoproj/argocd:v2.11.2
${PROGRAM} pull ghcr.io/dexidp/dex:v2.38.0
${PROGRAM} pull redis:7.2.4-alpine
${PROGRAM} pull haproxy:2.9.4-alpine
${PROGRAM} pull public.ecr.aws/eks/aws-load-balancer-controller:v2.7.1
${PROGRAM} pull registry.k8s.io/metrics-server/metrics-server:v0.7.0
${PROGRAM} pull registry.k8s.io/metrics-server/metrics-server:v0.6.4
${PROGRAM} pull registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.12.0
${PROGRAM} pull registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2
${PROGRAM} pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1
${PROGRAM} pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
${PROGRAM} pull prom/prometheus:v2.52.0
${PROGRAM} pull prom/prometheus:v2.45.0
${PROGRAM} pull prom/alertmanager:v0.27.0
${PROGRAM} pull prom/alertmanager:v0.25.0
${PROGRAM} pull prom/node-exporter:v1.8.0
${PROGRAM} pull prom/node-exporter:v1.6.0
${PROGRAM} pull quay.io/prometheus-operator/prometheus-operator:v0.74.0
${PROGRAM} pull quay.io/prometheus-operator/prometheus-operator:v0.66.0
${PROGRAM} pull quay.io/prometheus-operator/prometheus-config-reloader:v0.74.0
${PROGRAM} pull quay.io/prometheus-operator/prometheus-config-reloader:v0.66.0
${PROGRAM} pull docker.io/grafana/grafana:10.0.2
${PROGRAM} pull docker.io/grafana/grafana-image-renderer:latest
${PROGRAM} pull docker.io/curlimages/curl:7.85.0
${PROGRAM} pull docker.io/curlimages/curl:7.83.1
${PROGRAM} pull docker.io/library/busybox:1.31.1
${PROGRAM} pull quay.io/kiwigrid/k8s-sidecar:1.24.6
${PROGRAM} pull xpkg.upbound.io/crossplane/crossplane:v1.16.0
${PROGRAM} pull xpkg.upbound.io/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} pull xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-apigateway:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudwatch:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudwatchlogs:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-dynamodb:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-ec2:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-eks:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-elasticache:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-iam:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-kms:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-lambda:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-rds:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-s3:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-sns:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-sqs:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-vpc:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-aws-cloudfront:v1.5.0
${PROGRAM} pull xpkg.upbound.io/upbound/provider-family-aws:v1.5.0

${PROGRAM} tag docker.io/openpolicyagent/gatekeeper-crds:v3.16.3 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/openpolicyagent/gatekeeper-crds:v3.16.3
${PROGRAM} tag quay.io/argoproj/argocd:v2.11.2 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/argocd:v2.11.2
${PROGRAM} tag ghcr.io/dexidp/dex:v2.38.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dex:v2.38.0
${PROGRAM} tag redis:7.2.4-alpine ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/redis:7.2.4-alpine
${PROGRAM} tag haproxy:2.9.4-alpine ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/haproxy:2.9.4-alpine
${PROGRAM} tag public.ecr.aws/eks/aws-load-balancer-controller:v2.7.1 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/aws-load-balancer-controller:v2.7.1
${PROGRAM} tag registry.k8s.io/metrics-server/metrics-server:v0.7.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/metrics-server/metrics-server:v0.7.0
${PROGRAM} tag registry.k8s.io/metrics-server/metrics-server:v0.6.4 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/metrics-server/metrics-server:v0.6.4
${PROGRAM} tag registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.12.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/kube-state-metrics/kube-state-metrics:v2.12.0
${PROGRAM} tag registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/kube-state-metrics/kube-state-metrics:v2.9.2
${PROGRAM} tag registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ingress-nginx/kube-webhook-certgen:v1.4.1
${PROGRAM} tag registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
${PROGRAM} tag prom/prometheus:v2.52.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/prometheus:v2.52.0
${PROGRAM} tag prom/prometheus:v2.45.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/prometheus:v2.45.0
${PROGRAM} tag prom/alertmanager:v0.27.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/alertmanager:v0.27.0
${PROGRAM} tag prom/alertmanager:v0.25.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/alertmanager:v0.25.0
${PROGRAM} tag prom/node-exporter:v1.8.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/node-exporter:v1.8.0
${PROGRAM} tag prom/node-exporter:v1.6.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/node-exporter:v1.6.0
${PROGRAM} tag quay.io/prometheus-operator/prometheus-operator:v0.74.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-operator:v0.74.0
${PROGRAM} tag quay.io/prometheus-operator/prometheus-operator:v0.66.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-operator:v0.66.0
${PROGRAM} tag quay.io/prometheus-operator/prometheus-config-reloader:v0.74.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-config-reloader:v0.74.0
${PROGRAM} tag quay.io/prometheus-operator/prometheus-config-reloader:v0.66.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-config-reloader:v0.66.0
${PROGRAM} tag docker.io/grafana/grafana:10.0.2 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/grafana:10.0.2
${PROGRAM} tag docker.io/grafana/grafana-image-renderer:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/grafana-image-renderer:latest
${PROGRAM} tag docker.io/curlimages/curl:7.85.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/curl:7.85.0
${PROGRAM} tag docker.io/curlimages/curl:7.83.1 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/openpolicyagent/curl:7.83.1
${PROGRAM} tag docker.io/library/busybox:1.31.1 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/busybox:1.31.1
${PROGRAM} tag quay.io/kiwigrid/k8s-sidecar:1.24.6 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/k8s-sidecar:1.24.6
${PROGRAM} tag xpkg.upbound.io/crossplane/crossplane:v1.16.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane/crossplane:v1.16.0
${PROGRAM} tag xpkg.upbound.io/crossplane-contrib/provider-helm:v0.13.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} tag xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.13.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-apigateway:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-apigateway:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-cloudwatch:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-cloudwatch:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-cloudwatchlogs:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-cloudwatchlogs:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-dynamodb:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-dynamodb:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-ec2:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-ec2:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-eks:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-eks:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-elasticache:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-elasticache:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-iam:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-iam:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-kms:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-kms:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-lambda:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-lambda:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-rds:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-rds:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-s3:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-s3:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-sns:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-sns:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-sqs:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-sqs:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-aws-vpc:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-vpc:v1.5.0
${PROGRAM} tag xpkg.upbound.io/upbound/provider-family-aws:v1.5.0 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-family-aws:v1.5.0

aws ecr get-login-password --region ${AWS_REGION} | ${PROGRAM} login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/argocd:v2.11.2
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dex:v2.38.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/redis:7.2.4-alpine
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/haproxy:2.9.4-alpine
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/aws-load-balancer-controller:v2.7.2
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/metrics-server/metrics-server:v0.7.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/metrics-server/metrics-server:v0.6.4
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/kube-state-metrics/kube-state-metrics:v2.12.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/kube-state-metrics/kube-state-metrics:v2.9.2
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ingress-nginx/kube-webhook-certgen:v1.4.1
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/prometheus:v2.52.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/prometheus:v2.45.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/alertmanager:v0.27.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/alertmanager:v0.25.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/node-exporter:v1.8.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus/node-exporter:v1.6.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-operator:v0.74.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-operator:v0.66.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-config-reloader:v0.74.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/prometheus-operator/prometheus-config-reloader:v0.66.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/grafana:10.0.2
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/grafana-image-renderer:latest
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/curl:7.85.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/busybox:1.31.1
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/grafana/k8s-sidecar:1.24.6
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane/crossplane:v1.16.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane-contrib/provider-helm:v0.13.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/crossplane-contrib/provider-kubernetes:v0.13.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-apigateway:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-cloudwatch:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-cloudwatchlogs:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-dynamodb:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-ec2:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-eks:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-elasticache:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-iam:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-kms:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-lambda:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-rds:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-s3:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-sns:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-sqs:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-aws-vpc:v1.5.0
${PROGRAM} push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/upbound/provider-family-aws:v1.5.0