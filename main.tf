terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "societe-numerique"

    workspaces {
      prefix = "website-"
    }
  }

  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}

variable "REGISTRY_ENDPOINT" {
  type        = string
  description = "Container Registry endpoint where your application container is stored"
}

variable "DEFAULT_PROJECT_ID" {
  type        = string
  description = "Project ID where your resources will be created"
}

variable "NEXT_PUBLIC_STRAPI_URL" {
  type        = string
  description = "URL of the Strapi API serving data to display"
}

locals {
  appName = "website"
}

resource "scaleway_container_namespace" "main" {
  name        = local.appName
  description = "Namespace created for serverless Website deployment"
  project_id  = var.DEFAULT_PROJECT_ID
}

resource "scaleway_container" "main" {
  name            = local.appName
  description     = "Container for Website"
  namespace_id    = scaleway_container_namespace.main.id
  registry_image  = "${var.REGISTRY_ENDPOINT}/website:latest"
  port            = 1337
  cpu_limit       = 1120
  memory_limit    = 4096
  min_scale       = 1
  max_scale       = 5
  timeout         = 600
  max_concurrency = 80
  privacy         = "public"
  protocol        = "http1"
  deploy          = true

  environment_variables = {
    "NEXT_PUBLIC_STRAPI_URL" = var.NEXT_PUBLIC_STRAPI_URL,
  }
  secret_environment_variables = {
  }
}

output "container_url" {
  value     = scaleway_container.main.domain_name
  sensitive = false
}

output "container_id" {
  value     = scaleway_container.main.id
  sensitive = false
}

