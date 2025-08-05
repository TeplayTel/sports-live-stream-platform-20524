-- Sports Telecast Database - Seed Data
-- This script populates the database with initial data based on frontend mock data

-- =====================================================
-- SPORTS DATA
-- =====================================================

INSERT INTO sports (sport_id, name, display_name, description) VALUES
(uuid_generate_v4(), 'football', 'Football', 'Association football (soccer)'),
(uuid_generate_v4(), 'basketball', 'Basketball', 'Basketball'),
(uuid_generate_v4(), 'tennis', 'Tennis', 'Tennis'),
(uuid_generate_v4(), 'baseball', 'Baseball', 'Baseball'),
(uuid_generate_v4(), 'hockey', 'Hockey', 'Ice Hockey'),
(uuid_generate_v4(), 'cricket', 'Cricket', 'Cricket');

-- =====================================================
-- EMOJI ASSETS DATA
-- =====================================================

INSERT INTO emoji_assets (emoji_id, emoji_type, name, image_url, description, unicode_char, color, gradient_class, sound_config, sort_order) VALUES
('EMJ001', 'heart'::emoji_type, 'Love', 'https://cdn.mydomain.com/emojis/heart.png', 'Love and appreciation', '❤️', '#ff1744', 'from-pink-500 via-red-500 to-rose-600', '{"frequency": 523.25, "type": "sine", "duration": 0.3}', 1),
('EMJ002', 'laugh'::emoji_type, 'Laugh', 'https://cdn.mydomain.com/emojis/laugh.png', 'Laughter and joy', '😂', '#ffc107', 'from-yellow-400 via-orange-400 to-red-400', '{"frequency": 659.25, "type": "triangle", "duration": 0.4}', 2),
('EMJ003', 'shocked'::emoji_type, 'Wow', 'https://cdn.mydomain.com/emojis/wow.png', 'Surprise and amazement', '😮', '#2196f3', 'from-blue-400 via-purple-500 to-indigo-600', '{"frequency": 783.99, "type": "sawtooth", "duration": 0.5}', 3),
('EMJ004', 'clap'::emoji_type, 'Clap', 'https://cdn.mydomain.com/emojis/clap.png', 'Applause and approval', '👏', '#4caf50', 'from-green-400 via-emerald-500 to-teal-600', '{"frequency": 392.00, "type": "square", "duration": 0.2}', 4),
('EMJ005', 'fire'::emoji_type, 'Fire', 'https://cdn.mydomain.com/emojis/fire.png', 'Excitement and intensity', '🔥', '#ff5722', 'from-orange-500 via-red-500 to-pink-500', '{"frequency": 698.46, "type": "sine", "duration": 0.6}', 5),
('EMJ006', 'goal'::emoji_type, 'Soccer', 'https://cdn.mydomain.com/emojis/soccer.png', 'Football/soccer celebration', '⚽', '#8bc34a', 'from-green-500 via-lime-500 to-emerald-500', '{"frequency": 440.00, "type": "triangle", "duration": 0.8}', 6);

-- =====================================================
-- SAMPLE TEAMS DATA
-- =====================================================

-- Get football sport ID for team creation
DO $$
DECLARE
    football_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    -- Premier League Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    ('TEAM001', 'Arsenal', 'ARS', 'https://cdn.mydomain.com/logos/arsenal.png', '{"primary": "#DC143C", "secondary": "#FFFFFF"}', football_sport_id),
    ('TEAM002', 'Chelsea', 'CHE', 'https://cdn.mydomain.com/logos/chelsea.png', '{"primary": "#034694", "secondary": "#FFFFFF"}', football_sport_id),
    ('TEAM003', 'Liverpool', 'LIV', 'https://cdn.mydomain.com/logos/liverpool.png', '{"primary": "#C8102E", "secondary": "#FFFFFF"}', football_sport_id),
    ('TEAM004', 'Manchester City', 'MCI', 'https://cdn.mydomain.com/logos/mancity.png', '{"primary": "#6CABDD", "secondary": "#FFFFFF"}', football_sport_id),
    ('TEAM005', 'Manchester United', 'MUN', 'https://cdn.mydomain.com/logos/manutd.png', '{"primary": "#DA020E", "secondary": "#FFFFFF"}', football_sport_id),
    ('TEAM006', 'Tottenham', 'TOT', 'https://cdn.mydomain.com/logos/tottenham.png', '{"primary": "#132257", "secondary": "#FFFFFF"}', football_sport_id);
    
    -- La Liga Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    ('TEAM007', 'Barcelona', 'BAR', 'https://cdn.mydomain.com/logos/barcelona.png', '{"primary": "#A50044", "secondary": "#004D98"}', football_sport_id),
    ('TEAM008', 'Real Madrid', 'RMA', 'https://cdn.mydomain.com/logos/realmadrid.png', '{"primary": "#FFFFFF", "secondary": "#FEBE10"}', football_sport_id);
    
    -- Champions League Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    ('TEAM009', 'PSG', 'PSG', 'https://cdn.mydomain.com/logos/psg.png', '{"primary": "#004170", "secondary": "#DA020E"}', football_sport_id),
    ('TEAM010', 'Bayern Munich', 'BAY', 'https://cdn.mydomain.com/logos/bayern.png', '{"primary": "#DC052D", "secondary": "#FFFFFF"}', football_sport_id);
END $$;

-- =====================================================
-- SAMPLE EVENTS DATA
-- =====================================================

DO $$
DECLARE
    football_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    INSERT INTO events (event_id, name, description, sport_id, start_date, end_date, location, organizer, is_featured) VALUES
    ('EVT001', 'Premier League 2024/25', 'English Premier League Season 2024/25', football_sport_id, '2024-08-01 00:00:00+00', '2025-05-31 23:59:59+00', 'England', 'Premier League', true),
    ('EVT002', 'UEFA Champions League 2024/25', 'UEFA Champions League Season 2024/25', football_sport_id, '2024-09-01 00:00:00+00', '2025-06-30 23:59:59+00', 'Europe', 'UEFA', true),
    ('EVT003', 'La Liga 2024/25', 'Spanish La Liga Season 2024/25', football_sport_id, '2024-08-01 00:00:00+00', '2025-05-31 23:59:59+00', 'Spain', 'La Liga', true);
END $$;

-- =====================================================
-- SAMPLE MATCHES DATA (Based on Mock Data)
-- =====================================================

DO $$
DECLARE
    premier_league_id UUID := 'EVT001';
    champions_league_id UUID := 'EVT002';
    la_liga_id UUID := 'EVT003';
    football_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    -- Current Live Match (Arsenal vs Chelsea)
    INSERT INTO matches (match_id, event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, thumbnail_url) VALUES
    ('MATCH001', premier_league_id, 'TEAM001', 'TEAM002', football_sport_id, 'live', CURRENT_TIMESTAMP - INTERVAL '67 minutes', 'Emirates Stadium', 'Premier League', 'https://stream.example.com/match001', 12847, true, '/api/placeholder/400/225');
    
    -- Other Live/Featured Matches from Mock Data
    INSERT INTO matches (match_id, event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, is_trending, thumbnail_url) VALUES
    ('MATCH002', premier_league_id, 'TEAM003', 'TEAM004', football_sport_id, 'live', CURRENT_TIMESTAMP - INTERVAL '73 minutes', 'Anfield', 'Premier League', 'https://stream.example.com/match002', 18500, true, true, '/api/placeholder/400/225'),
    ('MATCH003', premier_league_id, 'TEAM005', 'TEAM006', football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '3 hours', 'Old Trafford', 'Premier League', 'https://stream.example.com/match003', 0, false, false, '/api/placeholder/400/225'),
    ('MATCH004', la_liga_id, 'TEAM007', 'TEAM008', football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '6 hours', 'Camp Nou', 'La Liga', 'https://stream.example.com/match004', 0, true, false, '/api/placeholder/400/225'),
    ('MATCH005', champions_league_id, 'TEAM009', 'TEAM010', football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '8 hours 45 minutes', 'Parc des Princes', 'UEFA Champions League', 'https://stream.example.com/match005', 0, true, false, '/api/placeholder/400/225');
END $$;

-- =====================================================
-- SAMPLE MATCH SCORES
-- =====================================================

-- Current live match score (Arsenal 2-1 Chelsea)
INSERT INTO match_scores (match_id, home_score, away_score, current_time) VALUES
('MATCH001', 2, 1, '67''');

-- Liverpool vs Man City live score
INSERT INTO match_scores (match_id, home_score, away_score, current_time) VALUES
('MATCH002', 1, 1, '73''');

-- =====================================================
-- SAMPLE MATCH EVENTS (Arsenal vs Chelsea)
-- =====================================================

INSERT INTO match_events (match_id, event_type, minute, team_id, player_name, description, details, impact) VALUES
('MATCH001', 'goal', 12, 'TEAM001', 'Bukayo Saka', 'Goal', 'Right footed shot from the centre of the box to the bottom left corner.', 'high'),
('MATCH001', 'goal', 34, 'TEAM002', 'Raheem Sterling', 'Goal', 'Left footed shot from outside the box to the top right corner.', 'high'),
('MATCH001', 'card', 45, 'TEAM002', 'Enzo Fernández', 'Yellow Card', 'Foul on Declan Rice', 'medium'),
('MATCH001', 'goal', 56, 'TEAM001', 'Gabriel Jesus', 'Goal', 'Header from close range after corner kick.', 'high'),
('MATCH001', 'substitution', 62, 'TEAM001', 'Leandro Trossard', 'Substitution', 'Leandro Trossard replaces Gabriel Martinelli', 'low');

-- =====================================================
-- SAMPLE MATCH STATISTICS (Arsenal vs Chelsea)
-- =====================================================

INSERT INTO match_statistics (match_id, stat_type, home_value, away_value, home_display, away_display) VALUES
('MATCH001', 'possession', 58, 42, '58%', '42%'),
('MATCH001', 'shots', 12, 8, '12', '8'),
('MATCH001', 'shots_on_target', 6, 3, '6', '3'),
('MATCH001', 'corners', 7, 4, '7', '4'),
('MATCH001', 'fouls', 11, 9, '11', '9'),
('MATCH001', 'yellow_cards', 2, 1, '2', '1');

-- =====================================================
-- SAMPLE TEAM LINEUPS
-- =====================================================

-- Arsenal lineup (4-3-3 formation)
INSERT INTO match_lineups (match_id, team_id, formation, players) VALUES
('MATCH001', 'TEAM001', '4-3-3', '[
    {"name": "Ramsdale", "position": "GK", "number": "1"},
    {"name": "White", "position": "RB", "number": "4"},
    {"name": "Saliba", "position": "CB", "number": "2"},
    {"name": "Gabriel", "position": "CB", "number": "6"},
    {"name": "Zinchenko", "position": "LB", "number": "35"},
    {"name": "Partey", "position": "CDM", "number": "5"},
    {"name": "Rice", "position": "CM", "number": "41"},
    {"name": "Ødegaard", "position": "CAM", "number": "8"},
    {"name": "Saka", "position": "RW", "number": "7"},
    {"name": "Jesus", "position": "ST", "number": "9"},
    {"name": "Martinelli", "position": "LW", "number": "11"}
]');

-- Chelsea lineup (4-2-3-1 formation)
INSERT INTO match_lineups (match_id, team_id, formation, players) VALUES
('MATCH001', 'TEAM002', '4-2-3-1', '[
    {"name": "Kepa", "position": "GK", "number": "1"},
    {"name": "James", "position": "RB", "number": "24"},
    {"name": "Silva", "position": "CB", "number": "6"},
    {"name": "Koulibaly", "position": "CB", "number": "26"},
    {"name": "Chilwell", "position": "LB", "number": "21"},
    {"name": "Kanté", "position": "CDM", "number": "7"},
    {"name": "Fernández", "position": "CDM", "number": "5"},
    {"name": "Mount", "position": "CAM", "number": "19"},
    {"name": "Sterling", "position": "RW", "number": "17"},
    {"name": "Jackson", "position": "ST", "number": "15"},
    {"name": "Mudryk", "position": "LW", "number": "10"}
]');

-- =====================================================
-- SAMPLE STREAM QUALITIES
-- =====================================================

-- Stream qualities for the live match
INSERT INTO stream_qualities (match_id, quality_name, stream_url, bitrate, resolution, is_default) VALUES
('MATCH001', '4K', 'https://stream.example.com/match001/4k', 15000, '3840x2160', false),
('MATCH001', 'HD', 'https://stream.example.com/match001/hd', 8000, '1920x1080', false),
('MATCH001', '720p', 'https://stream.example.com/match001/720p', 4000, '1280x720', true),
('MATCH001', '480p', 'https://stream.example.com/match001/480p', 2000, '854x480', false),
('MATCH001', 'Auto', 'https://stream.example.com/match001/auto', 0, 'adaptive', false);

-- =====================================================
-- SAMPLE HIGHLIGHTS
-- =====================================================

INSERT INTO highlights (highlight_id, match_id, title, description, video_url, thumbnail_url, duration, tags, view_count) VALUES
('HIGH001', 'MATCH001', 'Bukayo Saka opens the scoring', 'Beautiful finish from Bukayo Saka in the 12th minute', 'https://highlights.example.com/match001/goal1', 'https://thumbnails.example.com/match001/goal1.jpg', 45, '{"goal", "saka", "arsenal"}', 1250),
('HIGH002', 'MATCH001', 'Sterling equalizes for Chelsea', 'Stunning strike from Raheem Sterling from outside the box', 'https://highlights.example.com/match001/goal2', 'https://thumbnails.example.com/match001/goal2.jpg', 38, '{"goal", "sterling", "chelsea"}', 980),
('HIGH003', 'MATCH001', 'Gabriel Jesus gives Arsenal the lead', 'Header from close range after a perfect corner kick delivery', 'https://highlights.example.com/match001/goal3', 'https://thumbnails.example.com/match001/goal3.jpg', 42, '{"goal", "jesus", "arsenal", "header"}', 756);

-- =====================================================
-- SAMPLE USER DATA (For Testing)
-- =====================================================

-- Create test users
INSERT INTO users (user_id, email, username, password_hash, full_name, role) VALUES
('USER001', 'admin@sportstelecast.com', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'System Admin', 'admin'),
('USER002', 'sportsf4n@example.com', 'SportsF4n', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Sports Fan', 'user'),
('USER003', 'footyexpert@example.com', 'FootyExpert', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Football Expert', 'user'),
('USER004', 'goalmachine@example.com', 'GoalMachine', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Goal Machine', 'user');

-- Create user preferences
INSERT INTO user_preferences (user_id, favorite_teams, favorite_sports, notification_settings) VALUES
('USER002', '{"TEAM001", "TEAM003"}', '{"football"}', '{"match_start": true, "goals": true, "final_score": true}'),
('USER003', '{"TEAM002", "TEAM004"}', '{"football"}', '{"match_start": true, "goals": true, "cards": true}'),
('USER004', '{"TEAM001", "TEAM007"}', '{"football"}', '{"goals": true, "highlights": true}');

-- =====================================================
-- SAMPLE EMOJI REACTIONS
-- =====================================================

-- Sample emoji reactions for the live match
INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id) VALUES
('USER002', 'EVT001', 'MATCH001', 'EMJ001'), -- love
('USER002', 'EVT001', 'MATCH001', 'EMJ004'), -- clap
('USER003', 'EVT001', 'MATCH001', 'EMJ002'), -- laugh
('USER004', 'EVT001', 'MATCH001', 'EMJ001'), -- love
('USER004', 'EVT001', 'MATCH001', 'EMJ005'); -- fire

-- Populate emoji reaction summary
INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count) VALUES
('EVT001', 'MATCH001', 'EMJ001', 342), -- love: 342
('EVT001', 'MATCH001', 'EMJ002', 128), -- laugh: 128
('EVT001', 'MATCH001', 'EMJ003', 89),  -- wow: 89
('EVT001', 'MATCH001', 'EMJ004', 205), -- clap: 205
('EVT001', 'MATCH001', 'EMJ005', 167), -- fire: 167
('EVT001', 'MATCH001', 'EMJ006', 95);  -- soccer: 95

-- =====================================================
-- SAMPLE CHAT MESSAGES
-- =====================================================

INSERT INTO chat_messages (event_id, match_id, user_id, message) VALUES
('EVT001', 'MATCH001', 'USER002', 'Great goal by Arsenal! 🔥'),
('EVT001', 'MATCH001', 'USER003', 'Chelsea needs to step up their game'),
('EVT001', 'MATCH001', 'USER004', 'This match is incredible!'),
('EVT001', 'MATCH001', 'USER002', 'Arsenal looking strong today');

-- =====================================================
-- SAMPLE VIEWER DATA
-- =====================================================

-- Current viewer sessions for the live match
INSERT INTO viewer_sessions (user_id, match_id, join_time, quality_watched) VALUES
('USER002', 'MATCH001', CURRENT_TIMESTAMP - INTERVAL '30 minutes', '720p'),
('USER003', 'MATCH001', CURRENT_TIMESTAMP - INTERVAL '45 minutes', 'HD'),
('USER004', 'MATCH001', CURRENT_TIMESTAMP - INTERVAL '20 minutes', '720p');

-- Viewer count snapshots
INSERT INTO viewer_count_snapshots (match_id, viewer_count) VALUES
('MATCH001', 12847),
('MATCH002', 18500);
