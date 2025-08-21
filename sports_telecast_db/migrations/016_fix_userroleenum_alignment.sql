-- Migration 016: Fix userroleenum alignment (idempotent remedial script)
-- Purpose:
--   - Normalize existing users.role values to lowercase allowed set: ('user','admin','moderator')
--   - Ensure enum type public.userroleenum exists with lowercase labels
--   - Convert users.role column to public.userroleenum with DEFAULT 'user' and NOT NULL
-- Notes:
--   - Safe to run multiple times
--   - Designed as a quick remediation when verification detects mismatches or InvalidTextRepresentationError

BEGIN;

-- 1) Ensure enum type public.userroleenum with lowercase labels exists
DO $$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM pg_type t
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE t.typname = 'userroleenum' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.userroleenum AS ENUM ('user','admin','moderator');
  ELSE
    -- Ensure all required labels exist (add if missing)
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname='userroleenum' AND e.enumlabel='user'
    ) THEN
      ALTER TYPE public.userroleenum ADD VALUE 'user';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname='userroleenum' AND e.enumlabel='admin'
    ) THEN
      ALTER TYPE public.userroleenum ADD VALUE 'admin';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname='userroleenum' AND e.enumlabel='moderator'
    ) THEN
      ALTER TYPE public.userroleenum ADD VALUE 'moderator';
    END IF;
  END IF;
END $$;

-- 2) If users table does not exist, nothing to do
DO $$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema='public' AND table_name='users'
  ) THEN
    RAISE NOTICE 'Table public.users not found; skipping.';
  END IF;
END $$;

-- 3) Normalize role values to lowercase strings before casting
DO $$
BEGIN
  IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name='users' AND column_name='role'
  ) THEN
    -- Lowercase all role values and map common variants
    BEGIN
      EXECUTE $sql$
        UPDATE public.users
        SET role = CASE
          WHEN role IS NULL THEN 'user'
          WHEN lower(role::text) IN ('user','admin','moderator') THEN lower(role::text)
          WHEN role::text IN ('USER','User') THEN 'user'
          WHEN role::text IN ('ADMIN','Admin') THEN 'admin'
          WHEN role::text IN ('MODERATOR','Moderator','mod','Mod','MOD') THEN 'moderator'
          ELSE 'user'
        END
        WHERE role IS DISTINCT FROM
              CASE
                WHEN role IS NULL THEN 'user'
                WHEN lower(role::text) IN ('user','admin','moderator') THEN lower(role::text)
                WHEN role::text IN ('USER','User') THEN 'user'
                WHEN role::text IN ('ADMIN','Admin') THEN 'admin'
                WHEN role::text IN ('MODERATOR','Moderator','mod','Mod','MOD') THEN 'moderator'
                ELSE 'user'
              END
      $sql$;
    EXCEPTION WHEN others THEN
      -- Ignore benign issues, continue to conversion logic
      NULL;
    END;
  END IF;
END $$;

-- 4) Convert users.role to the enum type if not already userroleenum
DO $$
BEGIN
  IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name='users' AND column_name='role' AND udt_name <> 'userroleenum'
  ) THEN
    -- Add temp enum column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name='users' AND column_name='role_tmp_enum'
    ) THEN
      ALTER TABLE public.users ADD COLUMN role_tmp_enum public.userroleenum;
    END IF;

    -- Populate from normalized role text
    UPDATE public.users
    SET role_tmp_enum = CASE
      WHEN lower(role::text) IN ('user','admin','moderator') THEN lower(role::text)::public.userroleenum
      ELSE 'user'::public.userroleenum
    END;

    -- Drop default/constraints temporarily on old role column to allow swap
    BEGIN
      EXECUTE 'ALTER TABLE public.users ALTER COLUMN role DROP DEFAULT';
    EXCEPTION WHEN others THEN
      -- ignore
      NULL;
    END;
    BEGIN
      EXECUTE 'ALTER TABLE public.users ALTER COLUMN role DROP NOT NULL';
    EXCEPTION WHEN others THEN
      -- ignore
      NULL;
    END;

    -- Swap columns
    ALTER TABLE public.users RENAME COLUMN role TO role_old;
    ALTER TABLE public.users RENAME COLUMN role_tmp_enum TO role;

    -- Enforce desired defaults and constraints
    ALTER TABLE public.users
      ALTER COLUMN role SET DEFAULT 'user'::public.userroleenum,
      ALTER COLUMN role SET NOT NULL;

    -- Cleanup old column
    ALTER TABLE public.users DROP COLUMN role_old;
  END IF;
END $$;

-- 5) Ensure default and NOT NULL even if already enum
DO $$
BEGIN
  IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name='users' AND column_name='role' AND udt_name = 'userroleenum'
  ) THEN
    EXECUTE 'ALTER TABLE public.users ALTER COLUMN role SET DEFAULT ''user''::public.userroleenum';
    EXECUTE 'ALTER TABLE public.users ALTER COLUMN role SET NOT NULL';
  END IF;
END $$;

COMMIT;

-- Verification (optional run after migration):
-- SELECT udt_name FROM information_schema.columns WHERE table_name='users' AND column_name='role';
-- SELECT DISTINCT role::text FROM public.users ORDER BY 1;
