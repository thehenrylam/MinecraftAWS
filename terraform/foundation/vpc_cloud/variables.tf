variable "aws_region" {
    description = "The AWS region to create resources in."
    type = string
}

variable "vpc_name" {
    description = "Name of the VPC (Virtual Private Cloud) that the deployment will operate in"
    type = string
}

variable "rtb_name" {
    description = "Name of the RTB (Route Table) associated to the VPC"
    type = string
}

variable "igw_name" {
    description = "Name of the IGW (Internet Gateway) that connects allows the VPC access to the internet and vice versa"
    type = string
}

variable "vpc_cidr_block" {
    description = "The CIDR block that the VPC will use"
    type = string
    validation {
        condition = provider::assert::cidrv4(var.vpc_cidr_block)
        error_message = "The vpc_cidr_block must be a valid IPv4 CIDR notation, e.g., 10.0.0.0/16."
    }
}
