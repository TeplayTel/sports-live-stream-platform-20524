-- ============================================================================
-- Migration 011: Create/Align emoji_reactions table
-- Purpose:
--   - Ensure the emoji_reactions table exists with required fields and constraints
--   - Align with prior canonical schema (UUIDs, emoji_type enum, updated_at trigger)
--   - Add indices for common query patterns
--   - Be fully idempotent (safe to re-run)
-- Notes:
--   - Works whether table exists or not
--   - If the update_updated_at_column() function doesn't exist, it is created
--   - Requires emoji_assets(emoji_type) to be unique for FK; creates unique idx if missing
-- ============================================================================

-- 0) Ensure required extensions exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1) Ensure emoji_type enum exists (safety)
DO $$
BEGIN
    PERFORM 1 FROM pg_type WHERE typname = 'emoji_type';
    IF NOT FOUND THEN
        CREATE TYPE emoji_type AS ENUM ('clap','fire','heart','thumbs_up','celebration','shocked','angry','sad','laugh','goal');
    END IF;
END$$;

-- 2) Ensure supporting function for updated_at trigger exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

-- 3) Ensure emoji_assets.emoji_type has a unique constraint/index to support FK
--    Create unique index and promote to constraint if not present
CREATE UNIQUE INDEX IF NOT EXISTS idx_emoji_assets_type ON emoji_assets (emoji_type);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_emoji_assets_emoji_type'
          AND conrelid = 'emoji_assets'::regclass
    ) THEN
        ALTER TABLE emoji_assets
            ADD CONSTRAINT uq_emoji_assets_emoji_type
            UNIQUE USING INDEX idx_emoji_assets_type;
    END IF;
END$$;

-- 4) Create emoji_reactions table if it does not exist (canonical UUID schema)
CREATE TABLE IF NOT EXISTS emoji_reactions (
    reaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    user_id UUID,
    match_id UUID,
    emoji_id UUID NOT NULL,
    emoji_type emoji_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5) Add/ensure foreign keys (idempotent)
DO $$
BEGIN
    -- fk to users.user_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_user_id'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_user_id
            FOREIGN KEY (user_id) REFERENCES users(user_id);
    END IF;

    -- fk to events.event_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_event_id'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_event_id
            FOREIGN KEY (event_id) REFERENCES events(event_id);
    END IF;

    -- fk to matches.match_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_match_id'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_match_id
            FOREIGN KEY (match_id) REFERENCES matches(match_id);
    END IF;

    -- fk to emoji_assets.emoji_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_emoji_id'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_emoji_id
            FOREIGN KEY (emoji_id) REFERENCES emoji_assets(emoji_id);
    END IF;

    -- fk from emoji_reactions.emoji_type to emoji_assets.emoji_type
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_emoji_type'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_emoji_type
            FOREIGN KEY (emoji_type) REFERENCES emoji_assets(emoji_type);
    END IF;
END$$;

-- 6) Ensure BEFORE UPDATE trigger for updated_at on emoji_reactions
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'update_emoji_reactions_updated_at'
    ) THEN
        CREATE TRIGGER update_emoji_reactions_updated_at
            BEFORE UPDATE ON emoji_reactions
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END$$;

-- 7) Indices for performance (idempotent)
-- Note: Some indices may already exist from earlier migrations; use IF NOT EXISTS
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_event_type ON emoji_reactions (event_id, emoji_type);
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_user ON emoji_reactions (user_id);
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_created_at ON emoji_reactions (created_at);

-- 8) Comments for documentation
COMMENT ON TABLE emoji_reactions IS 'User emoji reactions during events (UUID-based canonical schema)';
COMMENT ON COLUMN emoji_reactions.emoji_type IS 'Enum type referencing emoji_assets(emoji_type)';

-- 9) Record migration completion in migration_history if table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, success)
        VALUES ('011_create_emoji_reactions_table.sql', true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;
-- ============================================================================
