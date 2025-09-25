variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-0c02fb55956c7d316"
}

variable "key_name" {
  description = "AWS key pair name"
  default     = "devops-key"
}
