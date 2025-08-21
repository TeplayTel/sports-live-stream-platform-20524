-- Migration: 015_users_role_to_userroleenum.sql
-- Purpose (updated):
--   Previous intent was to convert users.role to an ENUM. This is now deprecated.
--   This migration now reinforces that users.role uses VARCHAR(32) with a CHECK constraint,
--   ensures lowercase role values, and removes ENUM dependencies if any remain.

-- 1) Ensure users.role exists and is VARCHAR(32)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS role VARCHAR(32);

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

-- 2) Normalize existing values and enforce constraints
UPDATE public.users
SET role = CASE
  WHEN role IS NULL THEN 'user'
  WHEN LOWER(role) IN ('user','admin','moderator') THEN LOWER(role)
  ELSE 'user'
END;

ALTER TABLE public.users
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN role SET DEFAULT 'user';

DO $$
BEGIN
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

-- 3) Best-effort removal of ENUM types no longer used
DO $$
BEGIN
  BEGIN
    DROP TYPE IF EXISTS public.userroleenum;
  EXCEPTION WHEN dependent_objects_still_exist THEN
    RAISE NOTICE 'public.userroleenum still in use, not dropped.';
  WHEN others THEN
    NULL;
  END;

  BEGIN
    DROP TYPE IF EXISTS public.user_role;
  EXCEPTION WHEN dependent_objects_still_exist THEN
    RAISE NOTICE 'public.user_role still in use, not dropped.';
  WHEN others THEN
    NULL;
  END;
END $$;

-- End of migration 015 (updated as no-op for ENUM, enforcing VARCHAR + CHECK)
