# =============================================================================
# Production Environment
# =============================================================================

project_name = "aurasync"
environment  = "prod"
region       = "us-east-1"

# Cloudflare (set via environment variables)
# cloudflare_account_id = ""
# cloudflare_zone_id    = ""
# cloudflare_api_token  = ""

domain_name = "aurasync.app"

# Supabase (set via environment variables)
# supabase_access_token = ""
# supabase_project_id   = ""
# supabase_db_password  = ""

# MongoDB Atlas (set via environment variables)
# mongodb_atlas_public_key   = ""
# mongodb_atlas_private_key  = ""
# mongodb_atlas_org_id       = ""
# mongodb_atlas_project_id   = ""

# Redis (use Upstash or managed Redis in production)
redis_password = ""  # Set via environment variable

# Web3
solana_rpc_url = "https://api.mainnet-beta.solana.com"
ethereum_rpc_url = ""  # Set via environment variable

# Age Verification (set via environment variables)
# yoti_client_sdk_id = ""
# worldcoin_app_id   = ""
