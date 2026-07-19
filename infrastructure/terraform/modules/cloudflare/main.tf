# =============================================================================
# Cloudflare Module
# =============================================================================

variable "account_id" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "environment" {
  type = string
}

# DNS Records
resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = "api"
  content = "api-gateway.pulsegrid.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "ws" {
  zone_id = var.zone_id
  name    = "ws"
  content = "sfu-server.pulsegrid.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "mqtt" {
  zone_id = var.zone_id
  name    = "mqtt"
  content = "mqtt-broker.pulsegrid.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Firewall Rules
resource "cloudflare_firewall_rule" "block_bad_bots" {
  zone_id     = var.zone_id
  description = "Block bad bots"
  priority    = 1
  action      = "block"
  filter_id   = cloudflare_filter.block_bad_bots.id
}

resource "cloudflare_filter" "block_bad_bots" {
  zone_id     = var.zone_id
  description = "Match bad bots"
  expression  = "(cf.threat_score gt 10) or (cf.client.bot)"
}

# Rate Limiting
resource "cloudflare_rate_limit_rule" "api_rate_limit" {
  zone_id     = var.zone_id
  description = "API rate limit"
  priority    = 1
  
  match {
    request {
      url_pattern = "${var.domain_name}/api/*"
      methods     = ["GET", "POST", "PUT", "DELETE"]
    }
  }

  action {
    mode    = "simulate"
    timeout = 60
    response {
      status_code = 429
      body        = "{\"error\": \"Rate limit exceeded\"}"
      content_type = "application/json"
    }
  }

  ratelimit {
    period          = 60
    requests_per_period = 100
    mitigation_timeout = 600
  }
}

# WAF
resource "cloudflare_waf_rule" "block_sql_injection" {
  zone_id     = var.zone_id
  rule_id     = "100001"
  mode        = "on"
  description = "Block SQL injection attacks"
}

# Page Rules
resource "cloudflare_page_rule" "api_cache" {
  zone_id  = var.zone_id
  target   = "api.${var.domain_name}/*"
  priority = 1

  actions {
    cache_level       = "bypass"
    disable_security  = false
  }
}

# SSL/TLS
resource "cloudflare_zone_settings_override" "ssl" {
  zone_id = var.zone_id
  
  settings {
    ssl                      = "strict"
    min_tls_version          = "1.2"
    automatic_https_rewrites = true
    always_use_https         = true
  }
}

# Workers (Edge computing)
resource "cloudflare_worker_script" "edge_auth" {
  name    = "edge-auth-${var.environment}"
  account_id = var.account_id
  content = file("${path.module}/workers/edge-auth.js")
}

# Outputs
output "zone_name" {
  value = var.domain_name
}

output "workers_domain" {
  value = "workers.${var.domain_name}"
}
