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

variable "jenkins_sbn_name" {
    description = "Subnet name for Jenkins instance"
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
