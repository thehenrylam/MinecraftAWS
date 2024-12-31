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
    # subnet_id       = aws_subnet.subnet_jenkins.id
    # security_groups = [aws_security_group.sg_jenkins.id]

    # Associate KeyPair
    key_name = aws_key_pair.keypair_jenkins.key_name

    root_block_device {
        volume_size = var.jenkins_vol_size # Size in GiB
        volume_type = var.jenkins_vol_type 
        encrypted = true
        delete_on_termination = true

        tags = {
            Name = var.jenkins_vol_name
        }        
    }

    # Set up the network interface for EC2 jenkins
    network_interface {
        network_interface_id = aws_network_interface.eni_jenkins.id
        device_index = 0
    }

    tags = {
        Name = var.jenkins_ec2_name 
    }
}

# EC2 Jenkins Elastic Network Interface (Have a valid attachment point for Elastic IP Allocation to associate to this interface)
resource "aws_network_interface" "eni_jenkins" {
    subnet_id = aws_subnet.subnet_jenkins.id
    security_groups = [aws_security_group.sg_jenkins.id]

    tags = {
        Name = var.jenkins_eni_name
    }
}

# EC2 Jenkins association from elastic IP allocation to elastic network interface 
resource "aws_eip_association" "eip_assoc_jenkins" {
    # If var.jenkins_eipalloc_id is null, then don't create this association 
    # If var.jenkins_eipalloc_id is NOT null, then create this association 
    count = var.jenkins_eipalloc_id != null ? 1 : 0
    
    allocation_id           = var.jenkins_eipalloc_id
    network_interface_id    = aws_network_interface.eni_jenkins.id
}

# EC2 Subnet for Jenkins
resource "aws_subnet" "subnet_jenkins" {
    vpc_id      = var.vpc_id 
    cidr_block  = var.sbn_jenkins_cidr_block
    map_public_ip_on_launch = var.jenkins_eipalloc_id != null ? false : true # true
    availability_zone = var.jenkins_availability_zone # "us-east-1a"

    tags = {
        Name = var.jenkins_sbn_name
    }
}

# Define a Security Group to allow SSH access to the EC2 instance
resource "aws_security_group" "sg_jenkins" {
    name        = var.jenkins_sg_name 
    description = "Security Group for Jenkins Instance"
    vpc_id      = var.vpc_id 

    tags = {
        Name = var.jenkins_sg_name 
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
