# outputs.tf

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_eip.docker_eip.public_ip
}

output "nginx_url" {
  description = "The URL to access the Nginx container."
  value       = "http://${aws_eip.docker_eip.public_ip}:80"
}