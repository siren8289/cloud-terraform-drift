terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

# 로컬 Docker 엔진에 연결
provider "docker" {}

# Nginx 이미지 준비
resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

# Terraform이 관리할 컨테이너
resource "docker_container" "web" {
  name  = "terraform-drift-web"
  image = docker_image.nginx.image_id

  # Nginx 80 포트를 Mac 8090 포트에 연결
  ports {
    internal = 80
    external = 8090
  }
}
