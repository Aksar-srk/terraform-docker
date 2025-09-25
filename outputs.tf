output "ec2_public_ip" {
  value = aws_eip.docker_eip.public_ip
}

output "nginx_url" {
  value = "http://${aws_eip.docker_eip.public_ip}"
}

output "node_app_url" {
  value = "http://${aws_eip.docker_eip.public_ip}:3000"
}
