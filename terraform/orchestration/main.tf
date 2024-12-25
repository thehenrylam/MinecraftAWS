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

    s3_name     = "s3b-${var.nickname}-datarepo"

    jenkins_sbn_name    = "subnet-${var.nickname}-jenkins"
    jenkins_ec2_name    = "ec2-${var.nickname}-jenkins"
    jenkins_sg_name     = "sgrp-${var.nickname}-jenkins"
    jenkins_kp_name     = "kp-${var.nickname}-jenkins"
}

# data "aws_vpc" "vpc" {
#   filter {
#     name   = "tag:Name"
#     values = ["${local.vpc_name}"]
#   }
# }

module "vpc_cloud" {
    source          = "./vpc_cloud"
    aws_region      = var.aws_region
    # Networking
    vpc_name        = local.vpc_name
    rtb_name        = local.rtb_name
    igw_name        = local.igw_name
    vpc_cidr_block  = var.vpc_cidr_block
}

module "s3_datarepo" {
    source          = "./s3_datarepo"
    aws_region      = var.aws_region
    # Datarepo Settings
    s3_name         = local.s3_name
}

module "ec2_jenkins" {
    source                  = "./ec2_jenkins"
    aws_region              = var.aws_region
    # Networking
    vpc_id                  = module.vpc_cloud.vpc_id
    sbn_jenkins_cidr_block  = var.sbn_jenkins_cidr_block
    # TODO: Boolean Flag To Enable Automatic IP Assignment
    # TODO: Elastic IP to assign onto Jenkins (Or can be set as an output)
    # Admin IPs (For SSH Access)
    admin_ip_list           = var.admin_ip_list
    # Jenkins Settings
    jenkins_sbn_name        = local.jenkins_sbn_name
    jenkins_ec2_name        = local.jenkins_ec2_name
    jenkins_ec2_type        = var.jenkins_ec2_type
    jenkins_ami_id          = var.jenkins_ami_id
    jenkins_sg_name         = local.jenkins_sg_name
    jenkins_kp_name         = local.jenkins_kp_name
    jenkins_pem_filename    = var.jenkins_pem_filename
}
