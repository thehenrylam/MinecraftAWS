packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/amazon"
        }
    }
}

# Variables most likely to change
variable "docker_version_string" {
    type    = string
    default = "latest"
}
variable "github_url_nginx" {
    type    = string
    default = "https://github.com/thehenrylam/SimpleNginx.git"
}
variable "github_url_jenkins" {
    type    = string
    default = "https://github.com/thehenrylam/SimpleJenkins.git"
}

# Variables least likely to change
variable "ssh_username" {
    type    = string 
    default = "admin"
}
variable "home_directory" {
    type    = string 
    default = "/home/admin"
}

source "amazon-ebs" "jenkins" {
    ami_name = "mcaws-jenkins-v1"
    instance_type = "t4g.micro"
    region = "us-east-1"

    # Use Debian 12 as our base AMI
    source_ami = "ami-0789039e34e739d67"
    # Debian 12 uses "admin" as the default username, so use that
    ssh_username = "{{ user `ssh_username` }}"
}

build {
    sources = ["source.amazon-ebs.jenkins"]

    # Upload all needed scripts to the instance
    provisioner "file" {
        source      = "./jenkins_node/deploy_app_nginx.sh"
        destination = "{{ user `home_dir` }}/scripts/deploy_app_nginx.sh"
    }
    provisioner "file" {
        source      = "./jenkins_node/initialize_node_jenkins.sh"
        destination = "{{ user `home_dir` }}/scripts/initialize_node_jenkins.sh"
    }

    # Set up all permissions and execute initialize_node_jenkins.sh
    provisioner "shell" {
        script = "./jenkins_node/initialize_node_jenkins.sh"
        environment_vars = [
            "HOME_DIRECTORY={{ user `home_directory` }}", 
            "DOCKER_VERSION_STRING={{ user `docker_version_string` }}",
            "GITHUB_URL_NGINX={{ user `github_url_nginx` }}",
            "GITHUB_URL_JENKINS={{ user `github_url_jenkins` }}",
        ]
    }

    # Send the output to manifest.json
    post-processor "manifest" {
        output = "manifest.json"
    }
}

