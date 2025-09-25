# main.tf

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create a new EC2 key pair from your public key
resource "aws_key_pair" "docker_key" {
  key_name   = var.ssh_key_name
  public_key = file(var.public_key_path)
}

# Create an EC2 instance to host Docker
resource "aws_instance" "docker_host" {
  ami             = "ami-0360c520857e3138f" # Ubuntu 22.04 LTS
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.docker_key.key_name
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id       = "subnet-064a38f726cb62cae"

  tags = {
    Name = "docker-host"
  }
}

# Create an Elastic IP and associate it with the EC2 instance
resource "aws_eip" "docker_eip" {
  instance = aws_instance.docker_host.id
}

# Create a security group to allow SSH and HTTP traffic
resource "aws_security_group" "docker_sg" {
  name        = "docker-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = "vpc-003506f72559404e4"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use a null_resource to run a remote provisioner to install Docker and run Nginx
resource "null_resource" "docker_setup" {
  triggers = {
    instance_id = aws_instance.docker_host.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_eip.docker_eip.public_ip
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su",
      "apt-get update -y",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update -y",
      "apt-get install -y docker-ce docker-ce-cli containerd.io",
      "usermod -aG docker ubuntu",
      "docker run -d -p 80:80 --name mynginx nginx:latest"
    ]
  }
}