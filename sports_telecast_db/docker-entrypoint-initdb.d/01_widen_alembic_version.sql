-- Purpose:
--   Ensure alembic_version.version_num is VARCHAR(64) for compatibility with longer Alembic revision identifiers.
--   This script is safe to run multiple times and only applies changes when needed.
--
-- Behavior:
--   - If the alembic_version table does not exist: do nothing.
--   - If the version_num column does not exist: do nothing.
--   - If the version_num column type is already varchar with length >= 64: do nothing.
--   - Otherwise, alter the column to type VARCHAR(64).
--
-- Notes:
--   - Designed for the official postgres docker image's /docker-entrypoint-initdb.d hook.
--   - Uses DO $$ ... $$ for idempotent checks.
--   - Does not require direct DB access during build; it runs at container initialization time.

DO $$
DECLARE
    v_table_exists boolean;
    v_col_exists boolean;
    v_is_varchar boolean;
    v_char_len int;
BEGIN
    -- Check for table existence in current database
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'alembic_version'
    ) INTO v_table_exists;

    IF NOT v_table_exists THEN
        -- Table not present; nothing to do
        RAISE NOTICE 'alembic_version table not found; skipping widen operation.';
        RETURN;
    END IF;

    -- Check for column existence
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'alembic_version'
          AND column_name = 'version_num'
    ) INTO v_col_exists;

    IF NOT v_col_exists THEN
        -- Column not present; nothing to do
        RAISE NOTICE 'alembic_version.version_num column not found; skipping widen operation.';
        RETURN;
    END IF;

    -- Determine current data type and length
    SELECT
        (data_type = 'character varying') AS is_varchar,
        character_maximum_length
    INTO v_is_varchar, v_char_len
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'alembic_version'
      AND column_name = 'version_num'
    LIMIT 1;

    -- If already varchar(>=64), nothing to do.
    IF v_is_varchar AND (v_char_len IS NULL OR v_char_len >= 64) THEN
        RAISE NOTICE 'alembic_version.version_num already VARCHAR(%), no change required.', COALESCE(v_char_len::text, 'unbounded');
        RETURN;
    END IF;

    -- If not varchar or varchar with length < 64, widen to VARCHAR(64).
    RAISE NOTICE 'Altering public.alembic_version.version_num to VARCHAR(64). Current: is_varchar=%, length=%', v_is_varchar, v_char_len;

    ALTER TABLE public.alembic_version
        ALTER COLUMN version_num TYPE VARCHAR(64);

    RAISE NOTICE 'Successfully altered public.alembic_version.version_num to VARCHAR(64).';
END
$$;
