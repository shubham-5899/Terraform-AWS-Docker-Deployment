provider "aws" {
  region = "ap-south-1"
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "devops_sg" {
  name        = "terraform-devops-sg"
  description = "Allow SSH and App Port"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-devops-sg"
  }
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "devops_server" {
  ami                         = "ami-019715e0d74f695be"
  instance_type               = "t3.micro"
  key_name                    = "terraform-key"
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Wait for network
sleep 40

apt-get update -y
apt-get install -y docker.io

systemctl start docker
systemctl enable docker

sleep 20

docker pull shubham5899/devops-app:8

docker run -d -p 3000:3000 --name devops-container shubham5899/devops-app:8
EOF

  tags = {
    Name = "terraform-devops-server"
  }
}
