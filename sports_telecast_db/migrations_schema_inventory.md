# Sports Telecast DB - Migrations Schema Inventory

This document lists all database objects (tables, types, indices, triggers, and views) defined by the SQL migration files under sports_telecast_db/migrations. It is derived from reading all migration SQL files and consolidating the schema as defined by the migrations (not runtime introspection).

Note on duplicates and multiple schema definitions:
- Early migrations (001_initial_schema*.sql) define a simpler schema.
- Migration 007_comprehensive_schema_migration.sql introduces a more extensive, canonical schema. Where overlaps exist, both are listed for completeness since all files are present in the migrations folder.
- Migration 013_create_user_table.sql adds a separate "user" table (singular) using SERIAL PK, distinct from the "users" table used elsewhere.

Custom Types (Enums)
- match_status: 'scheduled' | 'live' | 'finished' | 'cancelled' | 'postponed' (001, 007)
- emoji_type: 'clap' | 'fire' | 'heart' | 'thumbs_up' | 'celebration' | 'shocked' | 'angry' | 'sad' | 'laugh' | 'goal' (001, 007, 011)
- user_role: 'user' | 'admin' | 'moderator' | 'premium' (007)
- notification_type: 'match_start' | 'goal_scored' | 'match_end' | 'event_reminder' | 'system' (007)

Tables

1) users (001_initial_schema.sql, 001_initial_schema_fixed.sql)
- user_id UUID PK DEFAULT uuid_generate_v4()
- email VARCHAR(255) UNIQUE NOT NULL
- username VARCHAR(50) UNIQUE NOT NULL
- password_hash VARCHAR(255) NOT NULL
- full_name VARCHAR(255)
- avatar_url TEXT
- role VARCHAR(20) DEFAULT 'user' CHECK (IN 'user','admin','moderator')
- is_active BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_users_updated_at BEFORE UPDATE -> update_updated_at_column()

2) user_preferences (001, 001_fixed)
- preference_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID NOT NULL FK -> users(user_id) ON DELETE CASCADE
- favorite_teams TEXT[] DEFAULT '{}'
- favorite_sports TEXT[] DEFAULT '{}'
- notification_settings JSONB DEFAULT '{}'
- preferred_language VARCHAR(10) DEFAULT 'en'
- timezone VARCHAR(50) DEFAULT 'UTC'
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_user_preferences_updated_at BEFORE UPDATE -> update_updated_at_column()

3) sports (001, 001_fixed)
- sport_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(50) UNIQUE NOT NULL
- display_name VARCHAR(100) NOT NULL
- description TEXT
- is_active BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

4) teams (001, 001_fixed)
- team_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(255) NOT NULL
- short_name VARCHAR(10) NOT NULL
- logo_url TEXT
- colors JSONB DEFAULT '{}'
- sport_id UUID NOT NULL FK -> sports(sport_id)
- is_active BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_teams_updated_at BEFORE UPDATE -> update_updated_at_column()

5) events (001, 001_fixed)
- event_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(255) NOT NULL
- description TEXT
- sport_id UUID NOT NULL FK -> sports(sport_id)
- start_date TIMESTAMPTZ NOT NULL
- end_date TIMESTAMPTZ NOT NULL
- location VARCHAR(255)
- organizer VARCHAR(255)
- logo_url TEXT
- banner_url TEXT
- is_featured BOOLEAN DEFAULT false
- is_active BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_events_updated_at BEFORE UPDATE -> update_updated_at_column()

6) matches (001, 001_fixed)
- match_id UUID PK DEFAULT uuid_generate_v4()
- event_id UUID NOT NULL FK -> events(event_id)
- home_team_id UUID NOT NULL FK -> teams(team_id)
- away_team_id UUID NOT NULL FK -> teams(team_id)
- sport_id UUID NOT NULL FK -> sports(sport_id)
- status match_status DEFAULT 'scheduled'
- start_time TIMESTAMPTZ NOT NULL
- end_time TIMESTAMPTZ
- venue VARCHAR(255)
- competition VARCHAR(255)
- round VARCHAR(50)
- stream_url TEXT
- viewer_count INTEGER DEFAULT 0
- is_featured BOOLEAN DEFAULT false
- is_trending BOOLEAN DEFAULT false
- thumbnail_url TEXT
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_matches_updated_at BEFORE UPDATE -> update_updated_at_column()

7) match_scores
- 001_initial_schema.sql:
  - score_id UUID PK DEFAULT uuid_generate_v4()
  - match_id UUID NOT NULL FK -> matches(match_id) ON DELETE CASCADE
  - home_score INTEGER DEFAULT 0
  - away_score INTEGER DEFAULT 0
  - period_scores JSONB DEFAULT '[]'
  - current_time VARCHAR(10)
  - created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
  - updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- 001_initial_schema_fixed.sql:
  - current_time renamed to match_time VARCHAR(10)
Triggers:
- update_match_scores_updated_at BEFORE UPDATE -> update_updated_at_column()

8) match_events (001, 001_fixed)
- event_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id) ON DELETE CASCADE
- event_type VARCHAR(50) NOT NULL
- minute INTEGER NOT NULL
- team_id UUID NOT NULL FK -> teams(team_id)
- player_name VARCHAR(255)
- description TEXT NOT NULL
- details TEXT
- impact VARCHAR(20) DEFAULT 'medium'
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

9) match_statistics (001, 001_fixed)
- stat_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id) ON DELETE CASCADE
- stat_type VARCHAR(50) NOT NULL
- home_value INTEGER DEFAULT 0
- away_value INTEGER DEFAULT 0
- home_display VARCHAR(20)
- away_display VARCHAR(20)
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

10) match_lineups (001, 001_fixed)
- lineup_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id) ON DELETE CASCADE
- team_id UUID NOT NULL FK -> teams(team_id)
- formation VARCHAR(20)
- players JSONB NOT NULL
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Triggers:
- update_match_lineups_updated_at BEFORE UPDATE -> update_updated_at_column()

11) highlights (001, 001_fixed)
- highlight_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id)
- title VARCHAR(255) NOT NULL
- description TEXT
- video_url TEXT NOT NULL
- thumbnail_url TEXT
- duration INTEGER NOT NULL
- tags TEXT[] DEFAULT '{}'
- view_count INTEGER DEFAULT 0
- is_featured BOOLEAN DEFAULT false
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

12) stream_qualities (001, 001_fixed)
- quality_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id) ON DELETE CASCADE
- quality_name VARCHAR(20) NOT NULL
- stream_url TEXT NOT NULL
- bitrate INTEGER
- resolution VARCHAR(20)
- is_default BOOLEAN DEFAULT false
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

13) emoji_assets (001, 001_fixed; extended by 008/009/010/012/011)
- emoji_id UUID PK DEFAULT uuid_generate_v4()
- emoji_type emoji_type NOT NULL
- name VARCHAR(50) NOT NULL
- image_url TEXT NOT NULL
- description TEXT
- unicode_char VARCHAR(10)
- color VARCHAR(7)
- gradient_class VARCHAR(100)
- sound_config JSONB
- sort_order INTEGER DEFAULT 0
- is_active BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- emoji_path TEXT (008 added)
Constraints/Indexes:
- UNIQUE(emoji_type) via idx_emoji_assets_type and uq_emoji_assets_emoji_type (008/011)

14) emoji_reactions (001, 001_fixed; aligned/enhanced by 008, 011)
- reaction_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID NOT NULL FK -> users(user_id) (011 makes nullable user_id then FK)
- event_id UUID NOT NULL FK -> events(event_id)
- match_id UUID FK -> matches(match_id)
- emoji_id UUID NOT NULL FK -> emoji_assets(emoji_id)
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP (008/011)
- emoji_type emoji_type NOT NULL (008 adds and backfills; 011 includes)
Triggers:
- update_emoji_reactions_updated_at BEFORE UPDATE -> update_updated_at_column() (008/011)

15) emoji_reaction_summary (001, 001_fixed)
- summary_id UUID PK DEFAULT uuid_generate_v4()
- event_id UUID NOT NULL FK -> events(event_id)
- match_id UUID FK -> matches(match_id)
- emoji_id UUID NOT NULL FK -> emoji_assets(emoji_id)
- reaction_count INTEGER DEFAULT 0
- last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- UNIQUE(event_id, match_id, emoji_id)

16) chat_messages (001, 001_fixed)
- message_id UUID PK DEFAULT uuid_generate_v4()
- event_id UUID NOT NULL FK -> events(event_id)
- match_id UUID FK -> matches(match_id)
- user_id UUID NOT NULL FK -> users(user_id)
- message TEXT NOT NULL
- message_type VARCHAR(20) DEFAULT 'text'
- is_visible BOOLEAN DEFAULT true
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

17) viewer_sessions (001, 001_fixed)
- session_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID FK -> users(user_id)
- match_id UUID NOT NULL FK -> matches(match_id)
- ip_address INET
- user_agent TEXT
- join_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- leave_time TIMESTAMPTZ
- duration INTEGER
- quality_watched VARCHAR(20)

18) viewer_count_snapshots (001, 001_fixed)
- snapshot_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches(match_id)
- viewer_count INTEGER NOT NULL
- timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

19) user_profiles (007_comprehensive_schema_migration.sql)
- profile_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID NOT NULL FK -> users(user_id) ON DELETE CASCADE
- favorite_teams UUID[] DEFAULT '{}'
- favorite_sports UUID[] DEFAULT '{}'
- favorite_players TEXT[] DEFAULT '{}'
- notification_settings JSONB DEFAULT '{...}' (see file for default)
- privacy_settings JSONB DEFAULT '{...}'
- streaming_preferences JSONB DEFAULT '{...}'
- preferred_language VARCHAR(10) DEFAULT 'en'
- timezone VARCHAR(50) DEFAULT 'UTC'
- theme_preference VARCHAR(20) DEFAULT 'dark'
- subscription_tier VARCHAR(20) DEFAULT 'free' CHECK IN ('free','premium','vip')
- subscription_expires_at TIMESTAMPTZ
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(user_id)
Indexes:
- idx_user_profiles_user_id
- idx_user_profiles_subscription

20) sports (007) — extended version (note: also defined in 001)
- sport_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(50) UNIQUE NOT NULL
- display_name VARCHAR(100) NOT NULL
- description TEXT
- icon_url TEXT
- color_scheme JSONB DEFAULT '{}'
- rules_summary TEXT
- typical_duration INTEGER
- is_active BOOLEAN DEFAULT true
- sort_order INTEGER DEFAULT 0
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_sports_active

21) teams (007) — extended version (note: also defined in 001)
- team_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(255) NOT NULL
- short_name VARCHAR(10) NOT NULL
- code VARCHAR(5) NOT NULL
- logo_url TEXT
- banner_url TEXT
- colors JSONB NOT NULL DEFAULT '{"primary":"#000000","secondary":"#FFFFFF"}'
- sport_id UUID NOT NULL FK -> sports
- country VARCHAR(100)
- city VARCHAR(100)
- founded_year INTEGER CHECK (>1800)
- stadium_name VARCHAR(255)
- stadium_capacity INTEGER CHECK (>0)
- website_url TEXT
- social_media JSONB DEFAULT '{}'
- is_active BOOLEAN DEFAULT true
- follower_count INTEGER DEFAULT 0
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(name, sport_id)
- UNIQUE(code, sport_id)
Indexes:
- idx_teams_sport_id, idx_teams_active, idx_teams_country

22) events (007) — extended version (note: also defined in 001)
- event_id UUID PK DEFAULT uuid_generate_v4()
- name VARCHAR(255) NOT NULL
- display_name VARCHAR(255) NOT NULL
- description TEXT
- event_type VARCHAR(50) DEFAULT 'tournament'
- sport_id UUID NOT NULL FK -> sports
- season VARCHAR(20)
- start_date TIMESTAMPTZ NOT NULL
- end_date TIMESTAMPTZ NOT NULL
- location VARCHAR(255)
- country VARCHAR(100)
- organizer VARCHAR(255)
- logo_url TEXT
- banner_url TEXT
- official_website TEXT
- prize_pool DECIMAL(15,2) CHECK (>=0)
- currency VARCHAR(3) DEFAULT 'USD'
- is_featured BOOLEAN DEFAULT false
- is_active BOOLEAN DEFAULT true
- follower_count INTEGER DEFAULT 0
- total_matches INTEGER DEFAULT 0
- completed_matches INTEGER DEFAULT 0 CHECK (completed_matches <= total_matches)
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_events_sport_id, idx_events_featured, idx_events_active, idx_events_dates, idx_events_season
Constraints:
- CHECK (end_date >= start_date)

23) matches (007) — extended version (note: also defined earlier)
- match_id UUID PK DEFAULT uuid_generate_v4()
- event_id UUID NOT NULL FK -> events
- home_team_id UUID NOT NULL FK -> teams
- away_team_id UUID NOT NULL FK -> teams
- sport_id UUID NOT NULL FK -> sports
- status match_status DEFAULT 'scheduled'
- match_number INTEGER
- round_name VARCHAR(100)
- stage VARCHAR(50)
Scheduling:
- scheduled_start TIMESTAMPTZ NOT NULL
- actual_start TIMESTAMPTZ
- scheduled_end TIMESTAMPTZ
- actual_end TIMESTAMPTZ
Venue:
- venue_name VARCHAR(255)
- venue_city VARCHAR(100)
- venue_country VARCHAR(100)
- venue_capacity INTEGER CHECK (>0)
Details:
- competition VARCHAR(255)
- season VARCHAR(20)
- importance_level INTEGER DEFAULT 1 CHECK (1..5)
Media:
- stream_url TEXT
- backup_stream_url TEXT
- thumbnail_url TEXT
- preview_url TEXT
Analytics:
- viewer_count INTEGER DEFAULT 0 CHECK (>=0)
- peak_viewer_count INTEGER DEFAULT 0
- total_reactions INTEGER DEFAULT 0
- chat_message_count INTEGER DEFAULT 0
Flags:
- is_featured BOOLEAN DEFAULT false
- is_trending BOOLEAN DEFAULT false
- is_live BOOLEAN DEFAULT false
- has_highlights BOOLEAN DEFAULT false
- is_premium BOOLEAN DEFAULT false
Weather:
- weather_conditions JSONB
Timestamps:
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_matches_status, idx_matches_scheduled_start, idx_matches_event_id, idx_matches_home_team, idx_matches_away_team,
  idx_matches_sport_id, idx_matches_featured, idx_matches_trending, idx_matches_live, idx_matches_importance,
  idx_matches_status_start_time, idx_matches_teams_start_time

24) match_scores (007) — extended version
- score_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches ON DELETE CASCADE
- home_score INTEGER NOT NULL DEFAULT 0
- away_score INTEGER NOT NULL DEFAULT 0
- home_penalty_score INTEGER
- away_penalty_score INTEGER
- period_scores JSONB NOT NULL DEFAULT '[]'
- current_period VARCHAR(20)
- match_time VARCHAR(10)
- time_elapsed_seconds INTEGER DEFAULT 0
- is_final_score BOOLEAN NOT NULL DEFAULT false
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(match_id)
- CHECK scores non-negative, penalty pair logic

25) match_events (007) — extended version
- event_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches ON DELETE CASCADE
- event_type VARCHAR(50) NOT NULL
- event_subtype VARCHAR(50)
- minute INTEGER NOT NULL CHECK (0..250)
- added_time INTEGER DEFAULT 0 CHECK (0..30)
- period VARCHAR(20) DEFAULT '1st Half'
- team_id UUID NOT NULL FK -> teams
- player_name VARCHAR(255)
- player_id UUID
- assistant_player VARCHAR(255)
- description TEXT NOT NULL
- details JSONB DEFAULT '{}'
- impact_level VARCHAR(20) NOT NULL DEFAULT 'medium' IN ('low','medium','high','critical')
- video_url TEXT
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_match_events_match_id, idx_match_events_type, idx_match_events_team_id, idx_match_events_minute

26) match_statistics (007) — extended version
- stat_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches ON DELETE CASCADE
- stat_category VARCHAR(50) NOT NULL
- stat_type VARCHAR(50) NOT NULL
- home_value DECIMAL(10,2) NOT NULL DEFAULT 0
- away_value DECIMAL(10,2) NOT NULL DEFAULT 0
- home_display VARCHAR(50)
- away_display VARCHAR(50)
- unit VARCHAR(20)
- sort_order INTEGER DEFAULT 0
- is_percentage BOOLEAN DEFAULT false
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- CHECK non-negative
- UNIQUE(match_id, stat_type)
Indexes:
- idx_match_statistics_match_id, idx_match_statistics_category

27) match_lineups (007) — extended version
- lineup_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches ON DELETE CASCADE
- team_id UUID NOT NULL FK -> teams
- formation VARCHAR(20)
- formation_image_url TEXT
- starting_players JSONB NOT NULL DEFAULT '[]'
- substitute_players JSONB NOT NULL DEFAULT '[]'
- coaching_staff JSONB DEFAULT '[]'
- is_confirmed BOOLEAN DEFAULT false
- lineup_submitted_at TIMESTAMPTZ
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(match_id, team_id)
Indexes:
- idx_match_lineups_match_id, idx_match_lineups_team_id

28) highlights (007) — extended version
- highlight_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches
- event_id UUID FK -> match_events(event_id)
- title VARCHAR(255) NOT NULL
- description TEXT
- highlight_type VARCHAR(50) DEFAULT 'general'
- video_url TEXT NOT NULL
- thumbnail_url TEXT
- preview_gif_url TEXT
- duration_seconds INTEGER NOT NULL CHECK (>0)
- start_time_seconds INTEGER DEFAULT 0
- end_time_seconds INTEGER CHECK (> start_time_seconds)
- quality VARCHAR(20) DEFAULT 'HD'
- file_size_mb DECIMAL(8,2)
- encoding_format VARCHAR(20) DEFAULT 'mp4'
- tags TEXT[] NOT NULL DEFAULT '{}'
- player_names TEXT[] DEFAULT '{}'
- team_tags UUID[] DEFAULT '{}'
- content_rating VARCHAR(10) DEFAULT 'G'
- language VARCHAR(10) DEFAULT 'en'
- view_count INTEGER NOT NULL DEFAULT 0 CHECK (>=0)
- like_count INTEGER DEFAULT 0
- share_count INTEGER DEFAULT 0
- download_count INTEGER DEFAULT 0
- is_featured BOOLEAN DEFAULT false
- is_trending BOOLEAN DEFAULT false
- is_premium_content BOOLEAN DEFAULT false
- is_public BOOLEAN DEFAULT true
- auto_generated BOOLEAN DEFAULT false
- published_at TIMESTAMPTZ
- expires_at TIMESTAMPTZ
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_highlights_match_id, idx_highlights_type, idx_highlights_featured, idx_highlights_trending, idx_highlights_public,
  idx_highlights_view_count, idx_highlights_published_at
Compound:
- idx_highlights_match_type_featured

29) stream_qualities (007) — extended version
- quality_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID NOT NULL FK -> matches ON DELETE CASCADE
- quality_name VARCHAR(20) NOT NULL
- quality_label VARCHAR(50) NOT NULL
- stream_url TEXT NOT NULL
- bitrate_kbps INTEGER CHECK (>0 or null)
- resolution_width INTEGER
- resolution_height INTEGER
- fps INTEGER DEFAULT 30 CHECK (0<fps<=120)
- codec VARCHAR(20) DEFAULT 'H.264'
- is_default BOOLEAN DEFAULT false
- is_adaptive BOOLEAN DEFAULT false
- minimum_bandwidth_mbps DECIMAL(5,2)
- is_premium_quality BOOLEAN DEFAULT false
- sort_order INTEGER DEFAULT 0
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(match_id, quality_name)
Indexes:
- idx_stream_qualities_match_id, idx_stream_qualities_default

30) schedules (007)
- schedule_id UUID PK DEFAULT uuid_generate_v4()
- match_id UUID FK -> matches ON DELETE CASCADE
- event_id UUID FK -> events ON DELETE CASCADE
- schedule_type VARCHAR(50) DEFAULT 'match'
- original_start_time TIMESTAMPTZ NOT NULL
- current_start_time TIMESTAMPTZ NOT NULL
- estimated_end_time TIMESTAMPTZ
- actual_end_time TIMESTAMPTZ
- timezone VARCHAR(50) DEFAULT 'UTC'
- broadcast_regions TEXT[] DEFAULT '{}'
- blackout_regions TEXT[] DEFAULT '{}'
- primary_broadcaster VARCHAR(100)
- secondary_broadcasters TEXT[] DEFAULT '{}'
- commentary_languages TEXT[] DEFAULT '{\"en\"}'
- schedule_status VARCHAR(20) DEFAULT 'confirmed' IN ('confirmed','tentative','postponed','cancelled')
- change_reason TEXT
- change_count INTEGER DEFAULT 0
- last_changed_at TIMESTAMPTZ
- reminder_sent BOOLEAN DEFAULT false
- notification_times INTEGER[] DEFAULT '{60,15,5}'
- weather_dependent BOOLEAN DEFAULT false
- weather_backup_plan TEXT
- is_prime_time BOOLEAN DEFAULT false
- is_holiday BOOLEAN DEFAULT false
- requires_subscription BOOLEAN DEFAULT false
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_schedules_match_id, idx_schedules_event_id, idx_schedules_current_start, idx_schedules_status,
  idx_schedules_type, idx_schedules_prime_time, idx_schedules_time_status

31) user_schedule_preferences (007)
- preference_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID NOT NULL FK -> users(user_id) ON DELETE CASCADE
- default_reminder_times INTEGER[] DEFAULT '{60,15}'
- reminder_methods TEXT[] DEFAULT '{\"push\",\"email\"}'
- favorite_teams_only BOOLEAN DEFAULT false
- favorite_sports_only BOOLEAN DEFAULT false
- featured_matches_only BOOLEAN DEFAULT false
- minimum_importance_level INTEGER DEFAULT 1 CHECK (1..5)
- display_timezone VARCHAR(50) DEFAULT 'UTC'
- time_format VARCHAR(10) DEFAULT '24h'
- date_format VARCHAR(20) DEFAULT 'YYYY-MM-DD'
- calendar_sync_enabled BOOLEAN DEFAULT false
- calendar_provider VARCHAR(20)
- calendar_sync_token TEXT
- last_sync_at TIMESTAMPTZ
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
- updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Constraints:
- UNIQUE(user_id)
Indexes:
- idx_user_schedule_preferences_user_id

32) notifications (007)
- notification_id UUID PK DEFAULT uuid_generate_v4()
- user_id UUID NOT NULL FK -> users(user_id) ON DELETE CASCADE
- notification_type notification_type NOT NULL
- title VARCHAR(255) NOT NULL
- message TEXT NOT NULL
- match_id UUID FK -> matches(match_id) ON DELETE SET NULL
- event_id UUID FK -> events(event_id) ON DELETE SET NULL
- team_id UUID FK -> teams(team_id) ON DELETE SET NULL
- scheduled_for TIMESTAMPTZ NOT NULL
- sent_at TIMESTAMPTZ
- read_at TIMESTAMPTZ
- push_notification_sent BOOLEAN DEFAULT false
- email_sent BOOLEAN DEFAULT false
- sms_sent BOOLEAN DEFAULT false
- in_app_shown BOOLEAN DEFAULT false
- is_read BOOLEAN DEFAULT false
- is_archived BOOLEAN DEFAULT false
- delivery_status VARCHAR(20) DEFAULT 'pending' IN ('pending','sent','delivered','failed')
- retry_count INTEGER DEFAULT 0
- max_retries INTEGER DEFAULT 3
- next_retry_at TIMESTAMPTZ
- created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
Indexes:
- idx_notifications_user_id, idx_notifications_type, idx_notifications_scheduled, idx_notifications_status,
  idx_notifications_read, idx_notifications_match_id

33) "user" (013_create_user_table.sql) [singular, separate schema]
- id SERIAL PK
- email VARCHAR(255) UNIQUE NOT NULL
- username VARCHAR(50) UNIQUE NOT NULL
- password_hash TEXT NOT NULL
- full_name VARCHAR(255)
- avatar_url TEXT
- role VARCHAR(20) NOT NULL DEFAULT 'user'
- preferences JSONB DEFAULT '{}'::jsonb
- is_active BOOLEAN NOT NULL DEFAULT TRUE
- created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
- updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
Indexes:
- idx_user_email, idx_user_username
Trigger:
- trg_user_set_updated_at BEFORE UPDATE -> set_updated_at_user()

Views (007)
- match_details_view
  Columns (selected):
  - m: match_id, status, scheduled_start, actual_start, venue_name, viewer_count, is_featured, is_trending, is_live
  - e: event_name, event_display_name, event_type, season
  - s: sport_name, sport_display_name
  - ht: home_team_name, home_team_short, home_team_code, home_team_logo, home_team_colors
  - at: away_team_name, away_team_short, away_team_code, away_team_logo, away_team_colors
  - ms: home_score, away_score, match_time, current_period
  - sc: scheduled_time, timezone, schedule_status

- user_favorites_view
  Columns:
  - u: user_id, username, full_name
  - favorite_teams_details (json)
  - favorite_sports_details (json)

Functions and Triggers (non-exhaustive key ones)
- update_updated_at_column() (001/007/011)
- update_emoji_reaction_summary() + trigger update_emoji_summary_on_reaction (001/001_fixed)
- update_event_match_counts() + trigger update_event_counts_on_match_update (007)
- update_match_analytics() + trigger update_match_analytics_trigger (007)
- track_schedule_changes() + trigger track_schedule_changes_trigger (007)
- auto_archive_notifications(), create_daily_archive_job() (007)
- set_updated_at_user() + trg_user_set_updated_at (013)

Indexes (selected unique/important)
- Users: idx_users_email, idx_users_username, idx_users_active, idx_users_role (007), idx_users_created_at (007)
- Matches: idx_matches_status, idx_matches_scheduled_start, idx_matches_event_id, idx_matches_featured, idx_matches_trending, composite idx_matches_status_start_time, idx_matches_teams_start_time
- Events: idx_events_sport_id, idx_events_dates, idx_events_featured, idx_events_active, idx_events_season
- Emoji: idx_emoji_assets_type (UNIQUE on emoji_type); emoji_reactions: idx_emoji_reactions_event_type, idx_emoji_reactions_user, idx_emoji_reactions_created_at
- Highlights: idx_highlights_match_id, idx_highlights_type, idx_highlights_featured, idx_highlights_trending, idx_highlights_public, idx_highlights_view_count, idx_highlights_published_at, idx_highlights_match_type_featured
- Schedules: idx_schedules_match_id, idx_schedules_event_id, idx_schedules_current_start, idx_schedules_status, idx_schedules_type, idx_schedules_prime_time, idx_schedules_time_status
- Notifications: idx_notifications_user_id, idx_notifications_type, idx_notifications_scheduled, idx_notifications_status, idx_notifications_read, idx_notifications_match_id

Notes and Observations relative to backend expectations (from provided OpenAPI excerpts)
- Backend expects emoji endpoints and reaction summaries; relevant tables: emoji_assets, emoji_reactions, emoji_reaction_summary (present).
- Backend expects user auth and profiles; relevant tables:
  - users (UUID-based, comprehensive in 007) and user_profiles (007) align with JWT auth and profile features.
  - A separate "user" (singular) table exists (013) with SERIAL id. This appears redundant/conflicting with users/user_profiles. Clarify intended usage; likely "users" is canonical.
- Highlights endpoints exist; highlights table present (baseline and extended).
- Debug/tables endpoint expects alembic_version possibly; migrations include 01_widen_alembic_version.sql in docker-entrypoint-initdb.d but not an Alembic-managed set here. Consider presence of alembic_version table if using Alembic externally.

Seed and Data Migrations
- 002_seed_data*.sql, 003_comprehensive_seed_data.sql: Insert realistic seed data for sports, teams, events, matches, scores, stats, lineups, highlights, emoji assets, reactions, viewers, and chat.
- 004_realistic_mock_data.sql, 005_corrected_mock_data.sql: Contain alternate schemas/IDs (non-UUID) and tables like user_emoji_reactions that are not part of canonical schema. These may conflict with canonical schema if executed; they include deletes and differing types. Treat with caution for production.
- 006_complete_user_data.sql: Adds more seed data and updates emoji summary with triggers.

Potential Conflicts/Items to Verify
- Duplication of type/table definitions between 001 and 007. If both run on a fresh DB, 007 guards creation with IF NOT EXISTS and DO blocks for enums, but duplicate object handling is present; may be safe.
- The "user" table (013) collides conceptually with the "users" table used elsewhere. Ensure backend uses one consistent user table (likely "users"). 013 is idempotent and separate but may be unnecessary.
- Some older mock migrations (004, 005) define tables/columns not in canonical schema (e.g., user_emoji_reactions, events.sport_type) and use non-UUID IDs; running them may break the canonical schema. For production alignment with backend, avoid 004/005 or refactor them.

Summary of Canonical Tables for Backend Alignment
- users, user_profiles
- sports, teams
- events
- matches, match_scores, match_events, match_statistics, match_lineups
- highlights
- stream_qualities
- emoji_assets, emoji_reactions, emoji_reaction_summary
- chat_messages
- viewer_sessions, viewer_count_snapshots
- schedules, user_schedule_preferences
- notifications
- views: match_details_view, user_favorites_view
