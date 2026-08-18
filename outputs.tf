output "ec2_public_ip" {
  description = "Public IP address of the HelpDesk-Api EC2 instance"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the HelpDesk-Api EC2 instance"
  value       = aws_instance.api.public_dns
}