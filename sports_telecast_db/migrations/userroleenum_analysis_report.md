# User Role Enum Analysis Report

Date: 2025-08-21
Container: sports_telecast_db
Scope: Analyze all migrations affecting users.role and Postgres enum type handling for user roles, and identify causes for InvalidTextRepresentationError on /auth/register.

Summary
- Backend expects role enum values to be lowercase: 'user', 'admin', 'moderator' and uses a Postgres enum type named userroleenum.
- The correct, intended DB enum definition is: public.userroleenum AS ENUM ('user','admin','moderator').
- Migrations 014 and 015 explicitly define userroleenum with lowercase values and convert users.role to this enum safely with normalization.
- Legacy or alternative migrations exist that may introduce mismatches (uppercase values, different enum name).

Detailed Findings
1) Early schema (001_initial_schema.sql, 001_initial_schema_fixed.sql)
   - users.role: VARCHAR(20) with CHECK constraint enforcing lowercase ('user','admin','moderator'); default 'user'.
   - No enum type created at this point. Lowercase usage is consistent.

2) Seed data (002_seed_data*.sql)
   - Inserts use lowercase roles 'admin', 'user'. Consistent with the check constraint.

3) Comprehensive seed (003_comprehensive_seed_data.sql)
   - Includes a defensive DO block to normalize users.role to lowercase set {'user','admin','moderator'}; unknowns => 'user'.
   - Still text-based role at this stage (no enum conversion yet).

4) Realistic/Corrected mock data (004_realistic_mock_data.sql, 005_corrected_mock_data.sql)
   - Insert users with uppercase role strings: 'USER', 'ADMIN', 'MODERATOR'.
   - These scripts are inconsistent with the lowercase-only contract and with the schema from 001/003.
   - If run after converting role to a lowercase-only enum, they will trigger InvalidTextRepresentationError.

5) Comprehensive schema migration (007_comprehensive_schema_migration.sql)
   - Defines a different enum: user_role AS ENUM ('user','admin','moderator','premium').
   - Sets users.role to user_role (not userroleenum).
   - This diverges from the backend expectation and later migrations.
   - If a DB applied 007 but not 014/015, backend expecting userroleenum or only 3 labels may see mismatches.

6) Alignment migrations (014_align_users_table_and_userroleenum.sql)
   - Creates public.userroleenum AS ENUM ('user','admin','moderator') [lowercase].
   - Normalizes existing role values to lowercase and maps variants (e.g., 'USER','MOD') to valid labels.
   - Converts users.role to public.userroleenum via temp-column swap, sets NOT NULL and default 'user'.
   - Adds/ensures email/username unique indexes, preferences JSONB default, timestamps, and triggers.

7) Reinforcement migration (015_users_role_to_userroleenum.sql)
   - Ensures userroleenum exists with proper labels and users.role is converted (idempotent).
   - Again, normalizes role values and enforces NOT NULL + default.

OpenAPI/backend expectation
- UserRole enum: ["user","admin","moderator"] (lowercase).
- Backend expects DB enum values to be lowercase and the enum type name to be userroleenum.

Likely Cause of InvalidTextRepresentationError on /auth/register
- Occurs when inserting a label into an enum column that doesn't include that label.
- Scenarios likely causing it:
  A) users.role is of type userroleenum and backend (or seed path) attempts to insert uppercase 'USER' or any non-listed value -> error.
  B) DB applied migration 007 leaving users.role as type user_role (with different name and labels), and backend (or ORM) expects/targets userroleenum, leading to type/label mismatch.
  C) Manual DB creation of enum with uppercase labels (not found in repo) while backend sends lowercase (or vice versa).

Final Determination of Enum Case
- Based on migrations 014 and 015, the definitive enum values in DB should be lowercase: 'user','admin','moderator'.
- There is no migration in the repo that defines uppercase enum labels; uppercase appears only in some mock data inserts (text), not in enum definitions.

Actionable Verification Queries (to run against the live DB)
- Check enum types and labels:
  SELECT t.typname, e.enumlabel
  FROM pg_type t
  JOIN pg_enum e ON t.oid = e.enumtypid
  WHERE t.typname IN ('userroleenum','user_role')
  ORDER BY t.typname, e.enumsortorder;

- Check the users.role column type:
  SELECT data_type, udt_name
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='users' AND column_name='role';

- Inspect existing role values:
  SELECT DISTINCT role::text FROM public.users;

Recommended Fix Plan
1) If users.role is not type public.userroleenum, apply migrations 014 and 015 to convert safely.
2) Normalize any existing role values to lowercase before conversion (014/015 do this).
3) Ensure backend sends no explicit role (let DB default 'user') or always sends lowercase values.
4) Avoid running legacy mock migrations 004/005 in any environment with enum role, or adjust them to use lowercase valid labels.
5) If any 'premium' roles exist from a DB migrated with 007, decide policy (map to 'user' or add label) before converting to userroleenum.

Notes
- The presence of 007 in this repo indicates a historical divergence. 014 and 015 explicitly align to a simpler, lowercase-only enum, consistent with backend OpenAPI.
- The error reported aligns most with an attempt to insert uppercase role strings into the lowercase-only enum column.

Prepared by: BugFixingAndVerificationAgent
