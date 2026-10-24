output "instance_ip" {
  description = "Public IP of Django server"
  value       = aws_instance.django_server.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.django_server.public_ip}"
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}
