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
}

module "vpc_cloud" {
    source          = "./vpc_cloud"
    aws_region      = var.aws_region
    vpc_name        = local.vpc_name
    rtb_name        = local.rtb_name
    igw_name        = local.igw_name
    vpc_cidr_block  = var.vpc_cidr_block
}

module "s3_datarepo" {
    source        = "./s3_datarepo"
    aws_region    = var.aws_region
    s3_name      = local.s3_name
}
