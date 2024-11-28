provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
