-- ============================================================================
-- Sports Telecast Database - Comprehensive Schema Migration 
-- Migration: 007_comprehensive_schema_migration.sql
-- Description: Creates complete schema for users, profiles, matches, highlights, and schedules
-- Date: 2025-01-07
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================

-- Create custom enum types
DO $$ BEGIN
    CREATE TYPE match_status AS ENUM ('scheduled', 'live', 'finished', 'cancelled', 'postponed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE emoji_type AS ENUM ('clap','fire','heart','thumbs_up','celebration','shocked','angry','sad','laugh','goal');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator', 'premium');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM ('match_start', 'goal_scored', 'match_end', 'event_reminder', 'system');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- CORE USER MANAGEMENT TABLES
-- ============================================================================

-- Users table with comprehensive profile information
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    phone VARCHAR(20),
    country_code VARCHAR(3),
    role user_role NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    login_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_users_username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT chk_users_phone_format CHECK (phone IS NULL OR phone ~* '^[\+]?[1-9][\d]{0,15}$')
);

-- User profiles with extended preferences and settings
CREATE TABLE IF NOT EXISTS user_profiles (
    profile_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    favorite_teams UUID[] DEFAULT '{}',
    favorite_sports UUID[] DEFAULT '{}',
    favorite_players TEXT[] DEFAULT '{}',
    notification_settings JSONB NOT NULL DEFAULT '{
        "match_reminders": true,
        "goal_alerts": true,
        "live_notifications": true,
        "email_notifications": true,
        "push_notifications": true
    }',
    privacy_settings JSONB NOT NULL DEFAULT '{
        "profile_visibility": "public",
        "show_activity": true,
        "show_favorites": true
    }',
    streaming_preferences JSONB NOT NULL DEFAULT '{
        "default_quality": "auto",
        "autoplay": true,
        "subtitles": false,
        "preferred_language": "en"
    }',
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    theme_preference VARCHAR(20) DEFAULT 'dark',
    subscription_tier VARCHAR(20) DEFAULT 'free',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_user_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT uq_user_profiles_user_id UNIQUE (user_id),
    CONSTRAINT chk_user_profiles_subscription_tier CHECK (subscription_tier IN ('free', 'premium', 'vip'))
);

-- ============================================================================
-- SPORTS AND TEAMS STRUCTURE
-- ============================================================================

-- Sports categories and types
CREATE TABLE IF NOT EXISTS sports (
    sport_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    color_scheme JSONB DEFAULT '{}',
    rules_summary TEXT,
    typical_duration INTEGER, -- Duration in minutes
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Teams participating in matches
CREATE TABLE IF NOT EXISTS teams (
    team_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    code VARCHAR(5) NOT NULL, -- FIFA/official code
    logo_url TEXT,
    banner_url TEXT,
    colors JSONB NOT NULL DEFAULT '{"primary": "#000000", "secondary": "#FFFFFF"}',
    sport_id UUID NOT NULL,
    country VARCHAR(100),
    city VARCHAR(100),
    founded_year INTEGER,
    stadium_name VARCHAR(255),
    stadium_capacity INTEGER,
    website_url TEXT,
    social_media JSONB DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    follower_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_teams_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    
    -- Constraints
    CONSTRAINT uq_teams_name_sport UNIQUE (name, sport_id),
    CONSTRAINT uq_teams_code_sport UNIQUE (code, sport_id),
    CONSTRAINT chk_teams_founded_year CHECK (founded_year IS NULL OR founded_year > 1800),
    CONSTRAINT chk_teams_stadium_capacity CHECK (stadium_capacity IS NULL OR stadium_capacity > 0)
);

-- ============================================================================
-- EVENTS AND COMPETITIONS
-- ============================================================================

-- Sports events, tournaments, leagues, and competitions
CREATE TABLE IF NOT EXISTS events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL DEFAULT 'tournament', -- tournament, league, cup, friendly
    sport_id UUID NOT NULL,
    season VARCHAR(20), -- "2024-25", "2024", etc.
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255),
    country VARCHAR(100),
    organizer VARCHAR(255),
    logo_url TEXT,
    banner_url TEXT,
    official_website TEXT,
    prize_pool DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'USD',
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    follower_count INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    completed_matches INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_events_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    
    -- Constraints
    CONSTRAINT chk_events_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_events_prize_pool CHECK (prize_pool IS NULL OR prize_pool >= 0),
    CONSTRAINT chk_events_match_counts CHECK (completed_matches <= total_matches)
);

-- ============================================================================
-- MATCHES AND SCHEDULES
-- ============================================================================

-- Core matches table with comprehensive match information
CREATE TABLE IF NOT EXISTS matches (
    match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    home_team_id UUID NOT NULL,
    away_team_id UUID NOT NULL,
    sport_id UUID NOT NULL,
    status match_status NOT NULL DEFAULT 'scheduled',
    match_number INTEGER, -- Match number in tournament/league
    round_name VARCHAR(100), -- "Quarter Final", "Round 16", "Week 5"
    stage VARCHAR(50), -- "Group Stage", "Knockout", "Final"
    
    -- Scheduling
    scheduled_start TIMESTAMP WITH TIME ZONE NOT NULL,
    actual_start TIMESTAMP WITH TIME ZONE,
    scheduled_end TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    
    -- Venue information
    venue_name VARCHAR(255),
    venue_city VARCHAR(100),
    venue_country VARCHAR(100),
    venue_capacity INTEGER,
    
    -- Competition details
    competition VARCHAR(255),
    season VARCHAR(20),
    importance_level INTEGER DEFAULT 1, -- 1=low, 5=high (finals, derbies)
    
    -- Media and streaming
    stream_url TEXT,
    backup_stream_url TEXT,
    thumbnail_url TEXT,
    preview_url TEXT,
    
    -- Analytics and engagement
    viewer_count INTEGER NOT NULL DEFAULT 0,
    peak_viewer_count INTEGER DEFAULT 0,
    total_reactions INTEGER DEFAULT 0,
    chat_message_count INTEGER DEFAULT 0,
    
    -- Flags
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_trending BOOLEAN NOT NULL DEFAULT false,
    is_live BOOLEAN NOT NULL DEFAULT false,
    has_highlights BOOLEAN NOT NULL DEFAULT false,
    is_premium BOOLEAN NOT NULL DEFAULT false,
    
    -- Weather (for outdoor sports)
    weather_conditions JSONB DEFAULT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_matches_event_id FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_matches_home_team FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_away_team FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    
    -- Constraints
    CONSTRAINT chk_matches_teams_different CHECK (home_team_id <> away_team_id),
    CONSTRAINT chk_matches_viewer_count CHECK (viewer_count >= 0),
    CONSTRAINT chk_matches_importance CHECK (importance_level BETWEEN 1 AND 5),
    CONSTRAINT chk_matches_venue_capacity CHECK (venue_capacity IS NULL OR venue_capacity > 0)
);

-- Match scores with detailed tracking
CREATE TABLE IF NOT EXISTS match_scores (
    score_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    home_score INTEGER NOT NULL DEFAULT 0,
    away_score INTEGER NOT NULL DEFAULT 0,
    home_penalty_score INTEGER DEFAULT NULL,
    away_penalty_score INTEGER DEFAULT NULL,
    period_scores JSONB NOT NULL DEFAULT '[]', -- [{"period": 1, "home": 1, "away": 0, "type": "regular"}]
    current_period VARCHAR(20), -- "1st Half", "2nd Half", "Extra Time", "Penalties"
    match_time VARCHAR(10), -- "45'", "90+2'", "FT"
    time_elapsed_seconds INTEGER DEFAULT 0,
    is_final_score BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_match_scores_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT uq_match_scores_match_id UNIQUE (match_id),
    CONSTRAINT chk_match_scores_non_negative CHECK (home_score >= 0 AND away_score >= 0),
    CONSTRAINT chk_match_penalty_scores CHECK (
        (home_penalty_score IS NULL AND away_penalty_score IS NULL) OR
        (home_penalty_score IS NOT NULL AND away_penalty_score IS NOT NULL AND home_penalty_score >= 0 AND away_penalty_score >= 0)
    )
);

-- Detailed match events (goals, cards, substitutions, etc.)
CREATE TABLE IF NOT EXISTS match_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- goal, yellow_card, red_card, substitution, penalty, corner, etc.
    event_subtype VARCHAR(50), -- penalty_goal, own_goal, header, free_kick, etc.
    minute INTEGER NOT NULL,
    added_time INTEGER DEFAULT 0,
    period VARCHAR(20) DEFAULT '1st Half',
    team_id UUID NOT NULL,
    player_name VARCHAR(255),
    player_id UUID, -- For future player table integration
    assistant_player VARCHAR(255), -- For assists, substitutions
    description TEXT NOT NULL,
    details JSONB DEFAULT '{}', -- Additional event-specific data
    impact_level VARCHAR(20) NOT NULL DEFAULT 'medium', -- low, medium, high, critical
    video_url TEXT, -- Link to video of the event
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_match_events_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_match_events_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id),
    
    -- Constraints
    CONSTRAINT chk_match_events_minute CHECK (minute >= 0 AND minute <= 250),
    CONSTRAINT chk_match_events_added_time CHECK (added_time >= 0 AND added_time <= 30),
    CONSTRAINT chk_match_events_impact CHECK (impact_level IN ('low', 'medium', 'high', 'critical'))
);

-- Match statistics tracking
CREATE TABLE IF NOT EXISTS match_statistics (
    stat_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    stat_category VARCHAR(50) NOT NULL, -- possession, shots, passing, defending, discipline
    stat_type VARCHAR(50) NOT NULL, -- ball_possession, shots_total, shots_on_target, passes_completed, etc.
    home_value DECIMAL(10,2) NOT NULL DEFAULT 0,
    away_value DECIMAL(10,2) NOT NULL DEFAULT 0,
    home_display VARCHAR(50), -- Formatted display value like "65%", "12/15"
    away_display VARCHAR(50),
    unit VARCHAR(20), -- %, count, ratio, time
    sort_order INTEGER DEFAULT 0,
    is_percentage BOOLEAN DEFAULT false,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_match_statistics_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_match_statistics_values CHECK (home_value >= 0 AND away_value >= 0),
    CONSTRAINT uq_match_statistics_match_type UNIQUE (match_id, stat_type)
);

-- Team lineups and formations
CREATE TABLE IF NOT EXISTS match_lineups (
    lineup_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    team_id UUID NOT NULL,
    formation VARCHAR(20), -- "4-3-3", "3-5-2", etc.
    formation_image_url TEXT,
    starting_players JSONB NOT NULL DEFAULT '[]', -- [{name, position, number, captain, etc.}]
    substitute_players JSONB NOT NULL DEFAULT '[]',
    coaching_staff JSONB DEFAULT '[]', -- [{name, role}]
    is_confirmed BOOLEAN DEFAULT false,
    lineup_submitted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_match_lineups_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_match_lineups_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id),
    
    -- Constraints
    CONSTRAINT uq_match_lineups_match_team UNIQUE (match_id, team_id)
);

-- ============================================================================
-- HIGHLIGHTS AND MEDIA CONTENT
-- ============================================================================

-- Match highlights and video content
CREATE TABLE IF NOT EXISTS highlights (
    highlight_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    event_id UUID, -- Link to specific match event if applicable
    title VARCHAR(255) NOT NULL,
    description TEXT,
    highlight_type VARCHAR(50) DEFAULT 'general', -- goal, save, skill, recap, full_match, etc.
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    preview_gif_url TEXT,
    duration_seconds INTEGER NOT NULL,
    start_time_seconds INTEGER DEFAULT 0, -- Start time within the full match
    end_time_seconds INTEGER, -- End time within the full match
    quality VARCHAR(20) DEFAULT 'HD', -- SD, HD, 4K
    file_size_mb DECIMAL(8,2),
    encoding_format VARCHAR(20) DEFAULT 'mp4',
    
    -- Content classification
    tags TEXT[] NOT NULL DEFAULT '{}',
    player_names TEXT[] DEFAULT '{}',
    team_tags UUID[] DEFAULT '{}',
    content_rating VARCHAR(10) DEFAULT 'G', -- G, PG, PG-13
    language VARCHAR(10) DEFAULT 'en',
    
    -- Engagement metrics
    view_count INTEGER NOT NULL DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    
    -- Flags
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_trending BOOLEAN DEFAULT false,
    is_premium_content BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    auto_generated BOOLEAN DEFAULT false, -- AI/auto-generated highlights
    
    -- Publishing
    published_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_highlights_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id),
    CONSTRAINT fk_highlights_event_id FOREIGN KEY (event_id) REFERENCES match_events(event_id),
    
    -- Constraints
    CONSTRAINT chk_highlights_duration CHECK (duration_seconds > 0),
    CONSTRAINT chk_highlights_view_count CHECK (view_count >= 0),
    CONSTRAINT chk_highlights_times CHECK (
        start_time_seconds >= 0 AND 
        (end_time_seconds IS NULL OR end_time_seconds > start_time_seconds)
    )
);

-- Streaming quality options for matches
CREATE TABLE IF NOT EXISTS stream_qualities (
    quality_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    quality_name VARCHAR(20) NOT NULL, -- Auto, 4K, HD, 720p, 480p, 360p
    quality_label VARCHAR(50) NOT NULL, -- "Ultra HD 4K", "High Definition"
    stream_url TEXT NOT NULL,
    bitrate_kbps INTEGER,
    resolution_width INTEGER,
    resolution_height INTEGER,
    fps INTEGER DEFAULT 30,
    codec VARCHAR(20) DEFAULT 'H.264',
    is_default BOOLEAN NOT NULL DEFAULT false,
    is_adaptive BOOLEAN DEFAULT false, -- For adaptive bitrate streaming
    minimum_bandwidth_mbps DECIMAL(5,2),
    is_premium_quality BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_stream_qualities_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT uq_stream_qualities_match_quality UNIQUE (match_id, quality_name),
    CONSTRAINT chk_stream_qualities_bitrate CHECK (bitrate_kbps IS NULL OR bitrate_kbps > 0),
    CONSTRAINT chk_stream_qualities_resolution CHECK (
        (resolution_width IS NULL AND resolution_height IS NULL) OR
        (resolution_width > 0 AND resolution_height > 0)
    ),
    CONSTRAINT chk_stream_qualities_fps CHECK (fps > 0 AND fps <= 120)
);

-- ============================================================================
-- SCHEDULES AND TIME MANAGEMENT
-- ============================================================================

-- Enhanced scheduling system for matches and events
CREATE TABLE IF NOT EXISTS schedules (
    schedule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID,
    event_id UUID,
    schedule_type VARCHAR(50) NOT NULL DEFAULT 'match', -- match, event, maintenance, broadcast
    
    -- Timing details
    original_start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    current_start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    estimated_end_time TIMESTAMP WITH TIME ZONE,
    actual_end_time TIMESTAMP WITH TIME ZONE,
    
    -- Schedule metadata
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    broadcast_regions TEXT[] DEFAULT '{}', -- Regions where this is scheduled to broadcast
    blackout_regions TEXT[] DEFAULT '{}', -- Regions with broadcasting restrictions
    
    -- Broadcasting details
    primary_broadcaster VARCHAR(100),
    secondary_broadcasters TEXT[] DEFAULT '{}',
    commentary_languages TEXT[] DEFAULT '{"en"}',
    
    -- Status and changes
    schedule_status VARCHAR(20) DEFAULT 'confirmed', -- confirmed, tentative, postponed, cancelled
    change_reason TEXT, -- Reason for any schedule changes
    change_count INTEGER DEFAULT 0,
    last_changed_at TIMESTAMP WITH TIME ZONE,
    
    -- Notifications
    reminder_sent BOOLEAN DEFAULT false,
    notification_times INTEGER[] DEFAULT '{60, 15, 5}', -- Minutes before start to send notifications
    
    -- Weather dependency (for outdoor sports)
    weather_dependent BOOLEAN DEFAULT false,
    weather_backup_plan TEXT,
    
    -- Flags
    is_prime_time BOOLEAN DEFAULT false,
    is_holiday BOOLEAN DEFAULT false,
    requires_subscription BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_schedules_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_schedules_event_id FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_schedules_has_reference CHECK (match_id IS NOT NULL OR event_id IS NOT NULL),
    CONSTRAINT chk_schedules_times CHECK (estimated_end_time IS NULL OR estimated_end_time > current_start_time),
    CONSTRAINT chk_schedules_change_count CHECK (change_count >= 0),
    CONSTRAINT chk_schedules_status CHECK (schedule_status IN ('confirmed', 'tentative', 'postponed', 'cancelled'))
);

-- User schedule preferences and reminders
CREATE TABLE IF NOT EXISTS user_schedule_preferences (
    preference_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    
    -- Default reminder settings
    default_reminder_times INTEGER[] DEFAULT '{60, 15}', -- Minutes before matches
    reminder_methods TEXT[] DEFAULT '{"push", "email"}', -- push, email, sms
    
    -- Filtering preferences
    favorite_teams_only BOOLEAN DEFAULT false,
    favorite_sports_only BOOLEAN DEFAULT false,
    featured_matches_only BOOLEAN DEFAULT false,
    minimum_importance_level INTEGER DEFAULT 1,
    
    -- Time zone and display
    display_timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    time_format VARCHAR(10) DEFAULT '24h', -- 12h, 24h
    date_format VARCHAR(20) DEFAULT 'YYYY-MM-DD',
    
    -- Calendar integration
    calendar_sync_enabled BOOLEAN DEFAULT false,
    calendar_provider VARCHAR(20), -- google, outlook, apple
    calendar_sync_token TEXT,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_user_schedule_preferences_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT uq_user_schedule_preferences_user_id UNIQUE (user_id),
    CONSTRAINT chk_user_schedule_importance CHECK (minimum_importance_level BETWEEN 1 AND 5)
);

-- ============================================================================
-- NOTIFICATIONS AND ALERTS
-- ============================================================================

-- User notifications system
CREATE TABLE IF NOT EXISTS notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    notification_type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related entities
    match_id UUID,
    event_id UUID,
    team_id UUID,
    
    -- Notification metadata
    scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Delivery channels
    push_notification_sent BOOLEAN DEFAULT false,
    email_sent BOOLEAN DEFAULT false,
    sms_sent BOOLEAN DEFAULT false,
    in_app_shown BOOLEAN DEFAULT false,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    delivery_status VARCHAR(20) DEFAULT 'pending', -- pending, sent, delivered, failed
    
    -- Retry logic
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_event_id FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT chk_notifications_retry_count CHECK (retry_count >= 0 AND retry_count <= max_retries),
    CONSTRAINT chk_notifications_delivery_status CHECK (delivery_status IN ('pending', 'sent', 'delivered', 'failed'))
);

-- ============================================================================
-- PERFORMANCE INDEXES
-- ============================================================================

-- User-related indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription ON user_profiles(subscription_tier);

-- Sports and teams indexes
CREATE INDEX IF NOT EXISTS idx_sports_active ON sports(is_active);
CREATE INDEX IF NOT EXISTS idx_teams_sport_id ON teams(sport_id);
CREATE INDEX IF NOT EXISTS idx_teams_active ON teams(is_active);
CREATE INDEX IF NOT EXISTS idx_teams_country ON teams(country);

-- Events indexes
CREATE INDEX IF NOT EXISTS idx_events_sport_id ON events(sport_id);
CREATE INDEX IF NOT EXISTS idx_events_featured ON events(is_featured);
CREATE INDEX IF NOT EXISTS idx_events_active ON events(is_active);
CREATE INDEX IF NOT EXISTS idx_events_dates ON events(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_events_season ON events(season);

-- Match-related indexes
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_scheduled_start ON matches(scheduled_start);
CREATE INDEX IF NOT EXISTS idx_matches_event_id ON matches(event_id);
CREATE INDEX IF NOT EXISTS idx_matches_home_team ON matches(home_team_id);
CREATE INDEX IF NOT EXISTS idx_matches_away_team ON matches(away_team_id);
CREATE INDEX IF NOT EXISTS idx_matches_sport_id ON matches(sport_id);
CREATE INDEX IF NOT EXISTS idx_matches_featured ON matches(is_featured);
CREATE INDEX IF NOT EXISTS idx_matches_trending ON matches(is_trending);
CREATE INDEX IF NOT EXISTS idx_matches_live ON matches(is_live);
CREATE INDEX IF NOT EXISTS idx_matches_importance ON matches(importance_level);

-- Match events and statistics indexes
CREATE INDEX IF NOT EXISTS idx_match_scores_match_id ON match_scores(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_match_id ON match_events(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_type ON match_events(event_type);
CREATE INDEX IF NOT EXISTS idx_match_events_team_id ON match_events(team_id);
CREATE INDEX IF NOT EXISTS idx_match_events_minute ON match_events(minute);
CREATE INDEX IF NOT EXISTS idx_match_statistics_match_id ON match_statistics(match_id);
CREATE INDEX IF NOT EXISTS idx_match_statistics_category ON match_statistics(stat_category);
CREATE INDEX IF NOT EXISTS idx_match_lineups_match_id ON match_lineups(match_id);
CREATE INDEX IF NOT EXISTS idx_match_lineups_team_id ON match_lineups(team_id);

-- Highlights indexes
CREATE INDEX IF NOT EXISTS idx_highlights_match_id ON highlights(match_id);
CREATE INDEX IF NOT EXISTS idx_highlights_type ON highlights(highlight_type);
CREATE INDEX IF NOT EXISTS idx_highlights_featured ON highlights(is_featured);
CREATE INDEX IF NOT EXISTS idx_highlights_trending ON highlights(is_trending);
CREATE INDEX IF NOT EXISTS idx_highlights_public ON highlights(is_public);
CREATE INDEX IF NOT EXISTS idx_highlights_view_count ON highlights(view_count);
CREATE INDEX IF NOT EXISTS idx_highlights_published_at ON highlights(published_at);

-- Stream quality indexes
CREATE INDEX IF NOT EXISTS idx_stream_qualities_match_id ON stream_qualities(match_id);
CREATE INDEX IF NOT EXISTS idx_stream_qualities_default ON stream_qualities(is_default);

-- Schedule indexes
CREATE INDEX IF NOT EXISTS idx_schedules_match_id ON schedules(match_id);
CREATE INDEX IF NOT EXISTS idx_schedules_event_id ON schedules(event_id);
CREATE INDEX IF NOT EXISTS idx_schedules_current_start ON schedules(current_start_time);
CREATE INDEX IF NOT EXISTS idx_schedules_status ON schedules(schedule_status);
CREATE INDEX IF NOT EXISTS idx_schedules_type ON schedules(schedule_type);
CREATE INDEX IF NOT EXISTS idx_schedules_prime_time ON schedules(is_prime_time);

-- User schedule preferences index
CREATE INDEX IF NOT EXISTS idx_user_schedule_preferences_user_id ON user_schedule_preferences(user_id);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON notifications(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(delivery_status);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_match_id ON notifications(match_id);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_matches_status_start_time ON matches(status, scheduled_start);
CREATE INDEX IF NOT EXISTS idx_matches_teams_start_time ON matches(home_team_id, away_team_id, scheduled_start);
CREATE INDEX IF NOT EXISTS idx_events_sport_dates ON events(sport_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_highlights_match_type_featured ON highlights(match_id, highlight_type, is_featured);
CREATE INDEX IF NOT EXISTS idx_schedules_time_status ON schedules(current_start_time, schedule_status);

-- ============================================================================
-- TRIGGERS AND FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sports_updated_at BEFORE UPDATE ON sports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_scores_updated_at BEFORE UPDATE ON match_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_lineups_updated_at BEFORE UPDATE ON match_lineups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_highlights_updated_at BEFORE UPDATE ON highlights
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_schedule_preferences_updated_at BEFORE UPDATE ON user_schedule_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update match completion counts in events
CREATE OR REPLACE FUNCTION update_event_match_counts()
RETURNS TRIGGER AS $$
BEGIN
    -- Update completed matches count when match status changes to finished
    IF NEW.status = 'finished' AND OLD.status != 'finished' THEN
        UPDATE events 
        SET completed_matches = (
            SELECT COUNT(*) 
            FROM matches 
            WHERE event_id = NEW.event_id AND status = 'finished'
        )
        WHERE event_id = NEW.event_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_event_counts_on_match_update 
    AFTER UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_event_match_counts();

-- Function to update viewer counts and analytics
CREATE OR REPLACE FUNCTION update_match_analytics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update peak viewer count if current count is higher
    IF NEW.viewer_count > COALESCE(OLD.peak_viewer_count, 0) THEN
        NEW.peak_viewer_count = NEW.viewer_count;
    END IF;
    
    -- Set is_live flag based on status
    NEW.is_live = (NEW.status = 'live');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_match_analytics_trigger 
    BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_match_analytics();

-- Function to validate and update schedule changes
CREATE OR REPLACE FUNCTION track_schedule_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Track when schedule time is changed
    IF OLD.current_start_time != NEW.current_start_time THEN
        NEW.change_count = COALESCE(OLD.change_count, 0) + 1;
        NEW.last_changed_at = CURRENT_TIMESTAMP;
        NEW.reminder_sent = false; -- Reset reminder flag for new time
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_schedule_changes_trigger 
    BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION track_schedule_changes();

-- Function to auto-archive old notifications
CREATE OR REPLACE FUNCTION auto_archive_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-archive notifications older than 30 days
    UPDATE notifications 
    SET is_archived = true 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days' 
    AND is_archived = false;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that runs daily to archive old notifications
-- Note: In production, this should be handled by a scheduled job instead of a trigger
CREATE OR REPLACE FUNCTION create_daily_archive_job()
RETURNS void AS $$
BEGIN
    -- This is a placeholder for a scheduled job
    -- In production, use pg_cron or external job scheduler
    PERFORM auto_archive_notifications();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Comprehensive match view with team and event details
CREATE OR REPLACE VIEW match_details_view AS
SELECT 
    m.match_id,
    m.status,
    m.scheduled_start,
    m.actual_start,
    m.venue_name,
    m.viewer_count,
    m.is_featured,
    m.is_trending,
    m.is_live,
    
    -- Event details
    e.name as event_name,
    e.display_name as event_display_name,
    e.event_type,
    e.season,
    
    -- Sport details
    s.name as sport_name,
    s.display_name as sport_display_name,
    
    -- Home team details
    ht.name as home_team_name,
    ht.short_name as home_team_short,
    ht.code as home_team_code,
    ht.logo_url as home_team_logo,
    ht.colors as home_team_colors,
    
    -- Away team details
    at.name as away_team_name,
    at.short_name as away_team_short,
    at.code as away_team_code,
    at.logo_url as away_team_logo,
    at.colors as away_team_colors,
    
    -- Scores
    ms.home_score,
    ms.away_score,
    ms.match_time,
    ms.current_period,
    
    -- Schedule info
    sc.current_start_time as scheduled_time,
    sc.timezone,
    sc.schedule_status
    
FROM matches m
JOIN events e ON m.event_id = e.event_id
JOIN sports s ON m.sport_id = s.sport_id
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams at ON m.away_team_id = at.team_id
LEFT JOIN match_scores ms ON m.match_id = ms.match_id
LEFT JOIN schedules sc ON m.match_id = sc.match_id;

-- User favorites view
CREATE OR REPLACE VIEW user_favorites_view AS
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    
    -- Favorite teams with details
    COALESCE(
        (SELECT json_agg(
            json_build_object(
                'team_id', t.team_id,
                'name', t.name,
                'short_name', t.short_name,
                'logo_url', t.logo_url,
                'sport', s.display_name
            )
        )
        FROM unnest(up.favorite_teams) as team_id
        JOIN teams t ON t.team_id = team_id::uuid
        JOIN sports s ON t.sport_id = s.sport_id), '[]'::json
    ) as favorite_teams_details,
    
    -- Favorite sports with details  
    COALESCE(
        (SELECT json_agg(
            json_build_object(
                'sport_id', s.sport_id,
                'name', s.name,
                'display_name', s.display_name,
                'icon_url', s.icon_url
            )
        )
        FROM unnest(up.favorite_sports) as sport_id
        JOIN sports s ON s.sport_id = sport_id::uuid), '[]'::json
    ) as favorite_sports_details
    
FROM users u
JOIN user_profiles up ON u.user_id = up.user_id;

-- ============================================================================
-- TABLE COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE users IS 'Core user accounts with authentication and basic profile information';
COMMENT ON TABLE user_profiles IS 'Extended user preferences, settings, and personalization data';
COMMENT ON TABLE sports IS 'Available sports types and categories';
COMMENT ON TABLE teams IS 'Teams and organizations participating in matches';
COMMENT ON TABLE events IS 'Sports events, tournaments, leagues, and competitions';
COMMENT ON TABLE matches IS 'Individual matches with comprehensive scheduling and metadata';
COMMENT ON TABLE match_scores IS 'Real-time and historical match scoring information';
COMMENT ON TABLE match_events IS 'Detailed match events like goals, cards, substitutions';
COMMENT ON TABLE match_statistics IS 'Real-time match statistics and analytics';
COMMENT ON TABLE match_lineups IS 'Team lineups, formations, and player information';
COMMENT ON TABLE highlights IS 'Match highlights, clips, and video content';
COMMENT ON TABLE stream_qualities IS 'Available streaming quality options and URLs';
COMMENT ON TABLE schedules IS 'Comprehensive scheduling system for matches and events';
COMMENT ON TABLE user_schedule_preferences IS 'User preferences for schedule display and reminders';
COMMENT ON TABLE notifications IS 'User notification system for matches and events';

-- Migration completion log
INSERT INTO migration_history (migration_name, executed_at, success) 
VALUES ('007_comprehensive_schema_migration.sql', CURRENT_TIMESTAMP, true)
ON CONFLICT (migration_name) DO UPDATE SET 
    executed_at = CURRENT_TIMESTAMP, 
    success = true;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
