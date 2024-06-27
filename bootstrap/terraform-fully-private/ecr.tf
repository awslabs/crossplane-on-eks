data "aws_secretsmanager_secret" "docker" {
  name = "ecr-pullthroughcache/docker"
}

locals {
  ecr_repos = [ 
    "ecr/eks/aws-load-balancer-controller",
    "docker-hub/curlimages/curl",
    "docker-hub/dexidp/dex",
    "docker-hub/grafana/grafana",
    "docker-hub/grafana/grafana-image-renderer",
    "docker-hub/library/busybox",
    "docker-hub/library/haproxy",
    "docker-hub/library/redis",
    "docker-hub/openpolicyagent/gatekeeper",
    "docker-hub/openpolicyagent/gatekeeper-crds",
    "docker-hub/prom/alertmanager",
    "docker-hub/prom/prometheus",
    "k8s/metrics-server/metrics-server",
    "k8s/kube-state-metrics/kube-state-metrics",
    "k8s/ingress-nginx/kube-webhook-certgen",
    "quay/argoproj/argocd",
    "quay/kiwigrid/k8s-sidecar",
    "quay/prometheus/alertmanager",
    "quay/prometheus/node-exporter",
    "quay/prometheus/prometheus",
    "quay/prometheus-operator/admission-webhook",
    "quay/prometheus-operator/prometheus-operator",
    "quay/prometheus-operator/prometheus-config-reloader"
  ]
}

resource "aws_ecr_repository" "ecr_repo" {
  for_each = toset(local.ecr_repos)

  name     = each.key
  image_scanning_configuration {
    scan_on_push = true
  }

  tags     = local.tags
}

resource "aws_ecr_pull_through_cache_rule" "docker-hub" {
  ecr_repository_prefix = "docker-hub"
  upstream_registry_url = "registry-1.docker.io"
  credential_arn = data.aws_secretsmanager_secret.docker.arn
}

resource "aws_ecr_pull_through_cache_rule" "ecr" {
  ecr_repository_prefix = "ecr"
  upstream_registry_url = "public.ecr.aws"
}

resource "aws_ecr_pull_through_cache_rule" "k8s" {
  ecr_repository_prefix = "k8s"
  upstream_registry_url = "registry.k8s.io"
}

resource "aws_ecr_pull_through_cache_rule" "quay" {
  ecr_repository_prefix = "quay"
  upstream_registry_url = "quay.io"
}
