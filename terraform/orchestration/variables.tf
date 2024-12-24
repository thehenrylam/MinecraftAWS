variable "aws_region" {
    description = "The AWS region to create resources in."
    type = string
}

variable "nickname" {
    description = "The deployment's identifier (nickname). Will be used to help name cloud assets (e.g. Nickname of 'apple-fritter' will result in the name of 'vpc-apple-fritter' for the VPC)"
}

variable "vpc_cidr_block" {
    description = "The CIDR block that the VPC will use"
    type = string
    validation {
        condition = provider::assert::cidrv4(var.vpc_cidr_block)
        error_message = "The vpc_cidr_block must be a valid IPv4 CIDR notation, e.g., 10.0.0.0/16."
    }
}
