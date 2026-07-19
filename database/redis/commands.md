# =============================================================================
# Redis Commands for AuraSync Platform
# =============================================================================

# Room State Management
# =============================================================================

# Create room state
HSET room:{room_id} name "{name}" type "{type}" creator_id "{creator_id}" status "active" participants 0 created_at {timestamp}

# Get room state
HGETALL room:{room_id}

# Add participant to room
SADD room:{room_id}:participants {user_id}
HINCRBY room:{room_id} participants 1

# Remove participant from room
SREM room:{room_id}:participants {user_id}
HINCRBY room:{room_id} participants -1

# Get room participant count
SCARD room:{room_id}:participants

# Check if user is in room
SISMEMBER room:{room_id}:participants {user_id}

# Set room expiry (24 hours)
EXPIRE room:{room_id} 86400

# Tip Queue
# =============================================================================

# Add tip to queue
LPUSH tips:pending "{tip_json}"

# Process tip (move to processing)
RPOPLPUSH tips:pending tips:processing

# Mark tip as completed
LREM tips:processing 1 "{tip_json}"
LPUSH tips:completed "{tip_json}"

# Get pending tips count
LLEN tips:pending

# Permission Token Cache
# =============================================================================

# Store permission token
SET token:{user_id}:access "{token_json}" EX 3600

# Get permission token
GET token:{user_id}:access

# Revoke token
DEL token:{user_id}:access

# IoT Device State
# =============================================================================

# Set device online status
SET device:{device_id}:status "online" EX 300

# Get device status
GET device:{device_id}:status

# Store device telemetry
LPUSH telemetry:{device_id} "{telemetry_json}"
LTRIM telemetry:{device_id} 0 999  # Keep last 1000 readings

# Rate Limiting
# =============================================================================

# Check rate limit (sliding window)
MULTI
INCR ratelimit:{user_id}:{endpoint}
EXPIRE ratelimit:{user_id}:{endpoint} 60
EXEC

# Session Management
# =============================================================================

# Store session
SET session:{session_id} "{session_json}" EX 86400

# Get session
GET session:{session_id}

# Delete session
DEL session:{session_id}

# Pub/Sub for Real-time Updates
# =============================================================================

# Subscribe to room events
SUBSCRIBE room:{room_id}:events

# Publish room event
PUBLISH room:{room_id}:events "{event_json}"

# Leaderboard (for tips/earnings)
# =============================================================================

# Update creator earnings
ZINCRBY leaderboard:earnings {amount} {creator_id}

# Get top earners
ZREVRANGE leaderboard:earnings 0 9 WITHSCORES

# Get creator rank
ZREVRANK leaderboard:earnings {creator_id}
