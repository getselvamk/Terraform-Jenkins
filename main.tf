provider "aws" {
  region = "eu-west-1" # Change to your preferred region if needed
}

# Use the specified VPC ID directly
variable "vpc_id" {
  default = "vpc-0567dd68a6f03a784"
}

# Use the specified subnet ID directly
variable "subnet_id" {
  default = "subnet-0e9023d44a1f96322"
}

# Use the specified internet gateway ID directly
variable "internet_gateway_id" {
  default = "igw-02762816e70e63c54"
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "terraform-ec2-test-public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group allowing SSH access within the specified VPC
resource "aws_security_group" "ssh_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "terraform-ec2-test-ssh-sg"
  }
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in eu-west-1
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "terraform-ec2-test-instance"
  }
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
