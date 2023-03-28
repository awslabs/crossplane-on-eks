output "eks_cluster_id" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_id
}
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${var.name} --region ${var.region}"
}
