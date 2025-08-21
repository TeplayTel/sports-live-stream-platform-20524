# User Role Enum - Canonical Definition and Verification

Canonical enum for users.role:
- Type name: userroleenum
- Labels (lowercase only): 'user', 'admin', 'moderator'
- Default: 'user'

Backend expectation:
- OpenAPI and backend code expect lowercase labels only and the enum type name userroleenum.

Relevant migrations:
- 014_align_users_table_and_userroleenum.sql
- 015_users_role_to_userroleenum.sql

Potential pitfalls:
- Legacy mock scripts (004/005) use uppercase role strings; these will fail if role is an enum.
- Migration 007 creates a different enum (user_role) including 'premium' and is not aligned with the backend.

How to verify your DB:
- See migrations/userroleenum_verification_checklist.sql
- For a full analysis and troubleshooting steps, see migrations/userroleenum_analysis_report.md

Fix plan (if mismatch found):
1) Run verification checklist queries.
2) If users.role is not userroleenum or enum labels differ, apply migrations 014 and 015.
3) Ensure any existing role values are lowercase and within the valid set; the migrations normalize them.
4) Ensure backend sends lowercase role values or omits role to use the 'user' default.
