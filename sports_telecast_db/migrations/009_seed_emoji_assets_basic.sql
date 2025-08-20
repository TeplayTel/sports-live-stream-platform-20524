-- ============================================================================
-- Migration 009: Seed core emoji assets (heart, clap, fire, wow/love)
-- Purpose:
--   - Ensure the basic emoji set exists:
--       heart, clap, fire, wow (mapped to 'shocked' enum), and love (alias of 'heart')
--   - Populate emoji_path for compatibility with FE access patterns
-- Notes:
--   - Uses ON CONFLICT DO NOTHING for idempotency against existing seed data.
--   - Our canonical schema enforces one row per emoji_type (unique), and we already
--     have 'Love' for 'heart' in previous seeds; this will safely no-op where present.
-- ============================================================================

-- Insert minimal emoji assets with both image_url and emoji_path populated.
-- Choose consistent paths; adjust CDN paths as needed by environment.
INSERT INTO emoji_assets (emoji_type, name, image_url, emoji_path, description, unicode_char, sort_order, is_active)
VALUES
    ('heart'::emoji_type,  'Love', 'https://cdn.sportstelecast.com/emojis/heart.png', 'https://cdn.sportstelecast.com/emojis/heart.png', 'Love and appreciation', E'\u2764\uFE0F', 1, true),
    ('clap'::emoji_type,   'Clap', 'https://cdn.sportstelecast.com/emojis/clap.png',  'https://cdn.sportstelecast.com/emojis/clap.png',  'Applause and approval', E'\uD83D\uDC4F', 2, true),
    ('fire'::emoji_type,   'Fire', 'https://cdn.sportstelecast.com/emojis/fire.png',  'https://cdn.sportstelecast.com/emojis/fire.png',  'Excitement and intensity', E'\uD83D\uDD25', 3, true),
    ('shocked'::emoji_type,'Wow',  'https://cdn.sportstelecast.com/emojis/wow.png',   'https://cdn.sportstelecast.com/emojis/wow.png',   'Surprise and amazement', E'\uD83D\uDE2E', 4, true)
ON CONFLICT DO NOTHING;

-- Ensure emoji_path is populated for any existing rows missing it
UPDATE emoji_assets
SET emoji_path = COALESCE(emoji_path, image_url)
WHERE emoji_path IS NULL;

-- Record migration completion in migration_history if table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, success)
        VALUES ('009_seed_emoji_assets_basic.sql', true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;
-- ============================================================================
