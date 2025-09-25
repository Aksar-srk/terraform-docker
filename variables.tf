# variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "The name of the AWS EC2 key pair to use for the instance."
  type        = string
}

variable "public_key_path" {
  description = "The path to the local public key file for the EC2 key pair."
  type        = string
}

variable "private_key_path" {
  description = "The path to the local private key file for SSH access."
  type        = string
}