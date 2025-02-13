provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Use the specified VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-0567dd68a6f03a784"
}

# Create a public subnet within the specified VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.aws_vpc.existing_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Ensure instances in this subnet get a public IP

  tags = {
    Name = "terraform-ec2-test-public-subnet"
  }
}

# Create an Internet Gateway for the specified VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.existing_vpc.id

  tags = {
    Name = "terraform-ec2-test-igw"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.existing_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-ec2-test-public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group allowing SSH access within the specified VPC
resource "aws_security_group" "ssh_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

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
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "terraform-ec2-test-instance"
  }
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
