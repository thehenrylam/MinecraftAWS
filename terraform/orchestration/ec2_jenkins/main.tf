# OPENTOFU : EC2 Jenkins
# Purpose:
#   - Serves as the control node of a MinecraftAWS deployment

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

# EC2 Jenkins instance
resource "aws_instance" "ec2_jenkins" {
    ami             = var.jenkins_ami_id    # "ami-0789039e34e739d67"
    instance_type   = var.jenkins_ec2_type  # "t4g.micro"
    subnet_id       = aws_subnet.subnet_jenkins.id
    security_groups = [aws_security_group.sg_jenkins.id]

    # Associate KeyPair
    key_name = aws_key_pair.keypair_jenkins.key_name

    tags = {
        Name = var.jenkins_ec2_name # "ec2-mcaws-tango-jenkins"
    }
}

# EC2 Subnet for Jenkins
resource "aws_subnet" "subnet_jenkins" {
    vpc_id      = var.vpc_id 
    cidr_block  = var.sbn_jenkins_cidr_block

    tags = {
        Name = var.jenkins_sbn_name
    }
}

# Define a Security Group to allow SSH access to the EC2 instance
resource "aws_security_group" "sg_jenkins" {
    name        = var.jenkins_sg_name # "sg-mcaws-tango-jenkins"
    description = "Security Group for Jenkins Instance"
    vpc_id      = var.vpc_id 

    tags = {
        Name = var.jenkins_sg_name # "sg-mcaws-tango-jenkins"
    }

    # Ingress rules
    ingress {
        description = "Allow SSH from Admin IP(s)"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.admin_ip_list  # The list of admin IPs that can SSH into the instance (represented as CIDR blocks)
    }

    ingress {
        description = "Allow HTTP traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTPS traffic"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Egress rules
    egress {
        description = "Allow outbound HTTP traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow outbound HTTPS traffic"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow outbound DNS queries"
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Keypair Setup 
resource "aws_key_pair" "keypair_jenkins" {
  key_name = var.jenkins_kp_name 
  public_key = tls_private_key.tls_key_jenkins.public_key_openssh
}

# Generate a TLS Private Key (Stored Locally)
resource "tls_private_key" "tls_key_jenkins" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

# Output the private key to a local file for future use
resource "local_file" "private_key" {
  content  = tls_private_key.tls_key_jenkins.private_key_pem
  filename = "${path.module}/${var.jenkins_pem_filename}"  # Path to store the private key
}
