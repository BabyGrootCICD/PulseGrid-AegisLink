# PostgreSQL Database

## Overview

This directory contains the PostgreSQL database schema, migrations, and seed data for the PulseGrid-AegisLink (AuraSync) platform.

## Structure

```
database/postgres/
├── schema.sql              # Complete database schema
├── migrations/
│   ├── 001_init.sql        # Initial schema creation
│   ├── 002_add_rbac.sql    # Role-based access control
│   └── 003_add_audit_logs.sql  # Partitioned audit logs
├── seeds/
│   └── dev_seed.sql        # Development test data
└── README.md
```

## Tables

### Core Tables
- `users` - User accounts, wallet addresses, RBAC roles
- `rooms` - Live/counseling room settings, E2EE status
- `room_participants` - Room participants and roles

### Counseling Tables
- `counselors` - Counselor profiles, specialties, rates
- `bookings` - Appointment records and status

### Payment Tables
- `tips` - Tip escrow transactions
- `withdrawals` - Withdrawal requests and blockchain transactions

### Compliance Tables
- `audit_logs` - Operation audit logs (partitioned by month)
- `age_verifications` - Age verification records

### IoT Tables
- `devices` - IoT device registration

### RBAC Tables
- `permissions` - System permissions
- `roles` - User roles
- `role_permissions` - Role-permission mapping
- `user_roles` - User-role mapping

## Migrations

### Running Migrations

```bash
# Using psql
psql -U aurasync -d aurasync -f database/postgres/migrations/001_init.sql
psql -U aurasync -d aurasync -f database/postgres/migrations/002_add_rbac.sql
psql -U aurasync -d aurasync -f database/postgres/migrations/003_add_audit_logs.sql

# Using Drizzle ORM
npm run db:migrate
```

### Migration Order
1. `001_init.sql` - Creates all base tables and indexes
2. `002_add_rbac.sql` - Adds RBAC tables and default roles/permissions
3. `003_add_audit_logs.sql` - Creates partitioned audit logs table

## Seed Data

### Development Seed

```bash
psql -U aurasync -d aurasync -f database/postgres/seeds/dev_seed.sql
```

Creates:
- 4 test users (admin, creator, counselor, audience)
- 2 test rooms (live stream, counseling)
- 1 counselor profile
- 1 test IoT device

## Partitioning

The `audit_logs` table is partitioned by month for better performance:

- Current partitions: 2026-07 through 2026-12
- Auto-creation: Use `create_monthly_partition()` function
- Retention: Use `drop_old_audit_partitions()` function (default: 12 months)

## Indexes

All tables have appropriate indexes for:
- Primary keys (UUID)
- Foreign keys
- Common query patterns (email, status, timestamps)
- Composite indexes for complex queries

## Environment Variables

```env
DATABASE_URL=postgresql://aurasync:aurasync_dev@localhost:5432/aurasync
POSTGRES_USER=aurasync
POSTGRES_PASSWORD=aurasync_dev
POSTGRES_DB=aurasync
```
