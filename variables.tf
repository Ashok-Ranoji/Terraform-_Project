variable "region" {
  description = "AWS Region for deployment"
  #default     = "us-east-1"
  default = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for the web server"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the web server"
  type        = string
}

variable "key_name" {
  description = "Key pair for EC2 instances"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "azs" {
  description = "Availability Zones for the VPC"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnets"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired capacity of the autoscaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum size of the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the autoscaling group"
  type        = number
}
variable "lb_name" {
  description = "Name for the Load Balancer"
  default     = "web-lb"
}



