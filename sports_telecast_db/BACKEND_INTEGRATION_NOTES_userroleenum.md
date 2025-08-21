Backend Integration Notes: users.role enum (userroleenum)

Context:
- /auth/register reported InvalidTextRepresentationError related to userroleenum.

Canonical DB definition:
- Type: public.userroleenum
- Labels (lowercase only): 'user', 'admin', 'moderator'
- Default: 'user'
- Target column: public.users.role (enum)

Backend expectations/actions:
- Ensure any role value sent to the DB is lowercase: 'user' | 'admin' | 'moderator'.
- Prefer not to send role on registration; let DB default to 'user'.
- If client inputs role, normalize to lowercase on server before insert/update.

DB verification and remediation:
- Run migrations/userroleenum_verification_checklist.sql to confirm:
  - users.role udt_name = 'userroleenum'
  - enum labels are lowercase only
  - existing data uses lowercase
- If mismatches are found:
  - Apply migrations 014 and 015, or run migrations/016_fix_userroleenum_alignment.sql (idempotent remedial script).
  - Re-run verification, then re-test /auth/register.

Risk notes:
- Legacy data scripts 004/005 insert UPPERCASE roles; do not run in environments where users.role is enum.
- Migration 007 uses a different enum user_role (includes 'premium'); ensure 014/015/016 align to userroleenum.

References:
- migrations/userroleenum_analysis_report.md
- migrations/userroleenum_discrepancy_summary.txt
- migrations/userroleenum_verification_checklist.sql
- migrations/016_fix_userroleenum_alignment.sql
- USERROLEENUM_README.md
