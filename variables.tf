variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  default     = "devops-key"
}

variable "private_key_path" {
  description = "Path to your PEM private key file"
  default     = "C:/Users/aksar/devops.pem"  # Update if different
}
