variable "aws_region" {
  description = "La región de AWS para desplegar los recursos."
  type        = string
  default     = "us-east-2"
}

variable "secret_key" {
  description = "La SECRET_KEY de Django."
  type        = string
  sensitive   = true # Evita que Terraform muestre este valor en los logs.
}

variable "db_password" {
  description = "La contraseña para el usuario de la base de datos RDS."
  type        = string
  sensitive   = true
}

variable "ecr_repo_url" {
  description = "La URL completa del repositorio ECR (sin la etiqueta :latest)."
  type        = string
}
