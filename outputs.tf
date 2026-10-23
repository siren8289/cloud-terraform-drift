output "container_id" {
  description = "Terraform managed Docker container ID"
  value       = docker_container.web.id
}

output "web_url" {
  description = "Local Nginx URL"
  value       = "http://localhost:8090"
}
