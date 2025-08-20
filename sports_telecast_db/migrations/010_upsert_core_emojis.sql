-- ============================================================================
-- Migration 010: Upsert core emoji assets with image paths
-- Purpose:
--   - Ensure the core emoji set exists and is updated as needed:
--       heart, clap, fire, wow (mapped to 'shocked' enum), and love (alias via name)
--   - Use UPSERT (insert or replace/update) semantics so records are overwritten if present
--   - Ensure emoji_path is present and populated for FE access patterns
-- Notes:
--   - Schema enforces uniqueness on emoji_type (from migration 008). We upsert on emoji_type.
--   - 'wow' corresponds to enum 'shocked' (as per emoji_type enum).
--   - 'love' is represented via the 'heart' emoji_type with name 'Love' due to enum constraints.
--   - CDN paths are samples and can be adjusted per environment/CDN.
-- ============================================================================

-- 0) Ensure emoji_path exists on emoji_assets (safety in case 008 not applied)
ALTER TABLE IF EXISTS emoji_assets
    ADD COLUMN IF NOT EXISTS emoji_path TEXT;

-- 1) Upsert HEART (alias 'Love')
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, sort_order, is_active)
VALUES
    ('heart'::emoji_type, 'Love', 'https://cdn.sportstelecast.com/emojis/heart.png',
     'Love and appreciation', E'\u2764\uFE0F', 1, true)
ON CONFLICT (emoji_type) DO UPDATE SET
    name = EXCLUDED.name,
    image_url = EXCLUDED.image_url,
    description = EXCLUDED.description,
    unicode_char = EXCLUDED.unicode_char,
    sort_order = EXCLUDED.sort_order,
    is_active = true;

UPDATE emoji_assets
SET emoji_path = image_url
WHERE emoji_type = 'heart'::emoji_type
  AND (emoji_path IS NULL OR emoji_path <> image_url);

-- 2) Upsert CLAP
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, sort_order, is_active)
VALUES
    ('clap'::emoji_type, 'Clap', 'https://cdn.sportstelecast.com/emojis/clap.png',
     'Applause and approval', E'\U0001F44F', 2, true)
ON CONFLICT (emoji_type) DO UPDATE SET
    name = EXCLUDED.name,
    image_url = EXCLUDED.image_url,
    description = EXCLUDED.description,
    unicode_char = EXCLUDED.unicode_char,
    sort_order = EXCLUDED.sort_order,
    is_active = true;

UPDATE emoji_assets
SET emoji_path = image_url
WHERE emoji_type = 'clap'::emoji_type
  AND (emoji_path IS NULL OR emoji_path <> image_url);

-- 3) Upsert FIRE
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, sort_order, is_active)
VALUES
    ('fire'::emoji_type, 'Fire', 'https://cdn.sportstelecast.com/emojis/fire.png',
     'Excitement and intensity', E'\U0001F525', 3, true)
ON CONFLICT (emoji_type) DO UPDATE SET
    name = EXCLUDED.name,
    image_url = EXCLUDED.image_url,
    description = EXCLUDED.description,
    unicode_char = EXCLUDED.unicode_char,
    sort_order = EXCLUDED.sort_order,
    is_active = true;

UPDATE emoji_assets
SET emoji_path = image_url
WHERE emoji_type = 'fire'::emoji_type
  AND (emoji_path IS NULL OR emoji_path <> image_url);

-- 4) Upsert WOW (mapped to 'shocked')
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, sort_order, is_active)
VALUES
    ('shocked'::emoji_type, 'Wow', 'https://cdn.sportstelecast.com/emojis/wow.png',
     'Surprise and amazement', E'\U0001F62E', 4, true)
ON CONFLICT (emoji_type) DO UPDATE SET
    name = EXCLUDED.name,
    image_url = EXCLUDED.image_url,
    description = EXCLUDED.description,
    unicode_char = EXCLUDED.unicode_char,
    sort_order = EXCLUDED.sort_order,
    is_active = true;

UPDATE emoji_assets
SET emoji_path = image_url
WHERE emoji_type = 'shocked'::emoji_type
  AND (emoji_path IS NULL OR emoji_path <> image_url);

-- 5) Ensure emoji_path is populated for any remaining rows
UPDATE emoji_assets
SET emoji_path = COALESCE(emoji_path, image_url)
WHERE emoji_path IS NULL;

-- Optional: record migration completion if a migration history table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'migration_history'
    ) THEN
        INSERT INTO migration_history (migration_name, success)
        VALUES ('010_upsert_core_emojis.sql', true)
        ON CONFLICT (migration_name) DO UPDATE
        SET executed_at = CURRENT_TIMESTAMP, success = true;
    END IF;
END$$;
-- ============================================================================
