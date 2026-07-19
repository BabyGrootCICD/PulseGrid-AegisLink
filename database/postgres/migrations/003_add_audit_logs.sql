-- Migration 003: Enhanced Audit Logs & Partitioning
-- Created: 2026-07-19

-- Drop existing audit_logs table and recreate with partitioning
DROP TABLE IF EXISTS audit_logs;

-- Create partitioned audit_logs table
CREATE TABLE audit_logs (
    id UUID NOT NULL DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action audit_action NOT NULL,
    resource VARCHAR(255),
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions for current and future months
CREATE TABLE audit_logs_2026_07 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');

CREATE TABLE audit_logs_2026_08 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');

CREATE TABLE audit_logs_2026_09 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');

CREATE TABLE audit_logs_2026_10 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');

CREATE TABLE audit_logs_2026_11 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE audit_logs_2026_12 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

-- Create indexes on partitioned table
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- Create composite index for common queries
CREATE INDEX idx_audit_logs_user_action ON audit_logs(user_id, action);
CREATE INDEX idx_audit_logs_resource_action ON audit_logs(resource, action);

-- Function to auto-create monthly partitions
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS void AS $$
DECLARE
    next_month DATE;
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
BEGIN
    next_month := DATE_TRUNC('month', NOW() + INTERVAL '1 month');
    partition_name := 'audit_logs_' || TO_CHAR(next_month, 'YYYY_MM');
    start_date := DATE_TRUNC('month', next_month);
    end_date := start_date + INTERVAL '1 month';
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF audit_logs FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
END;
$$ LANGUAGE plpgsql;

-- Schedule partition creation (run monthly via pg_cron or external scheduler)
-- SELECT create_monthly_partition();

-- Data retention: function to drop old partitions
CREATE OR REPLACE FUNCTION drop_old_audit_partitions(months_to_keep INTEGER DEFAULT 12)
RETURNS void AS $$
DECLARE
    cutoff_date DATE;
    partition RECORD;
BEGIN
    cutoff_date := DATE_TRUNC('month', NOW() - (months_to_keep || ' months')::INTERVAL);
    
    FOR partition IN
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE 'audit_logs_%'
        AND tablename < 'audit_logs_' || TO_CHAR(cutoff_date, 'YYYY_MM')
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS %I.%I', partition.schemaname, partition.tablename);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
