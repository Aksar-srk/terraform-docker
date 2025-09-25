#########################################
# AWS Provider
#########################################
provider "aws" {
  region = var.aws_region
}

#########################################
# Key Pair
#########################################
resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-key"
  public_key = file(var.public_key_path)
}

#########################################
# Security Group
#########################################
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

#########################################
# EC2 Instance (Free Tier safe)
#########################################
resource "aws_instance" "docker_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.docker_sg.name]

  root_block_device {
    volume_size = var.ebs_volume_size
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -aG docker ec2-user
              EOF

  tags = { Name = "docker-ec2" }
}

#########################################
# Docker Provider (connect to EC2)
#########################################
provider "docker" {
  host           = "ssh://ec2-user@${aws_instance.docker_host.public_ip}"
  ssh_agent_auth = true
}

#########################################
# Docker Containers
#########################################
# Nginx Container
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

resource "docker_container" "nginx_container" {
  name  = "nginx"
  image = docker_image.nginx_image.latest
  ports {
    internal = 80
    external = 80
  }
}

# Node.js Container
resource "docker_image" "node_image" {
  name = "node:18"
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
