-- Migration 002: RBAC (Role-Based Access Control)
-- Created: 2026-07-19

-- Permissions table
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Roles table (extended from enum)
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Role permissions mapping
CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- User roles mapping (users can have multiple roles)
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- Insert default roles
INSERT INTO roles (name, description, is_default) VALUES
    ('audience', 'Regular audience member', TRUE),
    ('creator', 'Content creator', FALSE),
    ('counselor', 'Professional counselor', FALSE),
    ('moderator', 'Content moderator', FALSE),
    ('admin', 'System administrator', FALSE);

-- Insert default permissions
INSERT INTO permissions (name, description, resource, action) VALUES
    ('room:create', 'Create rooms', 'room', 'create'),
    ('room:read', 'View rooms', 'room', 'read'),
    ('room:update', 'Update rooms', 'room', 'update'),
    ('room:delete', 'Delete rooms', 'room', 'delete'),
    ('room:join', 'Join rooms', 'room', 'join'),
    ('tip:create', 'Send tips', 'tip', 'create'),
    ('tip:release', 'Release tips', 'tip', 'release'),
    ('booking:create', 'Create bookings', 'booking', 'create'),
    ('booking:manage', 'Manage bookings', 'booking', 'manage'),
    ('device:manage', 'Manage devices', 'device', 'manage'),
    ('user:read', 'View users', 'user', 'read'),
    ('user:update', 'Update users', 'user', 'update'),
    ('user:ban', 'Ban users', 'user', 'ban'),
    ('audit:read', 'View audit logs', 'audit', 'read'),
    ('admin:full', 'Full admin access', 'admin', 'full');

-- Assign permissions to roles
-- Audience
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'audience' AND p.name IN ('room:read', 'room:join', 'tip:create');

-- Creator
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'creator' AND p.name IN ('room:create', 'room:read', 'room:update', 'room:delete', 'room:join', 'tip:create', 'tip:release', 'device:manage');

-- Counselor
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'counselor' AND p.name IN ('room:create', 'room:read', 'room:update', 'room:join', 'booking:create', 'booking:manage');

-- Moderator
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'moderator' AND p.name IN ('room:read', 'user:read', 'user:update', 'user:ban', 'audit:read');

-- Admin
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'admin' AND p.name IN ('admin:full');

-- Indexes
CREATE INDEX idx_roles_name ON roles(name);
CREATE INDEX idx_permissions_resource ON permissions(resource);
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
