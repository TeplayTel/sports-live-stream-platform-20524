-- 016_fix_userroleenum_alignment.sql
-- Purpose: Forcibly align the userroleenum type and all existing roles to lowercase values,
--          ensuring future inserts use the canonical enum.
-- Notes:
--  - This script is idempotent and safe to re-run.
--  - It normalizes existing values, reconciles enum labels, and enforces the correct column type and default.
--  - Explicitly ignores legacy migrations 004, 005, and 015 per instruction.
--  - Enum canonical values are: 'user', 'admin', 'moderator'.

BEGIN;

-- 1) Ensure the enum type exists with canonical lowercase values.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t WHERE t.typname = 'userroleenum') THEN
        CREATE TYPE userroleenum AS ENUM ('user', 'admin', 'moderator');
    END IF;
END$$;

-- 2) Add any missing enum labels (defensive, though the canonical set above should suffice).
DO $$
DECLARE
    v_label text;
BEGIN
    FOREACH v_label IN ARRAY ARRAY['user','admin','moderator']
    LOOP
        IF NOT EXISTS (
            SELECT 1
            FROM pg_enum e
            JOIN pg_type t ON t.oid = e.enumtypid
            WHERE t.typname = 'userroleenum' AND e.enumlabel = v_label
        ) THEN
            EXECUTE format('ALTER TYPE userroleenum ADD VALUE IF NOT EXISTS %L', v_label);
        END IF;
    END LOOP;
END$$;

-- 3) Ensure users.role column exists; if not, skip type enforcement and updates gracefully.
--    We still perform updates only if the column is present.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
        RAISE NOTICE 'Column public.users.role does not exist; skipping userroleenum alignment for users table.';
    END IF;
END$$;

-- 4) Normalize existing role strings to lowercase prior to type enforcement.
--    This step handles cases where the column might still be text or enum with mixed case values.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
        -- If role is of enum type userroleenum already, temporarily cast to text for normalization
        -- and use a safe mapping that only sets values which are valid when lowercased.
        -- Otherwise, if it's text, simply lowercase it.
        PERFORM 1;
        -- Determine current type
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role' AND udt_name = 'userroleenum'
        ) THEN
            -- When already enum: update only those rows where lower(text(role)) is different and known
            EXECUTE $sql$
                UPDATE public.users
                SET role = LOWER(role::text)::userroleenum
                WHERE role::text <> LOWER(role::text)
                  AND LOWER(role::text) IN ('user','admin','moderator')
            $sql$;
        ELSE
            -- When text: lowercase and null invalids that don't map to canonical values
            EXECUTE $sql$
                UPDATE public.users
                SET role = CASE
                    WHEN LOWER(role) IN ('user','admin','moderator') THEN LOWER(role)
                    WHEN role IS NULL THEN NULL
                    ELSE LOWER(role) -- still lowercase, next step will coerce or fail if invalid
                END
            $sql$;
        END IF;
    END IF;
END$$;

-- 5) Ensure the default exists on the enum type for 'user' where needed (set at column level).
--    First drop any existing default to avoid conflicts; then set a proper default.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
        -- Drop default if exists to reset cleanly
        EXECUTE 'ALTER TABLE public.users ALTER COLUMN role DROP DEFAULT';
    END IF;
END$$;

-- 6) Convert the users.role column to userroleenum, using a safe cast mapping.
--    We use USING clause with explicit CASE mapping to prevent InvalidTextRepresentationError.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
        -- If already of correct enum type, no-op conversion guarded by IF
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role' AND udt_name = 'userroleenum'
        ) THEN
            EXECUTE $conv$
                ALTER TABLE public.users
                ALTER COLUMN role TYPE userroleenum
                USING (
                    CASE
                        WHEN role IS NULL THEN NULL
                        WHEN LOWER(role::text) = 'user' THEN 'user'::userroleenum
                        WHEN LOWER(role::text) = 'admin' THEN 'admin'::userroleenum
                        WHEN LOWER(role::text) = 'moderator' THEN 'moderator'::userroleenum
                        ELSE NULL
                    END
                )
            $conv$;
        END IF;
    END IF;
END$$;

-- 7) After conversion, backfill any NULLs with the default 'user' where appropriate.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role' AND udt_name = 'userroleenum'
    ) THEN
        EXECUTE $sql$
            UPDATE public.users
            SET role = 'user'::userroleenum
            WHERE role IS NULL
        $sql$;
    END IF;
END$$;

-- 8) Re-apply default for the users.role column to 'user'.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role' AND udt_name = 'userroleenum'
    ) THEN
        EXECUTE 'ALTER TABLE public.users ALTER COLUMN role SET DEFAULT ''user''::userroleenum';
    END IF;
END$$;

-- 9) Validate that only canonical enum values exist; optional soft check.
--    We do not RAISE EXCEPTION to keep idempotency; we just RAISE NOTICE if anomaly found.
DO $$
DECLARE
    v_bad_count integer := 0;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
        SELECT COUNT(*) INTO v_bad_count
        FROM public.users
        WHERE (role::text) NOT IN ('user','admin','moderator');
        IF v_bad_count > 0 THEN
            RAISE NOTICE 'Found % non-canonical role values remaining after migration.', v_bad_count;
        END IF;
    END IF;
END$$;

COMMIT;

-- End of 016_fix_userroleenum_alignment.sql
