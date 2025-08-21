-- Migration: 013_create_user_table.sql
-- Purpose: Create a 'user' table for the sports telecast application.
-- Notes:
-- - Uses SERIAL for id for consistency with the example provided.
-- - Includes common user fields to support backend API requirements in the project.
-- - Enforces uniqueness on email and username.
-- - Adds created_at and updated_at timestamps with sensible defaults.

BEGIN;

-- Create table only if it doesn't already exist to keep idempotency in dev setups.
CREATE TABLE IF NOT EXISTS "user" (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'user', -- user | admin | moderator
    preferences JSONB DEFAULT '{}'::jsonb,    -- stores UserPreferences JSON
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Helpful indexes for lookups
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);
CREATE INDEX IF NOT EXISTS idx_user_username ON "user"(username);

-- Trigger to update updated_at on row modification
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'set_updated_at_user'
    ) THEN
        CREATE OR REPLACE FUNCTION set_updated_at_user()
        RETURNS TRIGGER AS $func$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END
        $func$ LANGUAGE plpgsql;
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'trg_user_set_updated_at'
    ) THEN
        CREATE TRIGGER trg_user_set_updated_at
        BEFORE UPDATE ON "user"
        FOR EACH ROW
        EXECUTE FUNCTION set_updated_at_user();
    END IF;
END$$;

COMMIT;
