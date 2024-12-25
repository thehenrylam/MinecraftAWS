variable "aws_region" {
    description = "The AWS region to create resources in."
    type        = string
}

variable "nickname" {
    description = "The deployment's identifier (nickname). Will be used to help name cloud assets (e.g. Nickname of 'apple-fritter' will result in the name of 'vpc-apple-fritter' for the VPC)"
    type        = string
}

variable "admin_ip_list" {
    description = "List of IP addresses allowed to access Jenkins via SSH, in CIDR notation"
    type        = list(string)
    validation {
        condition       = alltrue([for ip in var.admin_ip_list : provider::assert::cidrv4(ip)])
        error_message   = "Each IP address must be a valid CIDR block (e.g. 127.0.0.1/32)"
    }
}

variable "vpc_cidr_block" {
    description = "The CIDR block that the VPC will use"
    type        = string
    validation {
        condition       = provider::assert::cidrv4(var.vpc_cidr_block)
        error_message   = "The vpc_cidr_block must be a valid IPv4 CIDR notation, e.g., 10.0.0.0/16."
    }
}

variable "sbn_jenkins_cidr_block" {
    description = "The CIDR block of the subnet that Jenkins run on"
    type        = string
    validation {
        condition = provider::assert::cidrv4(var.sbn_jenkins_cidr_block)
        error_message = "The sbn_jenkins_cidr_block must be a valid IPv4 CIDR notation, e.g., 10.0.0.0/16."
    }
}

variable "jenkins_ec2_type" {
    description = "The EC2 instance type for the Jenkins instance"
    type        = string
}

variable "jenkins_ami_id" {
    description = "The AMI (Represented as an ID) that Jenkins will run on"
    type        = string
}

variable "jenkins_pem_filename" {
    description = "Private key filename (*.pem) to access the Jenkins instance"
    type        = string
    validation {
        condition       = can(regex(".*\\.pem$", var.jenkins_pem_filename))
        error_message   = "The filename MUST have a '.pem' as it's suffix"
    }
}
