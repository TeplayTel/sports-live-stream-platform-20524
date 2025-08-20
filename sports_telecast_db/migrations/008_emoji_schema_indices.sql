-- ============================================================================
-- Migration 008: Emoji schema alignment, foreign keys, and suggested indices
-- Purpose:
--   - Ensure emoji_assets and emoji_reactions satisfy requested schema elements:
--       * emoji_assets: emoji_type uniqueness, idx on emoji_type, emoji_path column
--       * emoji_reactions: emoji_type column referencing emoji_assets(emoji_type),
--                         updated_at column and update trigger,
--                         indices on (event_id, emoji_type) and (user_id)
-- Notes:
--   - This migration is designed to be idempotent and safe against existing schema.
--   - The existing canonical schema uses UUIDs; we preserve it and augment to meet requirements.
-- ============================================================================

-- 1) Ensure emoji_assets has emoji_path; backfill from image_url if present
ALTER TABLE IF EXISTS emoji_assets
    ADD COLUMN IF NOT EXISTS emoji_path TEXT;

UPDATE emoji_assets
SET emoji_path = COALESCE(emoji_path, image_url)
WHERE emoji_path IS NULL;

-- 2) Ensure an index/uniqueness exists for emoji_assets(emoji_type)
-- Create a unique index which also serves as the requested index by name
CREATE UNIQUE INDEX IF NOT EXISTS idx_emoji_assets_type ON emoji_assets (emoji_type);

-- Promote the unique index into a table-level UNIQUE constraint if missing
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

-- 3) Add emoji_type column to emoji_reactions (if not exists) and backfill from emoji_id
-- This uses the existing emoji_type ENUM defined in earlier migrations.
ALTER TABLE IF EXISTS emoji_reactions
    ADD COLUMN IF NOT EXISTS emoji_type emoji_type;

-- Backfill emoji_reactions.emoji_type from the related emoji_assets row via emoji_id
UPDATE emoji_reactions r
SET emoji_type = ea.emoji_type
FROM emoji_assets ea
WHERE r.emoji_id = ea.emoji_id
  AND r.emoji_type IS NULL;

-- Enforce NOT NULL now that data is backfilled
ALTER TABLE IF EXISTS emoji_reactions
    ALTER COLUMN emoji_type SET NOT NULL;

-- 4) Add a foreign key referencing emoji_assets(emoji_type)
--    This requires that emoji_assets(emoji_type) be UNIQUE (ensured above).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_emoji_reactions_emoji_type'
          AND conrelid = 'emoji_reactions'::regclass
    ) THEN
        ALTER TABLE emoji_reactions
            ADD CONSTRAINT fk_emoji_reactions_emoji_type
            FOREIGN KEY (emoji_type)
            REFERENCES emoji_assets(emoji_type);
    END IF;
END$$;

-- 5) Ensure updated_at column exists on emoji_reactions
ALTER TABLE IF EXISTS emoji_reactions
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 6) Ensure BEFORE UPDATE trigger on emoji_reactions to keep updated_at fresh
--    Reuses existing update_updated_at_column() function from initial migration.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_emoji_reactions_updated_at'
    ) THEN
        CREATE TRIGGER update_emoji_reactions_updated_at
            BEFORE UPDATE ON emoji_reactions
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END$$;

-- 7) Indices for emoji_reactions
-- Composite index on (event_id, emoji_type) as requested
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_event_type
    ON emoji_reactions (event_id, emoji_type);

-- Ensure an index exists for (user_id). One may already exist (idx_emoji_reactions_user_id);
-- create the requested name only if it doesn't exist.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public'
          AND indexname = 'idx_emoji_reactions_user'
    ) THEN
        CREATE INDEX idx_emoji_reactions_user ON emoji_reactions (user_id);
    END IF;
END$$;

-- Optional: document new/adjusted parts
COMMENT ON COLUMN emoji_assets.emoji_path IS 'Path/URL to emoji asset (backfilled from image_url for compatibility)';
COMMENT ON CONSTRAINT uq_emoji_assets_emoji_type ON emoji_assets IS 'Uniqueness for emoji_type to support FK references from emoji_reactions';
-- ============================================================================

-- Record migration completion in migration_history if table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, success)
        VALUES ('008_emoji_schema_indices.sql', true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;
