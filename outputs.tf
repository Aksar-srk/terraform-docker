output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.docker_host.public_ip
}

output "nginx_url" {
  description = "URL for Nginx container"
  value       = "http://${aws_instance.docker_host.public_ip}"
}

output "node_app_url" {
  description = "URL for Node.js container"
  value       = "http://${aws_instance.docker_host.public_ip}:3000"
}
