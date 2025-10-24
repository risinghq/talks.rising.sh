# Los outputs son valores que Terraform muestra al final de una ejecución.
# Son útiles para obtener información clave como IPs o endpoints.

output "instance_ip" {
  description = "IP pública del servidor Django."
  value       = aws_instance.django_server.public_ip
}

output "app_url" {
  description = "URL de la aplicación."
  value       = "http://${aws_instance.django_server.public_ip}"
}

output "db_endpoint" {
  description = "Endpoint de la instancia de base de datos RDS para migraciones locales."
  value       = aws_db_instance.main.endpoint
}
