# Frequently Asked Questions

## Timeouts on destroy

Customers who are deleting their environments using `terraform destroy` may see timeout errors when VPCs are being deleted. This is due to a known issue in the [vpc-cni](https://github.com/aws/amazon-vpc-cni-k8s/issues/1223#issue-704536542)

Customers may face a situation where ENIs that were attached to EKS managed nodes (same may apply to self-managed nodes) are not being deleted by the VPC CNI as expected which leads to IaC tool failures, such as:

* ENIs are left on subnets
* EKS managed security group which is attached to the ENI can’t be deleted by EKS

The current recommendation is to execute cleanup in the following order:

1. delete all pods that have been created in the cluster.
2. add delay/ wait
3. delete VPC CNI
4. delete nodes
5. delete cluster