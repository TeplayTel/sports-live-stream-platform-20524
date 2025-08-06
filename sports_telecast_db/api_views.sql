-- Sports Telecast Database API Views
-- Optimized views for FastAPI backend integration

-- =====================================================
-- LIVE MATCH DATA VIEWS
-- =====================================================

-- Live matches with full details for frontend
CREATE OR REPLACE VIEW live_matches_full AS
SELECT 
    m.match_id,
    m.event_id,
    e.name as event_name,
    e.competition,
    m.home_team_id,
    ht.name as home_team_name,
    ht.short_name as home_team_short,
    ht.logo_url as home_team_logo,
    ht.colors as home_team_colors,
    m.away_team_id,
    at.name as away_team_name,
    at.short_name as away_team_short,
    at.logo_url as away_team_logo,
    at.colors as away_team_colors,
    ms.home_score,
    ms.away_score,
    ms.match_time,
    m.status,
    m.start_time,
    m.venue,
    m.stream_url,
    m.viewer_count,
    m.is_featured,
    m.is_trending,
    m.thumbnail_url
FROM matches m
JOIN events e ON m.event_id = e.event_id
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams at ON m.away_team_id = at.team_id
LEFT JOIN match_scores ms ON m.match_id = ms.match_id
WHERE m.status = 'live'
ORDER BY m.start_time DESC;

-- Match statistics view for real-time updates
CREATE OR REPLACE VIEW match_stats_live AS
SELECT 
    ms.match_id,
    json_object_agg(ms.stat_type, json_build_object(
        'home_value', ms.home_value,
        'away_value', ms.away_value,
        'home_display', ms.home_display,
        'away_display', ms.away_display
    )) as statistics
FROM match_statistics ms
GROUP BY ms.match_id;

-- Recent match events for timeline
CREATE OR REPLACE VIEW match_events_timeline AS
SELECT 
    me.match_id,
    json_agg(
        json_build_object(
            'event_id', me.event_id,
            'event_type', me.event_type,
            'minute', me.minute,
            'team_id', me.team_id,
            'team_name', t.short_name,
            'player_name', me.player_name,
            'description', me.description,
            'impact', me.impact,
            'created_at', me.created_at
        ) ORDER BY me.minute DESC, me.created_at DESC
    ) as events
FROM match_events me
JOIN teams t ON me.team_id = t.team_id
GROUP BY me.match_id;

-- =====================================================
-- EMOJI REACTIONS VIEWS
-- =====================================================

-- Top emoji reactions per match
CREATE OR REPLACE VIEW top_emoji_reactions AS
SELECT 
    ers.match_id,
    ers.event_id,
    json_agg(
        json_build_object(
            'emoji_id', ea.emoji_id,
            'emoji_type', ea.emoji_type,
            'name', ea.name,
            'unicode_char', ea.unicode_char,
            'color', ea.color,
            'reaction_count', ers.reaction_count
        ) ORDER BY ers.reaction_count DESC
    ) as top_reactions
FROM emoji_reaction_summary ers
JOIN emoji_assets ea ON ers.emoji_id = ea.emoji_id
WHERE ea.is_active = true
GROUP BY ers.match_id, ers.event_id;

-- Real-time emoji counts for live updates
CREATE OR REPLACE VIEW live_emoji_counts AS
SELECT 
    ers.match_id,
    ers.emoji_id,
    ea.emoji_type,
    ea.unicode_char,
    ea.color,
    ers.reaction_count,
    ers.last_updated
FROM emoji_reaction_summary ers
JOIN emoji_assets ea ON ers.emoji_id = ea.emoji_id
WHERE ea.is_active = true
AND ers.match_id IN (SELECT match_id FROM matches WHERE status = 'live')
ORDER BY ers.match_id, ers.reaction_count DESC;

-- =====================================================
-- SCHEDULE AND EVENTS VIEWS
-- =====================================================

-- Upcoming matches schedule
CREATE OR REPLACE VIEW upcoming_matches AS
SELECT 
    m.match_id,
    m.event_id,
    e.name as event_name,
    e.competition,
    ht.name as home_team_name,
    ht.short_name as home_team_short,
    ht.logo_url as home_team_logo,
    at.name as away_team_name,
    at.short_name as away_team_short,
    at.logo_url as away_team_logo,
    m.start_time,
    m.venue,
    m.status,
    m.is_featured,
    m.thumbnail_url,
    s.name as sport_name
FROM matches m
JOIN events e ON m.event_id = e.event_id
JOIN sports s ON m.sport_id = s.sport_id
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams at ON m.away_team_id = at.team_id
WHERE m.status IN ('scheduled') 
AND m.start_time > CURRENT_TIMESTAMP
ORDER BY m.start_time ASC
LIMIT 50;

-- Featured events with match counts
CREATE OR REPLACE VIEW featured_events AS
SELECT 
    e.event_id,
    e.name,
    e.description,
    e.start_date,
    e.end_date,
    e.location,
    e.organizer,
    e.logo_url,
    e.banner_url,
    s.name as sport_name,
    s.display_name as sport_display_name,
    count(m.match_id) as total_matches,
    count(CASE WHEN m.status = 'live' THEN 1 END) as live_matches,
    count(CASE WHEN m.status = 'scheduled' AND m.start_time > CURRENT_TIMESTAMP THEN 1 END) as upcoming_matches
FROM events e
JOIN sports s ON e.sport_id = s.sport_id
LEFT JOIN matches m ON e.event_id = m.event_id
WHERE e.is_featured = true AND e.is_active = true
GROUP BY e.event_id, e.name, e.description, e.start_date, e.end_date, 
         e.location, e.organizer, e.logo_url, e.banner_url, s.name, s.display_name
ORDER BY e.start_date DESC;

-- =====================================================
-- USER AND PREFERENCES VIEWS
-- =====================================================

-- User profile with preferences
CREATE OR REPLACE VIEW user_profiles AS
SELECT 
    u.user_id,
    u.email,
    u.username,
    u.full_name,
    u.avatar_url,
    u.role,
    u.is_active,
    up.favorite_teams,
    up.favorite_sports,
    up.notification_settings,
    up.preferred_language,
    up.timezone,
    u.created_at,
    u.updated_at
FROM users u
LEFT JOIN user_preferences up ON u.user_id = up.user_id
WHERE u.is_active = true;

-- =====================================================
-- ANALYTICS VIEWS
-- =====================================================

-- Current viewer statistics
CREATE OR REPLACE VIEW current_viewer_stats AS
SELECT 
    m.match_id,
    m.viewer_count as current_viewers,
    count(vs.session_id) as active_sessions,
    count(DISTINCT vs.user_id) as unique_viewers,
    count(CASE WHEN vs.user_id IS NULL THEN 1 END) as anonymous_viewers
FROM matches m
LEFT JOIN viewer_sessions vs ON m.match_id = vs.match_id 
    AND vs.leave_time IS NULL
WHERE m.status = 'live'
GROUP BY m.match_id, m.viewer_count;

-- Popular highlights
CREATE OR REPLACE VIEW popular_highlights AS
SELECT 
    h.highlight_id,
    h.match_id,
    h.title,
    h.description,
    h.video_url,
    h.thumbnail_url,
    h.duration,
    h.tags,
    h.view_count,
    ht.name as home_team_name,
    at.name as away_team_name,
    e.name as event_name
FROM highlights h
JOIN matches m ON h.match_id = m.match_id
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams at ON m.away_team_id = at.team_id
JOIN events e ON m.event_id = e.event_id
ORDER BY h.view_count DESC, h.created_at DESC
LIMIT 20;

-- Grant select permissions on views
-- GRANT SELECT ON live_matches_full TO your_app_user;
-- GRANT SELECT ON match_stats_live TO your_app_user;
-- GRANT SELECT ON match_events_timeline TO your_app_user;
-- GRANT SELECT ON top_emoji_reactions TO your_app_user;
-- GRANT SELECT ON live_emoji_counts TO your_app_user;
-- GRANT SELECT ON upcoming_matches TO your_app_user;
-- GRANT SELECT ON featured_events TO your_app_user;
-- GRANT SELECT ON user_profiles TO your_app_user;
-- GRANT SELECT ON current_viewer_stats TO your_app_user;
-- GRANT SELECT ON popular_highlights TO your_app_user;
