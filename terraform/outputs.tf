#
# Outputs Configuration
#

output "eks-node-sg" {
  value = "${aws_security_group.eks-node.id}"
}

