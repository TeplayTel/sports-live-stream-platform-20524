-- ============================================================================
-- Migration 012: Upsert core emoji assets with example CDN paths
-- Purpose:
--   - Ensure the core emoji set exists and is updated as needed:
--       heart (Love), clap, fire, wow (mapped to 'shocked' enum)
--   - Populate emoji_path for frontend usage alongside image_url
--   - Use idempotent operations (safe to re-run)
-- Notes:
--   - 'wow' corresponds to enum 'shocked' per emoji_type enum.
--   - 'love' is represented via emoji_type='heart' with name 'Love'.
--   - Supports both schemas:
--       a) Unique constraint on (emoji_type, name)
--       b) Unique constraint on emoji_type alone (added in migration 011)
-- ============================================================================

-- 0) Safety: ensure emoji_path column exists
ALTER TABLE IF EXISTS emoji_assets
    ADD COLUMN IF NOT EXISTS emoji_path TEXT;

-- 1) UPDATE existing rows by emoji_type to enforce example CDN paths and properties
-- HEART (alias LOVE)
UPDATE emoji_assets
SET name = 'Love',
    image_url = 'https://cdn.example.com/emojis/heart.png',
    description = 'Love and appreciation',
    unicode_char = E'\\u2764\\uFE0F',
    sort_order = 1,
    is_active = true,
    emoji_path = 'https://cdn.example.com/emojis/heart.png'
WHERE emoji_type = 'heart'::emoji_type;

-- CLAP
UPDATE emoji_assets
SET name = 'Clap',
    image_url = 'https://cdn.example.com/emojis/clap.png',
    description = 'Applause and approval',
    unicode_char = E'\\U0001F44F',
    sort_order = 2,
    is_active = true,
    emoji_path = 'https://cdn.example.com/emojis/clap.png'
WHERE emoji_type = 'clap'::emoji_type;

-- FIRE
UPDATE emoji_assets
SET name = 'Fire',
    image_url = 'https://cdn.example.com/emojis/fire.png',
    description = 'Excitement and intensity',
    unicode_char = E'\\U0001F525',
    sort_order = 3,
    is_active = true,
    emoji_path = 'https://cdn.example.com/emojis/fire.png'
WHERE emoji_type = 'fire'::emoji_type;

-- WOW (mapped to SHOCKED)
UPDATE emoji_assets
SET name = 'Wow',
    image_url = 'https://cdn.example.com/emojis/wow.png',
    description = 'Surprise and amazement',
    unicode_char = E'\\U0001F62E',
    sort_order = 4,
    is_active = true,
    emoji_path = 'https://cdn.example.com/emojis/wow.png'
WHERE emoji_type = 'shocked'::emoji_type;

-- 2) INSERT missing rows, ignore if already present under any unique constraint
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, sort_order, is_active, emoji_path)
VALUES
    ('heart'::emoji_type,  'Love', 'https://cdn.example.com/emojis/heart.png', 'Love and appreciation', E'\\u2764\\uFE0F', 1, true, 'https://cdn.example.com/emojis/heart.png'),
    ('clap'::emoji_type,   'Clap', 'https://cdn.example.com/emojis/clap.png',  'Applause and approval', E'\\U0001F44F', 2, true, 'https://cdn.example.com/emojis/clap.png'),
    ('fire'::emoji_type,   'Fire', 'https://cdn.example.com/emojis/fire.png',  'Excitement and intensity', E'\\U0001F525', 3, true, 'https://cdn.example.com/emojis/fire.png'),
    ('shocked'::emoji_type,'Wow',  'https://cdn.example.com/emojis/wow.png',   'Surprise and amazement', E'\\U0001F62E', 4, true, 'https://cdn.example.com/emojis/wow.png')
ON CONFLICT DO NOTHING;

-- 3) Fill emoji_path for any remaining existing rows if null
UPDATE emoji_assets
SET emoji_path = COALESCE(emoji_path, image_url)
WHERE emoji_path IS NULL;

-- 4) Optional migration history record
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, success)
        VALUES ('012_upsert_emoji_assets_example_cdn.sql', true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;
-- ============================================================================
