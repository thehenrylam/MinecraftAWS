terraform {
    required_providers {
        assert = {
        source = "opentofu/assert"
        version = "0.14.0"
        }
    }
}

locals {
    vpc_name    = "vpc-${var.nickname}"
}

data "aws_vpc" "vpc_cloud" {
    filter {
        name   = "tag:Name"
        values = ["${local.vpc_name}"]
    }
}

module "ec2_jenkins" {
    source                      = "./ec2_jenkins"
    aws_region                  = var.aws_region
    nickname                    = var.nickname
    # Networking
    vpc_id                      = data.aws_vpc.vpc_cloud.id
    sbn_jenkins_cidr_block      = var.sbn_jenkins_cidr_block
    # TODO: On Destroy, stop the EC2 instance before it destroys the IGW, and detach the volume before destroying it
    # TO-TEST: Elastic IP to assign onto Jenkins (Or can be set as an output)
    # Admin IPs (For SSH Access)
    admin_ip_list               = var.admin_ip_list
    # Jenkins Settings
    jenkins_instance_profile    = var.jenkins_instance_profile
    jenkins_availability_zone   = var.jenkins_availability_zone
    jenkins_eipalloc_id         = var.jenkins_eipalloc_id
    jenkins_ec2_type            = var.jenkins_ec2_type
    jenkins_vol_size            = var.jenkins_vol_size
    jenkins_vol_type            = var.jenkins_vol_type
    jenkins_ami_id              = var.jenkins_ami_id
    jenkins_pem_filename        = var.jenkins_pem_filename
}
