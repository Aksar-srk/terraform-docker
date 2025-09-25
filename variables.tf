variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "private_key_path" {
  description = "Path to your AWS PEM private key"
  default     = "C:\\Users\\aksar\\devops.pem"
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  default     = "ami-0c02fb55956c7d316" # N. Virginia Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"  # Free Tier
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GB"
  default     = 8
}
