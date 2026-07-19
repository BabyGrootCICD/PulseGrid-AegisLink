# =============================================================================
# Supabase Module
# =============================================================================

variable "project_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
}

# Supabase Project (managed via API)
resource "supabase_project" "aurasync" {
  name           = "aurasync-${var.environment}"
  region         = "us-east-1"
  database_plan  = "free"
  organization_id = ""  # Set via environment variable
}

# Database Extensions
resource "supabase_database_extension" "uuid_ossp" {
  project_id = var.project_id
  name       = "uuid-ossp"
  enabled    = true
}

resource "supabase_database_extension" "pgcrypto" {
  project_id = var.project_id
  name       = "pgcrypto"
  enabled    = true
}

resource "supabase_database_extension" "pg_trgm" {
  project_id = var.project_id
  name       = "pg_trgm"
  enabled    = true
}

# API Settings
resource "supabase_api_setting" "jwt_settings" {
  project_id = var.project_id
  jwt_exp    = 3600
  jwt_aud    = "authenticated"
}

# Auth Settings
resource "supabase_auth_setting" "auth_config" {
  project_id = var.project_id
  
  enable_signup = true
  enable_anonymous_sign_ins = false
  
  external_email_enabled = true
  external_phone_enabled = false
  
  # Disable email confirmation for dev
  mailer_autoconfirm = var.environment == "dev" ? true : false
  sms_autoconfirm = false
}

# Storage Buckets
resource "supabase_storage_bucket" "avatars" {
  project_id = var.project_id
  name       = "avatars"
  public     = true
  file_size_limit = 5242880  # 5MB
  
  allowed_mime_types = ["image/jpeg", "image/png", "image/webp"]
}

resource "supabase_storage_bucket" "media" {
  project_id = var.project_id
  name       = "media"
  public     = false
  file_size_limit = 104857600  # 100MB
  
  allowed_mime_types = ["video/mp4", "video/webm", "audio/mpeg", "audio/wav"]
}

# RLS Policies (via SQL)
resource "supabase_database_function" "handle_new_user" {
  project_id = var.project_id
  name       = "handle_new_user"
  definition = <<-SQL
    CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS TRIGGER AS $$
    BEGIN
      INSERT INTO public.users (id, email, display_name, role)
      VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'audience')
      );
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
  SQL
}

# Outputs
output "project_url" {
  value = "https://${var.project_id}.supabase.co"
}

output "anon_key" {
  value     = ""  # Retrieved from Supabase dashboard
  sensitive = true
}

output "service_role_key" {
  value     = ""  # Retrieved from Supabase dashboard
  sensitive = true
}

output "db_connection_string" {
  value     = "postgresql://postgres:${var.db_password}@db.${var.project_id}.supabase.co:5432/postgres"
  sensitive = true
}
