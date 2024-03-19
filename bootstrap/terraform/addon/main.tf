################################################################################
# Crossplane
################################################################################

module "crossplane" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.0"

  create = var.enable_crossplane

  # https://github.com/crossplane/crossplane/tree/master/cluster/charts/crossplane
  name             = try(var.crossplane.name, "crossplane")
  description      = try(var.crossplane.description, "A Helm chart to deploy crossplane project")
  namespace        = try(var.crossplane.namespace, "crossplane-system")
  create_namespace = try(var.crossplane.create_namespace, true)
  chart            = try(var.crossplane.chart, "crossplane")
  chart_version    = try(var.crossplane.chart_version, "1.15.0")
  repository       = try(var.crossplane.repository, "https://charts.crossplane.io/stable/")
  values           = try(var.crossplane.values, [])

  timeout                    = try(var.crossplane.timeout, null)
  repository_key_file        = try(var.crossplane.repository_key_file, null)
  repository_cert_file       = try(var.crossplane.repository_cert_file, null)
  repository_ca_file         = try(var.crossplane.repository_ca_file, null)
  repository_username        = try(var.crossplane.repository_username, null)
  repository_password        = try(var.crossplane.repository_password, null)
  devel                      = try(var.crossplane.devel, null)
  verify                     = try(var.crossplane.verify, null)
  keyring                    = try(var.crossplane.keyring, null)
  disable_webhooks           = try(var.crossplane.disable_webhooks, null)
  reuse_values               = try(var.crossplane.reuse_values, null)
  reset_values               = try(var.crossplane.reset_values, null)
  force_update               = try(var.crossplane.force_update, null)
  recreate_pods              = try(var.crossplane.recreate_pods, null)
  cleanup_on_fail            = try(var.crossplane.cleanup_on_fail, null)
  max_history                = try(var.crossplane.max_history, null)
  atomic                     = try(var.crossplane.atomic, null)
  skip_crds                  = try(var.crossplane.skip_crds, null)
  render_subchart_notes      = try(var.crossplane.render_subchart_notes, null)
  disable_openapi_validation = try(var.crossplane.disable_openapi_validation, null)
  wait                       = try(var.crossplane.wait, false)
  wait_for_jobs              = try(var.crossplane.wait_for_jobs, null)
  dependency_update          = try(var.crossplane.dependency_update, null)
  replace                    = try(var.crossplane.replace, null)
  lint                       = try(var.crossplane.lint, null)

  postrender    = try(var.crossplane.postrender, [])
  set           = try(var.crossplane.set, [])
  set_sensitive = try(var.crossplane.set_sensitive, [])

  tags = var.tags
}

