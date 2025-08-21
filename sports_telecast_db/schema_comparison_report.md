# Schema Comparison Report: DB Migrations vs Backend DATABASE_MODELS

This report compares:
- DB migrations inventory: sports_telecast_db/migrations_schema_inventory.md
- Backend schema requirements: sports_telecast_backend/DATABASE_MODELS.md

Goal: Verify migrations define only the required tables/fields for the FastAPI backend, and flag any differences (missing fields/tables, unused DB tables, naming/type mismatches).

Summary Verdict
- Not fully aligned. Core tables exist, but there are notable naming and normalization differences. Some extra tables exist in DB migrations not required by backend. Several backend-expected fields have different names or are in separate tables.

High-Importance Findings

1) Users table vs singular "user"
- Backend expects: users (UUID PK, role enum, preferences JSON).
- Migrations: 
  - users (UUID PK) present and adequate (001 baseline; 007 richer).
  - Extra/unused: "user" (singular) table from 013 with SERIAL PK (redundant wrt backend).
- Impact: Unused/conflicting table exists. Recommendation: Exclude/skip 013 in backend-aligned environments.

2) Events sport_type vs sport_id (naming/type mismatch)
- Backend: events.sport_type (sporttypeenum).
- Migrations: events.sport_id (FK to sports), no sport_type enum column.
- Impact: Backend model mismatches DB. Recommendation: Backend should adopt sport_id FKs; alternatively, DB could add sport_type (denormalized) if insisted.

3) Matches fields and normalization
- Backend: matches has sport_type, home_score, away_score, period_scores, statistics JSON.
- Migrations: matches uses sport_id FK; scores in match_scores; stats in match_statistics.
- Impact: Missing columns by backend expectations; data resides in separate tables. Recommendation: Backend to read match_scores/match_statistics and sport_id.

4) Emoji reactions table name mismatch
- Backend: user_emoji_reactions.
- Migrations: emoji_reactions (with emoji_type and match_id, timestamps).
- Impact: Name mismatch; backend should use emoji_reactions. Optionally create a view alias if backend cannot change soon.

5) Enum names/type differences
- Backend enums: sporttypeenum, matchstatusenum, userroleenum, emojitypeenum, profilevisibilityenum.
- Migrations enums: match_status, emoji_type, user_role, notification_type; no sporttypeenum; profile visibility not explicit as enum.
- Impact: Adjust backend to use DB enums where present and sport_id for sports; add profile visibility handling per DB structure or add enum to DB if required.

6) Emoji assets fallbacks
- Backend fallback references emoji_assets.file_location; expects image_url nullable OK.
- Migrations: emoji_assets includes emoji_id, emoji_type, image_url, name, etc., but legacy-like field appears as emoji_path (not file_location).
- Impact: Backend fallback may not find file_location. Recommendation: Backend derive from image_url/emoji_path or DB adds file_location alias/view.

7) Profiles fields mismatch
- Backend expects many fields (display_name, bio, avatar_url, cover_image_url, visibility enum, show flags, counters).
- Migrations (007) user_profiles focuses on preference/notification/subscription JSON and settings; missing several backend UI fields.
- Impact: Missing fields against backend expectations. Recommendation: Either extend DB schema or adjust backend to 007 structure.

8) Schedules/junction table
- Backend: schedules with date and schedule_matches (association table with composite PK).
- Migrations: Comprehensive schedules table, no schedule_matches association table documented.
- Impact: Missing schedule_matches relative to backend. Recommendation: Add schedule_matches or adjust backend.

9) Highlights minor differences
- Backend: duration (Integer), tags JSON.
- Migrations: duration_seconds (Integer), tags TEXT[] (extended schema).
- Impact: Minor field name/type mismatch. Recommendation: Adjust backend or add compat columns/views.

10) Extra/unused tables relative to backend current needs
- Present in migrations but not currently required: stream_qualities, emoji_reaction_summary, viewer_sessions, viewer_count_snapshots, notifications, various views and analytics tables. Not harmful, but not required by current backend models.

Compliance Matrix (abridged)

- users: Present; aligns (prefer 007). Extra: singular "user" table present (unused).
- user_profiles: Present but fields differ (backend expects more profile UI columns).
- teams: Present; aligns.
- sports: Present; backend prefers enum but DB uses normalized table + FK.
- events: Present; uses sport_id vs backend sport_type.
- matches: Present; lacks inline scores/stats; provided via separate tables.
- match_events: Present; aligns.
- match_scores: Present; backend expects inline scores (mismatch).
- match_statistics: Present; backend expects inline stats JSON (mismatch).
- highlights: Present; minor naming/type differences.
- emoji_assets: Present; need to consider file_location fallback vs emoji_path.
- emoji_reactions: Present; backend uses user_emoji_reactions (name mismatch).
- schedules: Present; structure differs; schedule_matches not present.
- schedule_matches: Missing (by backend spec).
- Alembic version table: DB repo includes widening script; backend uses Alembic. Ensure environment consistency.

Recommendations

Option A (preferred, backend-aligned to canonical DB):
- Update backend ORM and queries to:
  - Use sport_id references (join sports) instead of sport_type enums.
  - Read/write scores and stats via match_scores and match_statistics.
  - Use emoji_reactions table.
  - Adjust highlights to duration_seconds and tags TEXT[] (or cast).
  - Align profiles to 007 user_profiles fields or map required fields to existing JSON/settings.
  - Use schedules without schedule_matches or implement equivalent logic.

Option B (DB compatibility shims):
- Add DB compat elements:
  - Provide a view user_emoji_reactions pointing to emoji_reactions with projected columns.
  - Add schedule_matches association table.
  - Add display_name, bio, avatar_url, cover_image_url, profile_visibility enum and show flags to user_profiles.
  - Add duration (computed or duplicate) and tags JSON to highlights, or create a view.
  - Add file_location to emoji_assets as an alias to emoji_path or derive via trigger.
  - Avoid/skip 013 "user" migration.

Items to watch/avoid
- Do not run older mock migrations (004, 005) in production alignment—they may introduce conflicting non-UUID IDs or deprecated tables.

End of report.
