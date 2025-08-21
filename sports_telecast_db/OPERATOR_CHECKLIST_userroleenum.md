Operator Checklist: users.role enum sanity check

Objective:
- Confirm DB uses enum type userroleenum with lowercase labels ('user','admin','moderator').
- Prevent InvalidTextRepresentationError during /auth/register.

Run these queries in psql:

1) Enum type and labels
SELECT t.typname AS enum_type, e.enumlabel AS label
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typname IN ('userroleenum','user_role')
ORDER BY enum_type, e.enumsortorder;

Expected:
- enum_type = userroleenum
- labels exactly: user, admin, moderator
- If user_role exists, note it but ensure users.role is not using it.

2) Column type for users.role
SELECT table_schema, table_name, column_name, data_type, udt_name
FROM information_schema.columns
WHERE table_schema='public' AND table_name='users' AND column_name='role';

Expected:
- udt_name = userroleenum
- data_type = USER-DEFINED

3) Distinct role values
SELECT DISTINCT role::text AS role_value, COUNT(*) AS cnt
FROM public.users
GROUP BY role_value
ORDER BY role_value;

Expected:
- role_value entries are lowercase only: admin, moderator, user

If any check fails:
- Apply migrations 014_align_users_table_and_userroleenum.sql and 015_users_role_to_userroleenum.sql
- Re-run the checks
- Ensure the backend sends lowercase role values or omits role (DB default 'user').

References:
- migrations/userroleenum_verification_checklist.sql
- migrations/userroleenum_analysis_report.md
- migrations/userroleenum_discrepancy_summary.txt
- USERROLEENUM_README.md
