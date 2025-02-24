packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/amazon"
        }
    }
}

variable "nickname" {
    type    = string
}
variable "aws_region" {
    type    = string
}
variable "instance_profile" {
    type    = string
}
variable "github_url_nginx" {
    type    = string
}
variable "github_url_jenkins" {
    type    = string
}

locals {
    # Ansible directory (Contains the variable files and template files)
    ansible_directory = "../ansible/"
    ansible_packer_jenkins_directory = "${local.ansible_directory}/template/config_packer/jenkins/"

    # The AMI name
    ami_name = "ami_${var.nickname}_jenkins"
    # The home directory (depends on the base AMI that its being used)
    home_directory = "/home/admin"
    # The docker version that will be installed
    docker_version_string = "5:27.4.0-1~debian.12~bookworm"
}

source "amazon-ebs" "jenkins" {
    ami_name = "${local.ami_name}"
    
    instance_type = "t4g.micro"
    region = "us-east-1"

    # Use Debian 12 as our base AMI
    source_ami = "ami-0789039e34e739d67"
    # Debian 12 uses "admin" as the default username, so use that
    ssh_username = "admin"

    iam_instance_profile = "${var.instance_profile}"

    tags = {
        Nickname = "${var.nickname}"
    }
}

build {
    sources = ["source.amazon-ebs.jenkins"]

    # Ensure the target directories exist before uploading files
    provisioner "shell" {
        inline = [
            "mkdir -p ${local.home_directory}/scripts/config",
            "mkdir -p ${local.home_directory}/scripts"
        ]
    }

    # Upload all needed scripts to the instance
    provisioner "file" {
        source      = "${local.ansible_packer_jenkins_directory}/nginxconfig_jenkins.yml"
        destination = "${local.home_directory}/scripts/config/nginxconfig_jenkins.yml"
    }
    provisioner "file" {
        source      = "./jenkins_node/common_functions.sh"
        destination = "${local.home_directory}/scripts/common_functions.sh"
    }
    provisioner "file" {
        source      = "./jenkins_node/deploy_app_jenkins.sh"
        destination = "${local.home_directory}/scripts/deploy_app_jenkins.sh"
    }
    provisioner "file" {
        source      = "./jenkins_node/deploy_app_nginx.sh"
        destination = "${local.home_directory}/scripts/deploy_app_nginx.sh"
    }
    provisioner "file" {
        source      = "./jenkins_node/initialize_node_jenkins.sh"
        destination = "${local.home_directory}/scripts/initialize_node_jenkins.sh"
    }

    # Set up all permissions and execute initialize_node_jenkins.sh
    provisioner "shell" {
        inline = [
            "chmod +x ${local.home_directory}/scripts/common_functions.sh",
            "chmod +x ${local.home_directory}/scripts/deploy_app_jenkins.sh",
            "chmod +x ${local.home_directory}/scripts/deploy_app_nginx.sh",
            "chmod +x ${local.home_directory}/scripts/initialize_node_jenkins.sh",
            "${local.home_directory}/scripts/initialize_node_jenkins.sh >> ${local.home_directory}/scripts/initialize_node_jenkins.log 2>&1"
        ]
        environment_vars = [
            "HOME_DIRECTORY=${local.home_directory}", 
            "DOCKER_VERSION_STRING=${local.docker_version_string}",
            "GITHUB_URL_NGINX=${var.github_url_nginx}",
            "GITHUB_URL_JENKINS=${var.github_url_jenkins}",
        ]
    }

    # Send the output to manifest.json
    post-processor "manifest" {
        output = "jenkins_manifest.json"
    }
}

