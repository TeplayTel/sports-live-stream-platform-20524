-- Sports Telecast Database - Initial Schema Migration
-- This migration creates all tables needed to persist frontend mock data

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram extension for text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- USERS AND AUTHENTICATION TABLES
-- =====================================================

-- Users table for authentication and profiles
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    -- IMPORTANT: Role labels must be lowercase only to align with backend/OpenAPI and userroleenum.
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User preferences table
CREATE TABLE user_preferences (
    preference_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    favorite_teams TEXT[] DEFAULT '{}',
    favorite_sports TEXT[] DEFAULT '{}',
    notification_settings JSONB DEFAULT '{}',
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SPORTS AND TEAMS TABLES
-- =====================================================

-- Sports types table
CREATE TABLE sports (
    sport_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Teams table
CREATE TABLE teams (
    team_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    logo_url TEXT,
    colors JSONB DEFAULT '{}', -- {"primary": "#ff0000", "secondary": "#ffffff"}
    sport_id UUID NOT NULL REFERENCES sports(sport_id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EVENTS AND COMPETITIONS TABLES
-- =====================================================

-- Sports events/tournaments table
CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sport_id UUID NOT NULL REFERENCES sports(sport_id),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255),
    organizer VARCHAR(255),
    logo_url TEXT,
    banner_url TEXT,
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- MATCHES TABLES
-- =====================================================

-- Match statuses enum
CREATE TYPE match_status AS ENUM ('scheduled', 'live', 'finished', 'cancelled', 'postponed');

-- Main matches table
CREATE TABLE matches (
    match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(event_id),
    home_team_id UUID NOT NULL REFERENCES teams(team_id),
    away_team_id UUID NOT NULL REFERENCES teams(team_id),
    sport_id UUID NOT NULL REFERENCES sports(sport_id),
    status match_status DEFAULT 'scheduled',
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    venue VARCHAR(255),
    competition VARCHAR(255),
    round VARCHAR(50),
    stream_url TEXT,
    viewer_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_trending BOOLEAN DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Match scores table
CREATE TABLE match_scores (
    score_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    period_scores JSONB DEFAULT '[]', -- [{"period": 1, "home": 1, "away": 0}]
    current_time VARCHAR(10), -- "67'" for match time
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Match events table (goals, cards, substitutions, etc.)
CREATE TABLE match_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'goal', 'card', 'substitution', 'penalty', etc.
    minute INTEGER NOT NULL,
    team_id UUID NOT NULL REFERENCES teams(team_id),
    player_name VARCHAR(255),
    description TEXT NOT NULL,
    details TEXT,
    impact VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Match statistics table
CREATE TABLE match_statistics (
    stat_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    stat_type VARCHAR(50) NOT NULL, -- 'possession', 'shots', 'corners', etc.
    home_value INTEGER DEFAULT 0,
    away_value INTEGER DEFAULT 0,
    home_display VARCHAR(20), -- For formatted display like "58%"
    away_display VARCHAR(20),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Team lineups table
CREATE TABLE match_lineups (
    lineup_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(team_id),
    formation VARCHAR(20), -- "4-3-3", "4-2-3-1", etc.
    players JSONB NOT NULL, -- [{"name": "Player", "position": "GK", "number": "1"}]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- HIGHLIGHTS AND MEDIA TABLES
-- =====================================================

-- Match highlights table
CREATE TABLE highlights (
    highlight_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INTEGER NOT NULL, -- Duration in seconds
    tags TEXT[] DEFAULT '{}',
    view_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Stream quality options table
CREATE TABLE stream_qualities (
    quality_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    quality_name VARCHAR(20) NOT NULL, -- '4K', 'HD', '720p', '480p', 'Auto'
    stream_url TEXT NOT NULL,
    bitrate INTEGER, -- Bitrate in kbps
    resolution VARCHAR(20), -- "1920x1080", "1280x720", etc.
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FAN ENGAGEMENT TABLES
-- =====================================================

-- Emoji types enum
CREATE TYPE emoji_type AS ENUM ('clap', 'fire', 'heart', 'thumbs_up', 'celebration', 'shocked', 'angry', 'sad', 'laugh', 'goal');

-- Emoji assets table
CREATE TABLE emoji_assets (
    emoji_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    emoji_type emoji_type NOT NULL,
    name VARCHAR(50) NOT NULL,
    image_url TEXT NOT NULL,
    description TEXT,
    unicode_char VARCHAR(10), -- Unicode representation
    color VARCHAR(7), -- Hex color code
    gradient_class VARCHAR(100), -- CSS gradient classes
    sound_config JSONB, -- Sound configuration for reactions
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User emoji reactions table
CREATE TABLE emoji_reactions (
    reaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    event_id UUID NOT NULL REFERENCES events(event_id),
    match_id UUID REFERENCES matches(match_id),
    emoji_id UUID NOT NULL REFERENCES emoji_assets(emoji_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Emoji reaction summary (aggregated data for performance)
CREATE TABLE emoji_reaction_summary (
    summary_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(event_id),
    match_id UUID REFERENCES matches(match_id),
    emoji_id UUID NOT NULL REFERENCES emoji_assets(emoji_id),
    reaction_count INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, match_id, emoji_id)
);

-- =====================================================
-- CHAT AND MESSAGING TABLES
-- =====================================================

-- Chat messages table
CREATE TABLE chat_messages (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(event_id),
    match_id UUID REFERENCES matches(match_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'emoji', 'system'
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- VIEWER ANALYTICS TABLES
-- =====================================================

-- Live viewer tracking table
CREATE TABLE viewer_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id),
    match_id UUID NOT NULL REFERENCES matches(match_id),
    ip_address INET,
    user_agent TEXT,
    join_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    leave_time TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- Duration in seconds
    quality_watched VARCHAR(20)
);

-- Match viewer count snapshots (for historical data)
CREATE TABLE viewer_count_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(match_id),
    viewer_count INTEGER NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDICES FOR PERFORMANCE
-- =====================================================

-- User indices
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);

-- Match indices
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_start_time ON matches(start_time);
CREATE INDEX idx_matches_event_id ON matches(event_id);
CREATE INDEX idx_matches_featured ON matches(is_featured);
CREATE INDEX idx_matches_trending ON matches(is_trending);

-- Event indices
CREATE INDEX idx_events_sport_id ON events(sport_id);
CREATE INDEX idx_events_featured ON events(is_featured);
CREATE INDEX idx_events_dates ON events(start_date, end_date);

-- Statistics indices
CREATE INDEX idx_match_statistics_match_id ON match_statistics(match_id);
CREATE INDEX idx_match_events_match_id ON match_events(match_id);
CREATE INDEX idx_match_events_type ON match_events(event_type);

-- Emoji reaction indices
CREATE INDEX idx_emoji_reactions_event_id ON emoji_reactions(event_id);
CREATE INDEX idx_emoji_reactions_user_id ON emoji_reactions(user_id);
CREATE INDEX idx_emoji_reactions_created_at ON emoji_reactions(created_at);
CREATE INDEX idx_emoji_summary_event_id ON emoji_reaction_summary(event_id);

-- Chat indices
CREATE INDEX idx_chat_messages_event_id ON chat_messages(event_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- Viewer indices
CREATE INDEX idx_viewer_sessions_match_id ON viewer_sessions(match_id);
CREATE INDEX idx_viewer_sessions_user_id ON viewer_sessions(user_id);
CREATE INDEX idx_viewer_snapshots_match_id ON viewer_count_snapshots(match_id);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
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

-- Function to update emoji reaction summary
CREATE OR REPLACE FUNCTION update_emoji_reaction_summary()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count, last_updated)
    VALUES (NEW.event_id, NEW.match_id, NEW.emoji_id, 1, CURRENT_TIMESTAMP)
    ON CONFLICT (event_id, match_id, emoji_id)
    DO UPDATE SET 
        reaction_count = emoji_reaction_summary.reaction_count + 1,
        last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to update emoji summary on new reactions
CREATE TRIGGER update_emoji_summary_on_reaction 
    AFTER INSERT ON emoji_reactions
    FOR EACH ROW EXECUTE FUNCTION update_emoji_reaction_summary();

-- =====================================================
-- COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE users IS 'User accounts and authentication data';
COMMENT ON TABLE user_preferences IS 'User preferences and personalization settings';
COMMENT ON TABLE sports IS 'Available sports types';
COMMENT ON TABLE teams IS 'Teams participating in matches';
COMMENT ON TABLE events IS 'Sports events, tournaments, and competitions';
COMMENT ON TABLE matches IS 'Individual matches within events';
COMMENT ON TABLE match_scores IS 'Current and historical match scores';
COMMENT ON TABLE match_events IS 'Match events like goals, cards, substitutions';
COMMENT ON TABLE match_statistics IS 'Real-time match statistics';
COMMENT ON TABLE match_lineups IS 'Team lineups and formations for matches';
COMMENT ON TABLE highlights IS 'Match highlights and video content';
COMMENT ON TABLE stream_qualities IS 'Available streaming quality options per match';
COMMENT ON TABLE emoji_assets IS 'Available emoji types for user reactions';
COMMENT ON TABLE emoji_reactions IS 'User emoji reactions during events';
COMMENT ON TABLE emoji_reaction_summary IS 'Aggregated emoji reaction counts for performance';
COMMENT ON TABLE chat_messages IS 'Live chat messages during events';
COMMENT ON TABLE viewer_sessions IS 'User viewing sessions for analytics';
COMMENT ON TABLE viewer_count_snapshots IS 'Historical viewer count data';
