variable "docker_username" {
  description = "Docker username for authentication"
  type        = string
}

variable "docker_password" {
  description = "Docker password for authentication"
  type        = string
  sensitive   = true
}
