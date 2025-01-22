module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "zantac-vpc"
  cidr                 = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = var.azs
  private_subnets      = var.private_subnet_cidr
  public_subnets       = var.public_subnet_cidr
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
}

# Security Group for Web Server
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow web traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################################

# Launch Template
resource "aws_launch_template" "web_server_template" {
  name          = "web-server-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    subnet_id                   = module.vpc.public_subnets[0]

  }

  iam_instance_profile {
    name = aws_iam_instance_profile.web_server_profile.name
  }

  user_data = base64encode(<<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y httpd
            sudo systemctl start httpd
            sudo systemctl enable httpd
            sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
            EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_auto_scaling" {
  name                = "web-auto-scaling-group"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = module.vpc.public_subnets

  launch_template {
    #id      = aws_launch_template.web_launch_template.id
    id      = aws_launch_template.web_server_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  #load_balancers            = [aws_lb.web_lb.id]
  target_group_arns = [aws_lb_target_group.web_target_group.arn]
}


# Load Balancer
resource "aws_lb" "web_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}

# IAM User for Web Server Restart
resource "aws_iam_user" "web_restart_user" {
  name = "web-restart-user"
}

# IAM Role for Web Server
resource "aws_iam_role" "web_server_role" {
  name = "web-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# IAM Instance Profile
resource "aws_iam_instance_profile" "web_server_profile" {
  name = "web-server-profile"
  role = aws_iam_role.web_server_role.name # Reference the role to associate with the profile
}



resource "aws_iam_policy" "web_restart_policy" {
  name        = "WebRestartPolicy"
  description = "Allow restarting web server"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:RebootInstances"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.web_restart_user.name
  policy_arn = aws_iam_policy.web_restart_policy.arn
}