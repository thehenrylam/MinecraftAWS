variable "aws_region" {
    description = "The AWS region to create resources in."
    type        = string
}

variable "vpc_id" {
    description = "ID of the VPC (Virtual Private Cloud) that the deployment will operate in"
    type        = string
}

variable "sbn_jenkins_cidr_block" {
    description = "The CIDR block of the subnet that Jenkins run on"
    type        = string
    validation {
        condition = provider::assert::cidrv4(var.sbn_jenkins_cidr_block)
        error_message = "The sbn_jenkins_cidr_block must be a valid IPv4 CIDR notation, e.g., 10.0.0.0/16."
    }
}

variable "admin_ip_list" {
    description = "List of IP addresses allowed to access Jenkins via SSH, in CIDR notation"
    type        = list(string)
    validation {
        condition       = alltrue([for ip in var.admin_ip_list : provider::assert::cidrv4(ip)])
        error_message   = "Each IP address must be a valid CIDR block (e.g. 127.0.0.1/32)"
    }
}

variable "jenkins_availability_zone" {
    description = "The availability zone for the Jenkins instance to exist on"
    type        = string
}

variable "jenkins_eipalloc_id" {
    description = "Elastic IP Allocation to be assigned to the Jenkins instance (represented as ID)"
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

variable "jenkins_sbn_name" {
    description = "Subnet name for Jenkins instance"
    type        = string
}

variable "jenkins_eni_name" {
    description = "Elastic Network Interface for Jenkins instance"
    type        = string
}

variable "jenkins_ec2_name" {
    description = "EC2 Jenkins instance name"
    type        = string
}

variable "jenkins_ec2_type" {
    description = "EC2 Jenkins instance type"
    type        = string
}

variable "jenkins_vol_name" {
    description = "EC2 Jenkins volume name"
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

variable "jenkins_ami_id" {
    description = "EC2 Jenkins instance AMI ID"
    type        = string
}

variable "jenkins_sg_name" {
    description = "Security Group name for Jenkins instance"
    type        = string
}

variable "jenkins_kp_name" {
    description = "Keypair Name for Jenkins instance"
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
