variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"   # N. Virginia
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID (Free Tier eligible)"
  default     = "ami-0c55b159cbfafe1f0" 
}

variable "public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ebs_volume_size" {
  description = "EBS root volume size in GB (Free Tier safe)"
  default     = 8
}
