# OPENTOFU : VPC Cloud
# Purpose:
#   - Isolate this deployment from everything else via VPCs and Subnets
#   - Reduces risk of failures by limiting the scope which cloud assets can connect to

terraform {
    required_providers {
        assert = {
        source = "opentofu/assert"
        version = "0.14.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

locals {
    vpc_name    = "vpc-${var.nickname}"
    rtb_name    = "rtb-${var.nickname}"
    igw_name    = "igw-${var.nickname}"
}

# Create the VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = false

    tags = {
        Name = local.vpc_name
        Nickname = var.nickname
    }
}

# Manage the Default Route Table
resource "aws_default_route_table" "rtb" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    tags = {
        Name = local.rtb_name
        Nickname = var.nickname
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = local.igw_name
        Nickname = var.nickname
    }
}

# Add a Route to the Default Route Table for Internet Access
resource "aws_route" "default_route" {
    route_table_id         = aws_default_route_table.rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}
