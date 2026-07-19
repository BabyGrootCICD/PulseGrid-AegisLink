# =============================================================================
# PulseGrid-AegisLink (AuraSync) Terraform Variables
# =============================================================================

# General
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aurasync"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Primary region for deployment"
  type        = string
  default     = "us-east-1"
}

# Cloudflare
variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for DNS"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "aurasync.app"
}

# Supabase
variable "supabase_access_token" {
  description = "Supabase access token"
  type        = string
  sensitive   = true
}

variable "supabase_project_id" {
  description = "Supabase project ID"
  type        = string
}

variable "supabase_db_password" {
  description = "Supabase database password"
  type        = string
  sensitive   = true
}

# MongoDB Atlas
variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas public key"
  type        = string
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas private key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
}

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas project ID"
  type        = string
}

# Redis
variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
  default     = ""
}

# Web3
variable "solana_rpc_url" {
  description = "Solana RPC URL"
  type        = string
  default     = "https://api.mainnet-beta.solana.com"
}

variable "ethereum_rpc_url" {
  description = "Ethereum RPC URL"
  type        = string
  default     = ""
}

# Age Verification
variable "yoti_client_sdk_id" {
  description = "Yoti Client SDK ID"
  type        = string
  sensitive   = true
}

variable "worldcoin_app_id" {
  description = "Worldcoin application ID"
  type        = string
}
