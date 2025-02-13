provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "foo" {
  ami           = "ami-05fa00d4c63e32376" # Ensure this AMI is available in us-east-1
  instance_type = "t2.micro"
  subnet_id     = "subnet-0e9023d44a1f96322" # Subnet in the specified VPC
  vpc_security_group_ids = ["sg-092816b294b0010e2"] # Use the existing security group

  tags = {
    Name = "TF-Instance"
  }
}
