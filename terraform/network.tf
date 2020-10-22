#
# Get public and private subnet ids from remote state of network    
#

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket  = "tf-state-ap-southeast-1-421376589955"
    key     = "network.tfstate"
    region  = "ap-southeast-1"
  }
}