packer {
    required_plugins {
        amazon = {
            source  = "github.com/hashicorp/amazon"
            version = ">= 1.3.5"
        }
        ansible = {
            source  = "github.com/hashicorp/ansible"
            version = ">= 1.1.3"
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
    # The home directory (depends on the base AMI that its being used)
    home_directory = "/home/admin"

    # Ansible directory (Contains the variable files and template files)
    ansible_directory = "${local.home_directory}/ansible/"

    # The AMI name
    ami_name = "ami_${var.nickname}_jenkins"
    
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

    # Initialize the ${local.ansible_directory}/scripts/ folder to prevent upload issues
    provisioner "shell" {
        inline = [
            "mkdir -p ${local.ansible_directory}/scripts/",
        ]
    }

    # Upload Prerequisites: Software installation script
    provisioner "file" {
        source =        "./ansible_jenkins_node/scripts/apt_app_install.sh"
        destination =   "${local.ansible_directory}/scripts/apt_app_install.sh"
    }
    provisioner "file" {
        source =        "./ansible_jenkins_node/scripts/apt_app_check.sh"
        destination =   "${local.ansible_directory}/scripts/apt_app_check.sh"
    }
    # Upload Prerequisites: Ansible installation script
    provisioner "file" {
        source =        "./ansible_jenkins_node/scripts/debian_ansible_uninstall.sh"
        destination =   "${local.ansible_directory}/scripts/debian_ansible_uninstall.sh"
    }
    provisioner "file" {
        source =        "./ansible_jenkins_node/scripts/debian_ansible_install.sh"
        destination =   "${local.ansible_directory}/scripts/debian_ansible_install.sh"
    }

    # Install Prerequisites: Helper Software + Ansible 
    provisioner "shell" {
        inline = [
            "chmod +x ${local.ansible_directory}/scripts/*.sh",
            "cd ${local.ansible_directory}/",
            "sudo bash -x -c './scripts/apt_app_install.sh' 2>&1 | tee apt_app_install.log",
            "sudo bash -x -c './scripts/apt_app_check.sh' 2>&1 | tee apt_app_check.log",
            "sudo bash -x -c './scripts/debian_ansible_install.sh' 2>&1 | tee debian_ansible_install.log",
        ]
    }

    # Attempt to upload the ansible repo via ansible-local
    # The reason why this is done this way instead of using "file" provsioner 
    # is to workaround the issue of uploading ansible.cfg, which interferes with rawSCP
    # Which "[default]" tag causes it to crash
    provisioner "ansible-local" {
        # This is a workaround to copy over ./ansible_jenkins_node/ 
        # to the target directory without executing anything we don't want.
        playbook_dir  = "./ansible_jenkins_node/"
        playbook_file = "./ansible_jenkins_node/playbooks/utility-do-nothing.yml"
        # Upload everything into ${local.ansible_directory} instead
        staging_directory = "${local.ansible_directory}"
        # keep it around if you need to inspect it afterwards
        clean_staging_directory = false
    }

    # Upload the nginxconfig_jenkins.yml within the centralized config folder
    provisioner "file" {
        source =        "../ansible/template/config_packer/jenkins/nginxconfig_jenkins.yml"
        destination =   "${local.ansible_directory}/template/nginxconfig_jenkins.yml"
    }

    # Set up all permissions and execute initialize_node_jenkins.sh
    provisioner "shell" {
        inline = [
            "chmod +x ${local.ansible_directory}/scripts/*.sh",
            "cd ${local.ansible_directory}/",
            # software-install.yml installs the prereqs (Shouldn't be an issue since its idempotent) along with docker + ansible
            "sudo ansible-playbook playbooks/software-install.yml >> software-install.log 2>&1",
            # deploy-nginx.yml pulls from the nginx repo and deploys it into the ec2 instance.
            "sudo ansible-playbook playbooks/deploy-nginx.yml >> deploy-nginx.log 2>&1",
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

