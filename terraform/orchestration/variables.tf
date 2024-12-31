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

variable "jenkins_availability_zone" {
    description = "The availability zone of that the Jenkins instance will exist on"
    type        = string
}

variable "jenkins_eipalloc_id" {
    description = "The Elastic IP allocation ID to be associated to Jenkins"
    type        = string
    default     = null

    validation {
        condition = (
            var.jenkins_eipalloc_id == null ||
            can(regex("^eipalloc-[0-9a-f]{17}$", var.jenkins_eipalloc_id))
        )
        error_message = "The jenkins_eipalloc_id must be null or a valid AWS Elastic IP Allocation ID, matching the pattern 'eipalloc-' followed by 17 hexadecimal characters."
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

variable "jenkins_vol_size" {
    description = "EC2 Jenkins volume size (GB)"
    type        = number
    default     = 12
    validation {
        condition       = var.jenkins_vol_size >= 8 && var.jenkins_vol_size <= 512 && floor(var.jenkins_vol_size) == var.jenkins_vol_size
        error_message   = "The jenkins_vol_size variable must be a positive integer between 8 and 512"
    }
}

variable "jenkins_vol_type" {
    description = "EC2 Jenkins volume type (e.g. gp2)"
    type        = string
    default     = "gp2"
}

variable "jenkins_vol_device_name" {
    description = "EC2 Jenkins volume device name (e.g. /dev/sda1)"
    type        = string
    default     = "/dev/sda1"
}

variable "jenkins_pem_filename" {
    description = "Private key filename (*.pem) to access the Jenkins instance"
    type        = string
    validation {
        condition       = can(regex(".*\\.pem$", var.jenkins_pem_filename))
        error_message   = "The filename MUST have a '.pem' as it's suffix"
    }
}
