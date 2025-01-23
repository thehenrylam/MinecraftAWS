# AWS Operating Region
aws_region = "us-west-1"

# Main Settings
nickname = "mcaws-omega"
admin_ip_list = ["<<INSERT YOUR IP HERE>>"]

# Key Settings
jenkins_pem_filename    = "kp-mcaws-omega-jenkins.pem"

# CIDR Block Settings
vpc_cidr_block          = "172.16.0.0/16"
sbn_jenkins_cidr_block  = "172.16.0.0/24"

# Jenkins Settings
jenkins_availability_zone = "us-west-1a"
jenkins_eipalloc_id = null
jenkins_ec2_type = "t4g.micro"
jenkins_ami_id = "???" # <-- Replace this with the AMI that packer has created
jenkins_vol_size = 12
jenkins_vol_type = "gp2"
jenkins_vol_device_name = "/dev/sda1"
