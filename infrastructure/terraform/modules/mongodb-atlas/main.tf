# =============================================================================
# MongoDB Atlas Module
# =============================================================================

variable "public_key" {
  type = string
}

variable "private_key" {
  type      = string
  sensitive = true
}

variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

# MongoDB Atlas Project
resource "mongodbatlas_project" "aurasync" {
  name   = "aurasync-${var.environment}"
  org_id = var.org_id

  depends_on = []
}

# Free Tier Cluster (M0)
resource "mongodbatlas_cluster" "aurasync_free" {
  project_id = mongodbatlas_project.aurasync.id
  name       = "aurasync-${var.environment}"
  
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M0"

  mongo_db_major_version = "7.0"

  # Free tier options
  disk_size_gb = 0.5  # 512MB

  # Labels
  labels {
    key   = "environment"
    value = var.environment
  }

  labels {
    key   = "project"
    value = "aurasync"
  }
}

# Database Users
resource "mongodbatlas_database_user" "app_user" {
  project_id = mongodbatlas_project.aurasync.id
  username   = "aurasync-app-${var.environment}"
  password   = var.private_key  # Use a proper password in production
  
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "aurasync"
  }

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }
}

resource "mongodbatlas_database_user" "readonly_user" {
  project_id = mongodbatlas_project.aurasync.id
  username   = "aurasync-readonly-${var.environment}"
  password   = var.private_key  # Use a proper password in production
  
  auth_database_name = "admin"

  roles {
    role_name     = "read"
    database_name = "aurasync"
  }
}

# IP Access List
resource "mongodbatlas_project_ip_access_list" "allow_all" {
  project_id = mongodbatlas_project.aurasync.id
  cidr_block = "0.0.0.0/0"  # Restrict in production!
  comment    = "Allow all IPs (restrict in production)"
}

# Network Peering (for production)
# resource "mongodbatlas_network_peering" "aws_peering" {
#   project_id       = mongodbatlas_project.aurasync.id
#   container_id     = mongodbatlas_cluster.aurasync_free.container_id
#   provider_name    = "AWS"
#   aws_account_id   = var.aws_account_id
#   vpc_id           = var.vpc_id
#   cidr_block       = var.vpc_cidr
# }

# Outputs
output "connection_string" {
  value     = mongodbatlas_cluster.aurasync_free.connection_strings[0].standard_srv
  sensitive = true
}

output "cluster_name" {
  value = mongodbatlas_cluster.aurasync_free.name
}

output "project_id" {
  value = mongodbatlas_project.aurasync.id
}
