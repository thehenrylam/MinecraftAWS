# OPENTOFU: Foundation Template
# Purpose: 
#   - Deploys and manages the state of foundational components of the deployment (See below comments for more details)
terraform {
    required_providers {
        assert = {
        source = "opentofu/assert"
        version = "0.14.0"
        }
    }
}

locals {
    vpc_name    = "vpc-${var.nickname}"
    rtb_name    = "rtb-${var.nickname}"
    igw_name    = "igw-${var.nickname}"

    cache_path  = "${path.module}/../_cache/"
}

# VPC - Everything in the project runs on it (Self-Explanatory)
module "vpc_cloud" {
    source          = "./vpc_cloud"
    aws_region      = var.aws_region
    nickname        = var.nickname
    # Networking
    vpc_cidr_block  = var.vpc_cidr_block
}

# S3 - A datarepo any resource can leverage (But mostly by Jenkins)
module "s3_datarepo" {
    source          = "./s3_datarepo"
    aws_region      = var.aws_region
    nickname        = var.nickname
}

# SecretsManager (Jenkins SSL) - Used to enable jenkins SSL
module "secretsmanager_jenkins_ssh" {
    source      = "./secretsmanager_jenkins_ssl"
    aws_region  = var.aws_region
    nickname    = var.nickname
    # Cache path to grab the files
    cache_path  = local.cache_path
}

# Execute packer build to generate an AMI for jenkins
data "external" "packer_output" {
  program = ["bash", "${path.module}/../../packer/test.pkr.sh", "${module.secretsmanager_jenkins_ssh.instance_profile_name}"]
}


