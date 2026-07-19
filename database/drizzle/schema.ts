import { pgTable, uuid, varchar, text, boolean, integer, decimal, timestamp, jsonb, pgEnum } from 'drizzle-orm/pg-core';

// =============================================================================
// ENUM TYPES
// =============================================================================

export const userRoleEnum = pgEnum('user_role', ['audience', 'creator', 'counselor', 'admin']);
export const roomTypeEnum = pgEnum('room_type', ['live_stream', 'counseling', 'private']);
export const roomStatusEnum = pgEnum('room_status', ['active', 'ended', 'scheduled']);
export const bookingStatusEnum = pgEnum('booking_status', ['pending', 'confirmed', 'cancelled', 'completed']);
export const tipStatusEnum = pgEnum('tip_status', ['pending', 'held', 'released', 'refunded', 'failed']);
export const withdrawalStatusEnum = pgEnum('withdrawal_status', ['pending', 'processing', 'completed', 'failed']);
export const verificationMethodEnum = pgEnum('verification_method', ['worldid', 'yoti']);
export const deviceStatusEnum = pgEnum('device_status', ['online', 'offline', 'error', 'maintenance']);
export const auditActionEnum = pgEnum('audit_action', ['login', 'logout', 'create', 'update', 'delete', 'verify', 'withdraw', 'tip']);

// =============================================================================
// CORE TABLES
// =============================================================================

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: varchar('email', { length: 255 }).unique().notNull(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  displayName: varchar('display_name', { length: 100 }),
  role: userRoleEnum('role').notNull().default('audience'),
  walletAddress: varchar('wallet_address', { length: 255 }),
  avatarUrl: text('avatar_url'),
  isVerified: boolean('is_verified').default(false),
  isBanned: boolean('is_banned').default(false),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const rooms = pgTable('rooms', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  description: text('description'),
  type: roomTypeEnum('type').notNull().default('live_stream'),
  status: roomStatusEnum('status').notNull().default('active'),
  creatorId: uuid('creator_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  isE2ee: boolean('is_e2ee').default(false),
  maxParticipants: integer('max_participants').default(100),
  streamKey: varchar('stream_key', { length: 255 }),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const roomParticipants = pgTable('room_participants', {
  id: uuid('id').defaultRandom().primaryKey(),
  roomId: uuid('room_id').notNull().references(() => rooms.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  role: varchar('role', { length: 50 }).default('viewer'),
  joinedAt: timestamp('joined_at').defaultNow(),
  leftAt: timestamp('left_at'),
});

// =============================================================================
// COUNSELING TABLES
// =============================================================================

export const counselors = pgTable('counselors', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').unique().notNull().references(() => users.id, { onDelete: 'cascade' }),
  specialty: varchar('specialty', { length: 255 }).notNull(),
  bio: text('bio'),
  hourlyRate: decimal('hourly_rate', { precision: 10, scale: 2 }),
  isAvailable: boolean('is_available').default(true),
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0.00'),
  totalSessions: integer('total_sessions').default(0),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const bookings = pgTable('bookings', {
  id: uuid('id').defaultRandom().primaryKey(),
  counselorId: uuid('counselor_id').notNull().references(() => counselors.id, { onDelete: 'cascade' }),
  clientId: uuid('client_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  roomId: uuid('room_id').references(() => rooms.id, { onDelete: 'set null' }),
  scheduledAt: timestamp('scheduled_at').notNull(),
  durationMinutes: integer('duration_minutes').default(60),
  status: bookingStatusEnum('status').notNull().default('pending'),
  notes: text('notes'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// =============================================================================
// PAYMENT TABLES
// =============================================================================

export const tips = pgTable('tips', {
  id: uuid('id').defaultRandom().primaryKey(),
  senderId: uuid('sender_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  recipientId: uuid('recipient_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  roomId: uuid('room_id').references(() => rooms.id, { onDelete: 'set null' }),
  amount: decimal('amount', { precision: 20, scale: 6 }).notNull(),
  currency: varchar('currency', { length: 10 }).default('USDC'),
  txHash: varchar('tx_hash', { length: 255 }),
  status: tipStatusEnum('status').notNull().default('pending'),
  releasedAt: timestamp('released_at'),
  createdAt: timestamp('created_at').defaultNow(),
});

export const withdrawals = pgTable('withdrawals', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  amount: decimal('amount', { precision: 20, scale: 6 }).notNull(),
  currency: varchar('currency', { length: 10 }).default('USDC'),
  walletAddress: varchar('wallet_address', { length: 255 }).notNull(),
  txHash: varchar('tx_hash', { length: 255 }),
  status: withdrawalStatusEnum('status').notNull().default('pending'),
  processedAt: timestamp('processed_at'),
  createdAt: timestamp('created_at').defaultNow(),
});

// =============================================================================
// COMPLIANCE TABLES
// =============================================================================

export const auditLogs = pgTable('audit_logs', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),
  action: auditActionEnum('action').notNull(),
  resource: varchar('resource', { length: 255 }),
  resourceId: uuid('resource_id'),
  details: jsonb('details'),
  ipAddress: varchar('ip_address', { length: 45 }),
  userAgent: text('user_agent'),
  createdAt: timestamp('created_at').defaultNow(),
});

export const ageVerifications = pgTable('age_verifications', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  method: verificationMethodEnum('method').notNull(),
  verifiedAt: timestamp('verified_at').defaultNow(),
  expiresAt: timestamp('expires_at'),
  tokenHash: varchar('token_hash', { length: 255 }),
  createdAt: timestamp('created_at').defaultNow(),
});

// =============================================================================
// IOT TABLES
// =============================================================================

export const devices = pgTable('devices', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  type: varchar('type', { length: 100 }),
  firmwareVersion: varchar('firmware_version', { length: 50 }),
  status: deviceStatusEnum('status').notNull().default('offline'),
  lastSeen: timestamp('last_seen'),
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// =============================================================================
// RBAC TABLES
// =============================================================================

export const permissions = pgTable('permissions', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: varchar('name', { length: 100 }).unique().notNull(),
  description: text('description'),
  resource: varchar('resource', { length: 100 }).notNull(),
  action: varchar('action', { length: 50 }).notNull(),
  createdAt: timestamp('created_at').defaultNow(),
});

export const roles = pgTable('roles', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: varchar('name', { length: 50 }).unique().notNull(),
  description: text('description'),
  isDefault: boolean('is_default').default(false),
  createdAt: timestamp('created_at').defaultNow(),
});

export const rolePermissions = pgTable('role_permissions', {
  roleId: uuid('role_id').notNull().references(() => roles.id, { onDelete: 'cascade' }),
  permissionId: uuid('permission_id').notNull().references(() => permissions.id, { onDelete: 'cascade' }),
});

export const userRoles = pgTable('user_roles', {
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  roleId: uuid('role_id').notNull().references(() => roles.id, { onDelete: 'cascade' }),
  assignedAt: timestamp('assigned_at').defaultNow(),
});
