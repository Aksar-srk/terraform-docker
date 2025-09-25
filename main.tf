terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Security Group
resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Allow SSH, HTTP, Node.js"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

# EC2 Instance
resource "aws_instance" "docker_host" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "devops-key"
  security_groups = [aws_security_group.docker_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -aG docker ec2-user
  EOF

  tags = {
    Name = "docker-ec2"
  }
}

# Elastic IP
resource "aws_eip" "docker_eip" {
  instance = aws_instance.docker_host.id
}

# Docker provider to connect to EC2
provider "docker" {
  host        = "ssh://ec2-user@${aws_eip.docker_eip.public_ip}"
  private_key = file("C:/Users/aksar/devops.pem")
}

# Docker Images
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

resource "docker_image" "node_image" {
  name = "node:18"
}

# Docker Containers
resource "docker_container" "nginx_container" {
  name  = "nginx"
  image = docker_image.nginx_image.latest

  ports {
    internal = 80
    external = 80
  }
}

resource "docker_container" "node_container" {
  name  = "node-app"
  image = docker_image.node_image.latest

  ports {
    internal = 3000
    external = 3000
  }

  command = ["bash", "-c", "npm install -g http-server && echo 'Hello from Node.js' > index.html && http-server -p 3000"]
}

# Outputs
output "ec2_public_ip" {
  value = aws_eip.docker_eip.public_ip
}

output "nginx_url" {
  value = "http://${aws_eip.docker_eip.public_ip}"
}

output "node_app_url" {
  value = "http://${aws_eip.docker_eip.public_ip}:3000"
}
