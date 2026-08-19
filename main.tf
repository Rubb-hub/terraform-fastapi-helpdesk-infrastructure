terraform {
  required_version = ">= 1.6.0"
}

#Creates VPC with the specified CIDR block. The VPC is tagged with the project name for easy identification.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#Creates a public subnet within the VPC with the specified CIDR block. The subnet is tagged with the project name for easy identification.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

#Allows instances in the VPC to access the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#Route table for the public subnet, allowing instances in the subnet to access the internet through the internet gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#Security group for the EC2 instance, allowing SSH and HTTP access from the specified CIDR block.
resource "aws_security_group" "api" {
  name        = "${var.project_name}-sg"
  description = "Security group for HelpDesk API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.api.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "HTTP access for Nginx"
}
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.api.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound traffic"
}

#EC2 instance for the HelpDesk API, using the specified instance type and security group. The instance is tagged with the project name for easy identification.
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] #OFFICIAL UBUNTU OWNER ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "api" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true #this is required to access the instance from the internet, as it is in a public subnet.

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.api.id
  ]

  user_data = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true #terraform will replace the instance if the user_data changes

  tags = {
    Name = "${var.project_name}-api"
  }
}

##SSM SessIon Manager IAM Role and Policy for the EC2 instance, allowing secure access to the instance without using SSH.
resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}