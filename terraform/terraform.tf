#
# Terraform Configuration
#

terraform {
  backend "s3" {
    bucket         = "tf-state-ap-southeast-1-421376589955"
    key            = "eks-cluster.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-lock"
  }
}