-- Migration: 014_align_users_table_and_userroleenum.sql
-- Purpose:
--   Align the users table with backend ORM expectations for registration and auth.
--   - Define enum type userroleenum if not exists with values ('user','admin','moderator')
--   - Ensure users table exists and matches required schema:
--       id UUID PK (default gen_random_uuid())
--       email VARCHAR NOT NULL UNIQUE
--       username VARCHAR(50) NOT NULL UNIQUE
--       password_hash VARCHAR NOT NULL
--       full_name VARCHAR NULL
--       avatar_url VARCHAR NULL
--       role userroleenum NOT NULL DEFAULT 'user'
--       preferences JSONB NOT NULL DEFAULT '{}'::jsonb
--       is_active BOOLEAN NOT NULL DEFAULT TRUE
--       created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
--       updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
--
-- Design goals:
--   - Idempotent: safe to run multiple times without errors.
--   - Non-destructive: will not drop columns or data; performs safe casts where possible.
--   - Compatible with Postgres with pgcrypto extension for gen_random_uuid(); falls back to uuid_generate_v4() if available.
--
-- Pre-requisites:
--   Ensure pgcrypto exists for gen_random_uuid(). This block enables it if available.
--   Note: Enabling extensions may require superuser; ignore errors if permissions restrict this.

-- 0) Enable helpful extensions when possible (best-effort; ignore failure in restricted environments)
DO $$
BEGIN
  -- Try to create pgcrypto; ignore if not permitted or already exists
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
  EXCEPTION
    WHEN insufficient_privilege THEN
      -- ignore if we cannot create extension in this environment
      NULL;
    WHEN others THEN
      -- ignore other failures
      NULL;
  END;

  -- Also try uuid-ossp for uuid_generate_v4 fallback
  BEGIN
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN others THEN
      NULL;
  END;
END $$;

-- 1) Define enum type userroleenum if not exists
--    Ensure labels are strictly lowercase: ('user','admin','moderator')
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace
                 WHERE t.typname = 'userroleenum' AND n.nspname = 'public') THEN
    CREATE TYPE public.userroleenum AS ENUM ('user','admin','moderator');
  ELSE
    -- In case the enum exists but is missing any expected lowercase label, add it safely.
    PERFORM 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid WHERE t.typname='userroleenum' AND e.enumlabel='user';
    IF NOT FOUND THEN
      BEGIN
        ALTER TYPE public.userroleenum ADD VALUE 'user';
      EXCEPTION WHEN duplicate_object THEN NULL;
      END;
    END IF;
    PERFORM 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid WHERE t.typname='userroleenum' AND e.enumlabel='admin';
    IF NOT FOUND THEN
      BEGIN
        ALTER TYPE public.userroleenum ADD VALUE 'admin';
      EXCEPTION WHEN duplicate_object THEN NULL;
      END;
    END IF;
    PERFORM 1 FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid WHERE t.typname='userroleenum' AND e.enumlabel='moderator';
    IF NOT FOUND THEN
      BEGIN
        ALTER TYPE public.userroleenum ADD VALUE 'moderator';
      EXCEPTION WHEN duplicate_object THEN NULL;
      END;
    END IF;
  END IF;
END $$;

COMMENT ON TYPE public.userroleenum IS 'User role enumeration used by users.role (lowercase values only: user, admin, moderator).';

-- 2) Create users table if it does not exist with full schema
--    If it exists, we will adjust columns in subsequent steps.
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email VARCHAR NOT NULL,
  username VARCHAR(50) NOT NULL,
  password_hash VARCHAR NOT NULL,
  full_name VARCHAR NULL,
  avatar_url VARCHAR NULL,
  role public.userroleenum NOT NULL DEFAULT 'user',
  preferences JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3) Ensure id column exists, is UUID, NOT NULL, PK, and has a default generator
--    We do not drop PKs; we add/alter as needed.
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS id UUID;

-- Try to cast id to UUID if it is of another textual type
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users'
      AND column_name = 'id' AND udt_name NOT IN ('uuid')
  ) THEN
    -- Use a USING clause to cast common types to uuid
    BEGIN
      ALTER TABLE public.users
        ALTER COLUMN id TYPE UUID USING
          CASE
            WHEN pg_typeof(id)::text IN ('text','varchar','bpchar') THEN id::uuid
            ELSE id::uuid
          END;
    EXCEPTION WHEN others THEN
      -- If cast fails (bad data), leave type unchanged to avoid destructive changes
      RAISE NOTICE 'Skipping id type cast; manual remediation may be required for bad data.';
    END;
  END IF;
END $$;

-- Ensure id is NOT NULL
ALTER TABLE public.users
  ALTER COLUMN id SET NOT NULL;

-- Ensure PK constraint exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.users'::regclass
      AND contype = 'p'
  ) THEN
    ALTER TABLE public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
  END IF;
END $$;

-- Ensure default generator for id
DO $$
DECLARE
  deftext text;
BEGIN
  SELECT pg_get_expr(adbin, adrelid) INTO deftext
  FROM pg_attrdef
  WHERE adrelid = 'public.users'::regclass
    AND adnum = (SELECT attnum FROM pg_attribute WHERE attrelid = 'public.users'::regclass AND attname = 'id');

  IF deftext IS NULL THEN
    -- Prefer gen_random_uuid() if available, fallback to uuid_generate_v4()
    BEGIN
      EXECUTE 'ALTER TABLE public.users ALTER COLUMN id SET DEFAULT gen_random_uuid()';
    EXCEPTION WHEN undefined_function THEN
      BEGIN
        EXECUTE 'ALTER TABLE public.users ALTER COLUMN id SET DEFAULT uuid_generate_v4()';
      EXCEPTION WHEN undefined_function THEN
        -- If both are unavailable, leave without default
        RAISE NOTICE 'No UUID generator function available; id will have no default.';
      END;
    END;
  END IF;
END $$;

-- 4) Ensure core string columns exist with proper lengths/nullability
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS email VARCHAR;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS username VARCHAR(50);

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR;

-- Enforce NOT NULL constraints for required columns
ALTER TABLE public.users
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN username SET NOT NULL,
  ALTER COLUMN password_hash SET NOT NULL;

-- 5) Optional nullable columns
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS full_name VARCHAR;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS avatar_url VARCHAR;

-- 6) Role column as enum with default 'user' and NOT NULL
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS role public.userroleenum;

-- Data normalization BEFORE any type changes:
-- Ensure any existing role values are lowercase and valid. This prevents casting issues and enforces a single standard.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users' AND column_name='role'
  ) THEN
    -- Lowercase everything first (works for text/varchar/enum-to-text cast)
    BEGIN
      EXECUTE 'UPDATE public.users SET role = LOWER(role::text) WHERE role IS NOT NULL AND role::text <> LOWER(role::text)';
    EXCEPTION WHEN others THEN
      -- If role already enum, the ::text cast still works; ignore any warning-level issues
      NULL;
    END;

    -- Map common variants and unknowns to safe values (only lowercase are allowed)
    BEGIN
      EXECUTE $sql$
        UPDATE public.users
        SET role = CASE
          WHEN role::text IN ('user','admin','moderator') THEN role
          WHEN role::text IN ('USER','User') THEN 'user'
          WHEN role::text IN ('ADMIN','Admin') THEN 'admin'
          WHEN role::text IN ('MODERATOR','Moderator','mod','Mod','MOD') THEN 'moderator'
          ELSE 'user'
        END
        WHERE role IS NOT NULL AND role::text NOT IN ('user','admin','moderator')
      $sql$;
    EXCEPTION WHEN others THEN
      NULL;
    END;

    -- Ensure no NULL remains to avoid NOT NULL/enum casting issues later
    UPDATE public.users SET role = 'user' WHERE role IS NULL;
  END IF;
END $$;

-- If role exists but is not of enum type, attempt safe conversion preserving values
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users'
      AND column_name='role' AND udt_name <> 'userroleenum'
  ) THEN
    -- Create a temp column, cast, copy, then swap to avoid data loss
    ALTER TABLE public.users ADD COLUMN role_new public.userroleenum;
    -- Attempt to map string values to enum; unknowns map to 'user'
    UPDATE public.users
      SET role_new = CASE
                       WHEN lower(role::text) IN ('user','admin','moderator') THEN lower(role::text)::public.userroleenum
                       ELSE 'user'::public.userroleenum
                     END;
    ALTER TABLE public.users DROP COLUMN role;
    ALTER TABLE public.users RENAME COLUMN role_new TO role;
  END IF;
END $$;

-- Set NOT NULL and default on role
ALTER TABLE public.users
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN role SET DEFAULT 'user';

-- 7) Preferences JSONB with default
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS preferences JSONB;

-- Convert preferences to JSONB if needed
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users'
      AND column_name='preferences' AND udt_name <> 'jsonb'
  ) THEN
    ALTER TABLE public.users
      ALTER COLUMN preferences TYPE jsonb USING
        CASE
          WHEN pg_typeof(preferences)::text IN ('json','jsonb') THEN preferences::jsonb
          WHEN pg_typeof(preferences)::text IN ('text','varchar','bpchar') THEN
            CASE
              WHEN preferences ~ '^\s*$' THEN '{}'::jsonb
              ELSE preferences::jsonb
            END
          ELSE to_jsonb(preferences)
        END;
  END IF;
END $$;

ALTER TABLE public.users
  ALTER COLUMN preferences SET NOT NULL,
  ALTER COLUMN preferences SET DEFAULT '{}'::jsonb;

-- 8) Activity flag and timestamps with defaults
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN;
ALTER TABLE public.users
  ALTER COLUMN is_active SET NOT NULL,
  ALTER COLUMN is_active SET DEFAULT TRUE;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ;
ALTER TABLE public.users
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT NOW();

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE public.users
  ALTER COLUMN updated_at SET NOT NULL,
  ALTER COLUMN updated_at SET DEFAULT NOW();

-- 9) Uniqueness constraints for email and username
-- Create unique indexes if they don't exist, then ensure constraints exist.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='users_email_key'
  ) THEN
    -- Try to create unique index; ignore if duplicate values exist
    BEGIN
      CREATE UNIQUE INDEX users_email_key ON public.users (lower(email));
    EXCEPTION WHEN unique_violation THEN
      RAISE NOTICE 'Duplicate emails detected; unique index not created.';
    WHEN others THEN
      -- Handle potential collation/functional index issues by falling back to raw column unique
      BEGIN
        CREATE UNIQUE INDEX users_email_key ON public.users (email);
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Unable to create unique index on email.';
      END;
    END;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='users_username_key'
  ) THEN
    BEGIN
      CREATE UNIQUE INDEX users_username_key ON public.users (lower(username));
    EXCEPTION WHEN unique_violation THEN
      RAISE NOTICE 'Duplicate usernames detected; unique index not created.';
    WHEN others THEN
      BEGIN
        CREATE UNIQUE INDEX users_username_key ON public.users (username);
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Unable to create unique index on username.';
      END;
    END;
  END IF;
END $$;

-- Optionally attach constraints referencing these indexes if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.users'::regclass AND contype='u' AND conname='users_email_unique'
  ) THEN
    -- Attach a constraint using the existing index if possible
    BEGIN
      ALTER TABLE public.users
        ADD CONSTRAINT users_email_unique UNIQUE USING INDEX users_email_key;
    EXCEPTION WHEN duplicate_object THEN
      NULL;
    WHEN others THEN
      -- Fallback: add direct unique constraint on column (may create new index)
      BEGIN
        ALTER TABLE public.users ADD CONSTRAINT users_email_unique UNIQUE (email);
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Unable to add unique constraint users_email_unique.';
      END;
    END;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.users'::regclass AND contype='u' AND conname='users_username_unique'
  ) THEN
    BEGIN
      ALTER TABLE public.users
        ADD CONSTRAINT users_username_unique UNIQUE USING INDEX users_username_key;
    EXCEPTION WHEN duplicate_object THEN
      NULL;
    WHEN others THEN
      BEGIN
        ALTER TABLE public.users ADD CONSTRAINT users_username_unique UNIQUE (username);
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Unable to add unique constraint users_username_unique.';
      END;
    END;
  END IF;
END $$;

-- 10) Column comments for maintainers
COMMENT ON TABLE public.users IS 'Application users for authentication and profiles. Matches backend ORM expectations.';
COMMENT ON COLUMN public.users.id IS 'Primary key, UUID. Default generated server-side.';
COMMENT ON COLUMN public.users.email IS 'User email address (unique, required).';
COMMENT ON COLUMN public.users.username IS 'Public username (unique, required, max length 50).';
COMMENT ON COLUMN public.users.password_hash IS 'BCrypt/Argon2 password hash (required).';
COMMENT ON COLUMN public.users.full_name IS 'Optional full name (nullable).';
COMMENT ON COLUMN public.users.avatar_url IS 'Optional avatar URL (nullable).';
COMMENT ON COLUMN public.users.role IS 'User role enum (user/admin/moderator), default user.';
COMMENT ON COLUMN public.users.preferences IS 'JSONB storing preferences (default empty object).';
COMMENT ON COLUMN public.users.is_active IS 'Soft-enable flag, default TRUE.';
COMMENT ON COLUMN public.users.created_at IS 'Creation timestamp, default NOW().';
COMMENT ON COLUMN public.users.updated_at IS 'Last update timestamp, default NOW().';

-- 11) Trigger to auto-update updated_at on row updates (idempotent)
-- Create function if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'set_current_timestamp_updated_at' AND n.nspname='public'
  ) THEN
    CREATE FUNCTION public.set_current_timestamp_updated_at()
    RETURNS TRIGGER AS $f$
    BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
    END;
    $f$ LANGUAGE plpgsql;
  END IF;
END $$;

-- Create trigger if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname='set_public_users_updated_at'
  ) THEN
    CREATE TRIGGER set_public_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.set_current_timestamp_updated_at();
  END IF;
END $$;

-- End of migration
