-- UserRoleEnum Verification Checklist
-- Purpose: Quickly validate DB state for users.role enum to prevent InvalidTextRepresentationError.

-- 1) Inspect enum types and their labels (expected: userroleenum with lowercase 'user','admin','moderator')
SELECT t.typname AS enum_type, e.enumlabel AS label
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typname IN ('userroleenum','user_role')
ORDER BY enum_type, e.enumsortorder;

-- 2) Confirm users.role column uses the expected enum type (expected: udt_name='userroleenum')
SELECT table_schema, table_name, column_name, data_type, udt_name
FROM information_schema.columns
WHERE table_schema='public' AND table_name='users' AND column_name='role';

-- 3) Check distinct role values present (should be lowercase only)
SELECT DISTINCT role::text AS role_value, COUNT(*) AS cnt
FROM public.users
GROUP BY role_value
ORDER BY role_value;

-- 4) Simulate insert with default role (should succeed; role default 'user')
-- Note: Wrap in a transaction and roll back if running on live data.
BEGIN;
INSERT INTO public.users (email, username, password_hash) 
VALUES ('verify_role_default@example.com', 'verify_role_default', 'testhash123');
-- Verify the inserted role
SELECT role::text AS new_role 
FROM public.users 
WHERE email='verify_role_default@example.com';
ROLLBACK;

-- 5) Negative test for uppercase (should fail if enum is lowercase-only)
-- EXPECTED: ERROR: invalid input value for enum userroleenum: "USER"
-- Uncomment to test manually (wrap in transaction and ROLLBACK)
-- BEGIN;
-- INSERT INTO public.users (email, username, password_hash, role) 
-- VALUES ('verify_uppercase@example.com', 'verify_uppercase', 'testhash123', 'USER'::text::userroleenum);
-- ROLLBACK;

-- 6) If users.role is not userroleenum or enum contains unexpected labels:
--    Run migrations 014 and 015 to align. Ensure app downtime/maintenance window as needed.
