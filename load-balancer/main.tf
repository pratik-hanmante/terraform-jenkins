# =========================
# 🧩 Variable Definitions
# =========================

# Load balancer name
variable "lb_name" {}

# Load balancer type (application or network)
variable "lb_type" {}

# Flag to specify if the LB is internal (false = external)
variable "is_external" { 
  default = false 
}

# Security group ID(s) for the load balancer (e.g., allow HTTP/HTTPS/SSH)
variable "sg_enable_ssh_https" {}

# Subnets where the LB will be deployed
variable "subnet_ids" {}

# Common tag name for resources
variable "tag_name" {}

# ARN of the target group to attach instances to
variable "lb_target_group_arn" {}

# EC2 instance ID to register in the target group
variable "ec2_instance_id" {}

# Listener configuration for HTTP traffic
variable "lb_listner_port" {}
variable "lb_listner_protocol" {}
variable "lb_listner_default_action" {}

# Listener configuration for HTTPS traffic
variable "lb_https_listner_port" {}
variable "lb_https_listner_protocol" {}

# ACM certificate ARN for HTTPS listener
variable "dev_proj_1_acm_arn" {}

# Port used for the target group attachment
variable "lb_target_group_attachment_port" {}


# =========================
# 🌐 Outputs
# =========================

# Output the DNS name of the created load balancer
output "aws_lb_dns_name" {
  value = aws_lb.dev_proj_1_lb.dns_name
}

# Output the hosted zone ID of the load balancer
output "aws_lb_zone_id" {
  value = aws_lb.dev_proj_1_lb.zone_id
}


# =========================
# 🏗️ Resource Definitions
# =========================

# Create an AWS Load Balancer
resource "aws_lb" "dev_proj_1_lb" {
  name               = var.lb_name
  internal           = var.is_external           # false = internet-facing
  load_balancer_type = var.lb_type               # "application" or "network"
  security_groups    = [var.sg_enable_ssh_https] # attach SGs for inbound rules
  subnets            = var.subnet_ids            # list of subnets for LB

  enable_deletion_protection = false             # disable protection for easy cleanup

  tags = {
    Name = var.tag_name
  }
}

# Attach EC2 instance to target group
resource "aws_lb_target_group_attachment" "dev_proj_1_lb_target_group_attachment" {
  target_group_arn = var.lb_target_group_arn
  target_id        = var.ec2_instance_id
  port             = var.lb_target_group_attachment_port
}

# HTTP listener (example: port 80)
resource "aws_lb_listener" "dev_proj_1_lb_listner" {
  load_balancer_arn = aws_lb.dev_proj_1_lb.arn
  port              = var.lb_listner_port
  protocol          = var.lb_listner_protocol

  default_action {
    type             = var.lb_listner_default_action
    target_group_arn = var.lb_target_group_arn
  }
}

# HTTPS listener (example: port 443)
resource "aws_lb_listener" "dev_proj_1_lb_https_listner" {
  load_balancer_arn = aws_lb.dev_proj_1_lb.arn
  port              = var.lb_https_listner_port
  protocol          = var.lb_https_listner_protocol
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"  # Recommended AWS SSL policy
  certificate_arn   = var.dev_proj_1_acm_arn                  # ACM certificate for HTTPS

  default_action {
    type             = var.lb_listner_default_action
    target_group_arn = var.lb_target_group_arn
  }
}
