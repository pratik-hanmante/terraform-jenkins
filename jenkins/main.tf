# =========================
# 🧩 Variable Definitions
# =========================

# AMI ID to use for the EC2 instance (e.g., Ubuntu, Amazon Linux)
variable "ami_id" {}

# EC2 instance type (e.g., t2.micro, t3.medium)
variable "instance_type" {}

# Tag name to assign to the EC2 instance (used for identification)
variable "tag_name" {}

# Public SSH key to create an AWS key pair for connecting to the instance
variable "public_key" {}

# Subnet ID where the EC2 instance will be launched
variable "subnet_id" {}

# Security group(s) allowing Jenkins (port 8080), SSH, etc.
variable "sg_for_jenkins" {}

# Boolean flag to associate a public IP address with the instance
variable "enable_public_ip_address" {}

# User data script to install and configure Jenkins on instance boot
variable "user_data_install_jenkins" {}


# =========================
# 🌐 Output Definitions
# =========================

# Output a ready-to-use SSH command for connecting to the EC2 instance
output "ssh_connection_string_for_ec2" {
  value = format(
    "%s%s",
    "ssh -i /Users/rahulwagh/.ssh/aws_ec2_terraform ubuntu@",
    aws_instance.jenkins_ec2_instance_ip.public_ip
  )
}

# Output the instance ID of the Jenkins EC2 instance
output "jenkins_ec2_instance_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.id
}

# Output the public IP address of the Jenkins EC2 instance
output "dev_proj_1_ec2_instance_public_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.public_ip
}


# =========================
# 🏗️ EC2 Instance Definition
# =========================

resource "aws_instance" "jenkins_ec2_instance_ip" {
  # The Amazon Machine Image (AMI) to use
  ami           = var.ami_id

  # The EC2 instance type
  instance_type = var.instance_type

  # Assign tags for identification in AWS console
  tags = {
    Name = var.tag_name
  }

  # The key pair name used for SSH authentication (must match the key pair below)
  key_name = "aws_ec2_terraform"

  # The subnet in which this instance will be launched
  subnet_id = var.subnet_id

  # One or more security groups to associate with this instance
  vpc_security_group_ids = var.sg_for_jenkins

  # Whether to associate a public IP (depends on subnet and VPC settings)
  associate_public_ip_address = var.enable_public_ip_address

  # Startup script to install Jenkins and dependencies
  user_data = var.user_data_install_jenkins

  # Enforce IMDSv2 (Instance Metadata Service v2) for better security
  metadata_options {
    http_endpoint = "enabled"   # Enable metadata endpoint
    http_tokens   = "required"  # Require IMDSv2 token usage
  }
}


# =========================
# 🔐 Key Pair Resource
# =========================

# Create or import an AWS key pair using the provided public SSH key
resource "aws_key_pair" "jenkins_ec2_instance_public_key" {
  key_name   = "aws_ec2_terraform"  # Name must match key_name in aws_instance
  public_key = var.public_key       # Public key content (e.g., from ~/.ssh/id_rsa.pub)
}
