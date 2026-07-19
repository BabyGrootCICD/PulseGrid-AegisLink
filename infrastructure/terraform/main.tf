# =============================================================================
# PulseGrid-AegisLink (AuraSync) Terraform Configuration
# =============================================================================

module "cloudflare" {
  source = "./modules/cloudflare"

  account_id    = var.cloudflare_account_id
  zone_id       = var.cloudflare_zone_id
  domain_name   = var.domain_name
  environment   = var.environment
}

module "supabase" {
  source = "./modules/supabase"

  project_id    = var.supabase_project_id
  db_password   = var.supabase_db_password
  environment   = var.environment
}

module "mongodb_atlas" {
  source = "./modules/mongodb-atlas"

  public_key   = var.mongodb_atlas_public_key
  private_key  = var.mongodb_atlas_private_key
  org_id       = var.mongodb_atlas_org_id
  project_id   = var.mongodb_atlas_project_id
  environment  = var.environment
}
