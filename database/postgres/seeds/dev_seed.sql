-- =============================================================================
-- Development Seed Data
-- =============================================================================

-- Insert test users (password: test123456 - bcrypt hash)
INSERT INTO users (id, email, password_hash, display_name, role, wallet_address) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'admin@aurasync.dev', '$2a$10$YourHashHere', 'Admin User', 'admin', '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18'),
    ('550e8400-e29b-41d4-a716-446655440002', 'creator@aurasync.dev', '$2a$10$YourHashHere', 'Test Creator', 'creator', '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD19'),
    ('550e8400-e29b-41d4-a716-446655440003', 'counselor@aurasync.dev', '$2a$10$YourHashHere', 'Dr. Test Counselor', 'counselor', '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD20'),
    ('550e8400-e29b-41d4-a716-446655440004', 'audience@aurasync.dev', '$2a$10$YourHashHere', 'Test Audience', 'audience', '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD21');

-- Insert test rooms
INSERT INTO rooms (id, name, description, type, creator_id, is_e2ee) VALUES
    ('660e8400-e29b-41d4-a716-446655440001', 'Live Stream Test Room', 'Test live streaming room', 'live_stream', '550e8400-e29b-41d4-a716-446655440002', FALSE),
    ('660e8400-e29b-41d4-a716-446655440002', 'Private Counseling Room', 'E2EE counseling session', 'counseling', '550e8400-e29b-41d4-a716-446655440003', TRUE);

-- Insert counselor profile
INSERT INTO counselors (user_id, specialty, bio, hourly_rate, is_available) VALUES
    ('550e8400-e29b-41d4-a716-446655440003', 'Sexual Health & Wellness', 'Experienced counselor specializing in adult industry mental health.', 75.00, TRUE);

-- Insert test device
INSERT INTO devices (user_id, name, type, firmware_version, status) VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 'Test IoT Device', 'smart_vibrator', '1.0.0', 'offline');
