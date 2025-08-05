-- Sports Telecast Database Robust Canonical Schema
-- Enhanced with explicit integrity constraints: NOT NULL, UNIQUE, CHECK, FOREIGN KEY

-- ==============
-- EXTENSIONS
-- ==============
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =========================
-- ENUM TYPES
-- =========================
CREATE TYPE match_status AS ENUM ('scheduled', 'live', 'finished', 'cancelled', 'postponed');
CREATE TYPE emoji_type AS ENUM ('clap','fire','heart','thumbs_up','celebration','shocked','angry','sad','laugh','goal');

-- =========================
-- USERS & AUTHENTICATION
-- =========================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin','moderator')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_preferences (
    preference_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    favorite_teams TEXT[] NOT NULL DEFAULT '{}',
    favorite_sports TEXT[] NOT NULL DEFAULT '{}',
    notification_settings JSONB NOT NULL DEFAULT '{}',
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_preferences_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ======================
-- SPORTS & TEAMS
-- ======================
CREATE TABLE sports (
    sport_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teams (
    team_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    logo_url TEXT,
    colors JSONB NOT NULL DEFAULT '{}',
    sport_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_teams_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    CONSTRAINT uq_team_name UNIQUE (name, sport_id),
    CONSTRAINT uq_team_short_name UNIQUE (short_name, sport_id)
);

-- =====================
-- EVENTS & COMPETITIONS
-- =====================
CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sport_id UUID NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255),
    organizer VARCHAR(255),
    logo_url TEXT,
    banner_url TEXT,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_events_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

-- =========================
-- MATCHES
-- =========================
CREATE TABLE matches (
    match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    home_team_id UUID NOT NULL,
    away_team_id UUID NOT NULL,
    sport_id UUID NOT NULL,
    status match_status NOT NULL DEFAULT 'scheduled',
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    venue VARCHAR(255),
    competition VARCHAR(255),
    round VARCHAR(50),
    stream_url TEXT,
    viewer_count INTEGER NOT NULL DEFAULT 0 CHECK (viewer_count >= 0),
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_trending BOOLEAN NOT NULL DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_matches_event_id FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_matches_home_team FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_away_team FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_matches_sport_id FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    CONSTRAINT chk_teams_not_equal CHECK (home_team_id <> away_team_id)
);

CREATE TABLE match_scores (
    score_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    home_score INTEGER NOT NULL DEFAULT 0 CHECK (home_score >= 0),
    away_score INTEGER NOT NULL DEFAULT 0 CHECK (away_score >= 0),
    period_scores JSONB NOT NULL DEFAULT '[]',
    match_time VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_scores_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT uq_match_scores_match_id UNIQUE (match_id)
);

CREATE TABLE match_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    minute INTEGER NOT NULL CHECK (minute >=0 AND minute <= 250),
    team_id UUID NOT NULL,
    player_name VARCHAR(255),
    description TEXT NOT NULL,
    details TEXT,
    impact VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (impact IN ('low','medium','high')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_events_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_match_events_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE match_statistics (
    stat_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    stat_type VARCHAR(50) NOT NULL,
    home_value INTEGER NOT NULL DEFAULT 0,
    away_value INTEGER NOT NULL DEFAULT 0,
    home_display VARCHAR(20),
    away_display VARCHAR(20),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_statistics_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE
);

CREATE TABLE match_lineups (
    lineup_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    team_id UUID NOT NULL,
    formation VARCHAR(20),
    players JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_lineups_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_match_lineups_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id),
    CONSTRAINT uq_match_lineups_match_team UNIQUE (match_id, team_id)
);

-- =========================
-- HIGHLIGHTS & MEDIA
-- =========================
CREATE TABLE highlights (
    highlight_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INTEGER NOT NULL CHECK (duration > 0),
    tags TEXT[] NOT NULL DEFAULT '{}',
    view_count INTEGER NOT NULL DEFAULT 0 CHECK (view_count >= 0),
    is_featured BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_highlights_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

CREATE TABLE stream_qualities (
    quality_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    quality_name VARCHAR(20) NOT NULL,
    stream_url TEXT NOT NULL,
    bitrate INTEGER CHECK (bitrate IS NULL OR bitrate >= 0),
    resolution VARCHAR(20),
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stream_qualities_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    CONSTRAINT uq_stream_qualities_match_quality UNIQUE (match_id, quality_name)
);

-- =========================
-- FAN ENGAGEMENT
-- =========================
CREATE TABLE emoji_assets (
    emoji_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    emoji_type emoji_type NOT NULL,
    name VARCHAR(50) NOT NULL,
    image_url TEXT NOT NULL,
    description TEXT,
    unicode_char VARCHAR(10),
    color VARCHAR(7),
    gradient_class VARCHAR(100),
    sound_config JSONB,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_emoji_assets_type_name UNIQUE (emoji_type, name)
);

CREATE TABLE emoji_reactions (
    reaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    event_id UUID NOT NULL,
    match_id UUID,
    emoji_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emoji_reactions_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_emoji_reactions_event_id FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_emoji_reactions_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id),
    CONSTRAINT fk_emoji_reactions_emoji_id FOREIGN KEY (emoji_id) REFERENCES emoji_assets(emoji_id)
);

CREATE TABLE emoji_reaction_summary (
    summary_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    match_id UUID,
    emoji_id UUID NOT NULL,
    reaction_count INTEGER NOT NULL DEFAULT 0 CHECK (reaction_count >= 0),
    last_updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emoji_reaction_summary_event_id FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_emoji_reaction_summary_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id),
    CONSTRAINT fk_emoji_reaction_summary_emoji_id FOREIGN KEY (emoji_id) REFERENCES emoji_assets(emoji_id),
    CONSTRAINT uq_emoji_reaction_summary_triple UNIQUE (event_id, match_id, emoji_id)
);

-- =========================
-- CHAT & MESSAGING
-- =========================
CREATE TABLE chat_messages (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    match_id UUID,
    user_id UUID NOT NULL,
    message TEXT NOT NULL,
    message_type VARCHAR(20) NOT NULL DEFAULT 'text',
    is_visible BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_messages_event_id FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_chat_messages_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id),
    CONSTRAINT fk_chat_messages_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =========================
-- VIEWER ANALYTICS
-- =========================
CREATE TABLE viewer_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    match_id UUID NOT NULL,
    ip_address INET,
    user_agent TEXT,
    join_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leave_time TIMESTAMP WITH TIME ZONE,
    duration INTEGER CHECK (duration IS NULL OR duration >= 0),
    quality_watched VARCHAR(20),
    CONSTRAINT fk_viewer_sessions_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_viewer_sessions_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

CREATE TABLE viewer_count_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL,
    viewer_count INTEGER NOT NULL CHECK (viewer_count >= 0),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_viewer_count_snapshots_match_id FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- =========================
-- INDICES FOR PERFORMANCE
-- =========================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_start_time ON matches(start_time);
CREATE INDEX idx_matches_event_id ON matches(event_id);
CREATE INDEX idx_matches_featured ON matches(is_featured);
CREATE INDEX idx_matches_trending ON matches(is_trending);
CREATE INDEX idx_events_sport_id ON events(sport_id);
CREATE INDEX idx_events_featured ON events(is_featured);
CREATE INDEX idx_events_dates ON events(start_date, end_date);
CREATE INDEX idx_match_statistics_match_id ON match_statistics(match_id);
CREATE INDEX idx_match_events_match_id ON match_events(match_id);
CREATE INDEX idx_match_events_type ON match_events(event_type);
CREATE INDEX idx_emoji_reactions_event_id ON emoji_reactions(event_id);
CREATE INDEX idx_emoji_reactions_user_id ON emoji_reactions(user_id);
CREATE INDEX idx_emoji_reactions_created_at ON emoji_reactions(created_at);
CREATE INDEX idx_emoji_summary_event_id ON emoji_reaction_summary(event_id);
CREATE INDEX idx_chat_messages_event_id ON chat_messages(event_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_viewer_sessions_match_id ON viewer_sessions(match_id);
CREATE INDEX idx_viewer_sessions_user_id ON viewer_sessions(user_id);
CREATE INDEX idx_viewer_snapshots_match_id ON viewer_count_snapshots(match_id);

-- =========================
-- TRIGGERS & FUNCTIONS
-- =========================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

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

CREATE TRIGGER update_emoji_summary_on_reaction 
    AFTER INSERT ON emoji_reactions
    FOR EACH ROW EXECUTE FUNCTION update_emoji_reaction_summary();

-- =========================
-- TABLE COMMENTS
-- =========================
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
