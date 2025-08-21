-- ============================================================================
-- Migration 013: Add users.preferences JSONB column to align with backend ORM
-- Purpose:
--   - Ensure the users table contains a JSON/JSONB "preferences" column as expected
--     by the FastAPI backend ORM (UserDB.preferences).
--   - Idempotent and safe to re-run in various environments.
-- Notes:
--   - Uses JSONB for indexing and efficiency in Postgres.
--   - Sets a default '{}'::jsonb and ensures NOTHING breaks if already present.
-- ============================================================================

-- 0) Ensure required extensions (uuid extension may already be present; harmless here)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1) Add the preferences column if it does not exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'preferences'
    ) THEN
        ALTER TABLE users
            ADD COLUMN preferences JSONB;
    END IF;
END$$;

-- 2) Set default and backfill NULLs to an empty object for consistency with backend
ALTER TABLE IF EXISTS users
    ALTER COLUMN preferences SET DEFAULT '{}'::jsonb;

UPDATE users
SET preferences = '{}'::jsonb
WHERE preferences IS NULL;

-- 3) Optional: ensure updated_at trigger function exists (used across schema)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

-- 4) Ensure users table has BEFORE UPDATE trigger (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at'
    ) THEN
        CREATE TRIGGER update_users_updated_at
            BEFORE UPDATE ON users
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END$$;

-- 5) Optional migration history logging if migration_history table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, executed_at, success)
        VALUES ('013_add_users_preferences_column.sql', CURRENT_TIMESTAMP, true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;

-- ============================================================================
-- END OF MIGRATION 013
-- ============================================================================
