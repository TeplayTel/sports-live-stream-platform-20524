# Final Findings: users.role enum (userroleenum) analysis

Context:
- Subtask: Determine cause of /auth/register InvalidTextRepresentationError related to userroleenum.
- Container: sports_telecast_db

Answers to task questions:

1) Are DB enum values lowercase ('user','admin','moderator') or uppercase?
   - Intended and enforced by migrations 014 and 015: lowercase only.
   - Enum type: public.userroleenum AS ENUM ('user','admin','moderator').

2) Did any migrations or manual intervention leave a mismatch?
   - Potential mismatches identified:
     a) Legacy mock data migrations (004_realistic_mock_data.sql, 005_corrected_mock_data.sql) insert UPPERCASE role strings ('USER','ADMIN','MODERATOR'). If run after users.role became an enum, they will cause InvalidTextRepresentationError.
     b) Migration 007 (007_comprehensive_schema_migration.sql) defines a different enum user_role (labels: 'user','admin','moderator','premium') and sets users.role to user_role. If a DB applied 007 without 014/015, the type/label set will not align with backend expectations (type name and labels differ).
   - No migrations in this repo define uppercase enum labels. Any uppercase presence would come from data inserts, not enum labels.

3) Discrepancies between backend expectations and DB definitions:
   - Backend (OpenAPI) expects:
     - Type name: userroleenum
     - Labels: 'user','admin','moderator' (lowercase)
   - DB migrations:
     - 014 and 015 enforce exactly this (userroleenum, lowercase).
     - 001/003 earlier stages used VARCHAR with a lowercase-only CHECK (compatible).
     - 007 introduces user_role and 'premium' (incompatible if left applied).
     - 004/005 data scripts use uppercase role strings (incompatible once enum enforced).

Likely cause of InvalidTextRepresentationError at /auth/register:
- Inserting a non-existent enum label into users.role of type userroleenum, most commonly an uppercase 'USER' or other variant, or operating against a DB where users.role is still of type user_role instead of userroleenum.

Verification next steps (run on live DB):
- Check enum labels/type: see migrations/userroleenum_verification_checklist.sql
- Confirm users.role udt_name = 'userroleenum'
- Ensure existing role values are lowercase only

Remediation plan:
1) If users.role is not userroleenum or labels differ, run migrations:
   - 014_align_users_table_and_userroleenum.sql
   - 015_users_role_to_userroleenum.sql
2) Normalize any existing data (migrations handle mapping; unknowns -> 'user').
3) Ensure backend sends lowercase role values or omits role so DB default 'user' applies.
4) Do not run legacy 004/005 scripts in environments with enum role unless adjusted to lowercase values.

References:
- 014_align_users_table_and_userroleenum.sql
- 015_users_role_to_userroleenum.sql
- 007_comprehensive_schema_migration.sql (divergent user_role enum)
- 004_realistic_mock_data.sql / 005_corrected_mock_data.sql (uppercase role inserts)
- USERROLEENUM_README.md
- userroleenum_verification_checklist.sql
- userroleenum_analysis_report.md
- userroleenum_discrepancy_summary.txt
