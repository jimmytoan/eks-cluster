#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_security_group" "eks-cluster" {
  name = "eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id = data.terraform_remote_state.network.outputs.vpc

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks"
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-node.id}"
  to_port = 443
  type = "ingress"
}

resource "aws_eks_cluster" "eks" {
  name = "${var.cluster-name}"
  role_arn = "${aws_iam_role.eks-cluster.arn}"
  version = "1.18"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids = data.terraform_remote_state.network.outputs.private-subnets
    endpoint_private_access = true
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster",
    "aws_iam_role_policy_attachment.eks-service"
  ]

  enabled_cluster_log_types = ["api", "audit"] # authenticator, controllerManager, scheduler
}
