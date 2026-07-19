# =============================================================================
# PulseGrid-AegisLink (AuraSync) Terraform Outputs
# =============================================================================

# Cloudflare
output "cloudflare_zone_name" {
  description = "Cloudflare zone name"
  value       = module.cloudflare.zone_name
}

output "cloudflare_workers_domain" {
  description = "Cloudflare Workers domain"
  value       = module.cloudflare.workers_domain
}

# Supabase
output "supabase_project_url" {
  description = "Supabase project URL"
  value       = module.supabase.project_url
}

output "supabase_anon_key" {
  description = "Supabase anonymous key"
  value       = module.supabase.anon_key
  sensitive   = true
}

output "supabase_service_role_key" {
  description = "Supabase service role key"
  value       = module.supabase.service_role_key
  sensitive   = true
}

output "supabase_db_connection_string" {
  description = "Supabase database connection string"
  value       = module.supabase.db_connection_string
  sensitive   = true
}

# MongoDB Atlas
output "mongodb_atlas_connection_string" {
  description = "MongoDB Atlas connection string"
  value       = module.mongodb_atlas.connection_string
  sensitive   = true
}

output "mongodb_atlas_cluster_name" {
  description = "MongoDB Atlas cluster name"
  value       = module.mongodb_atlas.cluster_name
}
