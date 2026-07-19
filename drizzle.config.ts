import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './database/drizzle/schema.ts',
  out: './database/drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL || 'postgresql://aurasync:aurasync_dev@localhost:5432/aurasync',
  },
});
