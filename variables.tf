variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed_terraform_deployment"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "Availability zone for EC2 instance_terraform_deployment"
  type        = string
}

variable "project_name" {
  description = "Project name used to name AWS resources_terraform_deployment"
  type        = string
  default     = "helpdesk_terraform_deployment"
}

#Classless Inter-Domain Routing -- VPC TOTAL SPACE 65.536 Ip´s
variable "vpc_cidr" {
  description = "CIDR block for the VPC_terraform_deployment"
  type        = string
  default     = "10.0.0.0/16"
}

#Classless Inter-Domain Routing -- Subnet TOTAL SPACE 256 Ip´s
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet_terraform_deployment"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type_terraform_deployment"
  type        = string
  default     = "t3.micro"
}

