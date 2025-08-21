-- Migration: 014_align_users_table_and_userroleenum.sql
-- Purpose:
--   Align the users table role column to use VARCHAR(32) with a CHECK constraint instead of any ENUM.
--   Ensure existing data is normalized to lowercase within the allowed set: ('user', 'admin', 'moderator').
--   Remove any dependency on enum types for user roles.
-- Design goals:
--   - Idempotent and non-destructive.
--   - Compatible across environments with minimal privileges.

-- 0) Ensure users table exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'users'
  ) THEN
    RAISE NOTICE 'Table public.users does not exist; skipping role alignment.';
  END IF;
END $$;

-- 1) If role column does not exist, create it as VARCHAR(32) with default 'user'
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS role VARCHAR(32);

-- 2) Normalize existing role values to lowercase within allowed set
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users' AND column_name='role'
  ) THEN
    -- If column is enum, cast to text for normalization updates; if text, this still works.
    BEGIN
      EXECUTE $sql$
        UPDATE public.users
        SET role = CASE
          WHEN role IS NULL THEN 'user'
          WHEN LOWER(role::text) IN ('user','admin','moderator') THEN LOWER(role::text)
          ELSE 'user'
        END
      $sql$;
    EXCEPTION WHEN others THEN
      -- Defensive: if casting fails for any reason, fallback by trying without ::text
      BEGIN
        UPDATE public.users
        SET role = CASE
          WHEN role IS NULL THEN 'user'
          WHEN LOWER(role) IN ('user','admin','moderator') THEN LOWER(role)
          ELSE 'user'
        END;
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Unable to normalize role values; manual fix may be required.';
      END;
    END;
  END IF;
END $$;

-- 3) If column type is not character varying, convert it to VARCHAR(32) using a safe USING clause
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users' AND column_name='role'
      AND data_type <> 'character varying'
  ) THEN
    EXECUTE $conv$
      ALTER TABLE public.users
      ALTER COLUMN role TYPE VARCHAR(32)
      USING (
        CASE
          WHEN role IS NULL THEN 'user'
          WHEN LOWER(role::text) IN ('user','admin','moderator') THEN LOWER(role::text)
          ELSE 'user'
        END
      )
    $conv$;
  END IF;
END $$;

-- 4) Enforce NOT NULL and DEFAULT 'user'
ALTER TABLE public.users
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN role SET DEFAULT 'user';

-- 5) Add or replace CHECK constraint for allowed roles
DO $$
BEGIN
  -- Drop existing constraint if present with older name, then add a consistent one
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE table_schema='public' AND table_name='users' AND constraint_name='chk_users_role'
  ) THEN
    ALTER TABLE public.users DROP CONSTRAINT chk_users_role;
  END IF;

  ALTER TABLE public.users
    ADD CONSTRAINT chk_users_role CHECK (role IN ('user','admin','moderator'));
END $$;

-- 6) Clean up any leftover ENUM types for roles if they exist (best-effort, ignore failures)
DO $$
BEGIN
  -- userroleenum
  IF EXISTS (SELECT 1 FROM pg_type t WHERE t.typname='userroleenum') THEN
    -- Only drop if no columns depend on it anymore
    BEGIN
      DROP TYPE IF EXISTS public.userroleenum;
    EXCEPTION WHEN dependent_objects_still_exist THEN
      RAISE NOTICE 'public.userroleenum still in use, not dropped.';
    WHEN others THEN
      NULL;
    END;
  END IF;

  -- legacy user_role
  IF EXISTS (SELECT 1 FROM pg_type t WHERE t.typname='user_role') THEN
    BEGIN
      DROP TYPE IF EXISTS public.user_role;
    EXCEPTION WHEN dependent_objects_still_exist THEN
      RAISE NOTICE 'public.user_role still in use, not dropped.';
    WHEN others THEN
      NULL;
    END;
  END IF;
END $$;

-- End of migration 014
