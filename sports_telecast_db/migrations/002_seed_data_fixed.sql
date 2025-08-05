-- Sports Telecast Database - Seed Data (Fixed)
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

INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, color, gradient_class, sound_config, sort_order) VALUES
('heart'::emoji_type, 'Love', 'https://cdn.mydomain.com/emojis/heart.png', 'Love and appreciation', '❤️', '#ff1744', 'from-pink-500 via-red-500 to-rose-600', '{"frequency": 523.25, "type": "sine", "duration": 0.3}', 1),
('laugh'::emoji_type, 'Laugh', 'https://cdn.mydomain.com/emojis/laugh.png', 'Laughter and joy', '😂', '#ffc107', 'from-yellow-400 via-orange-400 to-red-400', '{"frequency": 659.25, "type": "triangle", "duration": 0.4}', 2),
('shocked'::emoji_type, 'Wow', 'https://cdn.mydomain.com/emojis/wow.png', 'Surprise and amazement', '😮', '#2196f3', 'from-blue-400 via-purple-500 to-indigo-600', '{"frequency": 783.99, "type": "sawtooth", "duration": 0.5}', 3),
('clap'::emoji_type, 'Clap', 'https://cdn.mydomain.com/emojis/clap.png', 'Applause and approval', '👏', '#4caf50', 'from-green-400 via-emerald-500 to-teal-600', '{"frequency": 392.00, "type": "square", "duration": 0.2}', 4),
('fire'::emoji_type, 'Fire', 'https://cdn.mydomain.com/emojis/fire.png', 'Excitement and intensity', '🔥', '#ff5722', 'from-orange-500 via-red-500 to-pink-500', '{"frequency": 698.46, "type": "sine", "duration": 0.6}', 5),
('goal'::emoji_type, 'Soccer', 'https://cdn.mydomain.com/emojis/soccer.png', 'Football/soccer celebration', '⚽', '#8bc34a', 'from-green-500 via-lime-500 to-emerald-500', '{"frequency": 440.00, "type": "triangle", "duration": 0.8}', 6);

-- =====================================================
-- SAMPLE TEAMS DATA
-- =====================================================

-- Get football sport ID for team creation
DO $$
DECLARE
    football_sport_id UUID;
    arsenal_id UUID := uuid_generate_v4();
    chelsea_id UUID := uuid_generate_v4();
    liverpool_id UUID := uuid_generate_v4();
    mancity_id UUID := uuid_generate_v4();
    manutd_id UUID := uuid_generate_v4();
    tottenham_id UUID := uuid_generate_v4();
    barcelona_id UUID := uuid_generate_v4();
    realmadrid_id UUID := uuid_generate_v4();
    psg_id UUID := uuid_generate_v4();
    bayern_id UUID := uuid_generate_v4();
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    -- Premier League Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    (arsenal_id, 'Arsenal', 'ARS', 'https://cdn.mydomain.com/logos/arsenal.png', '{"primary": "#DC143C", "secondary": "#FFFFFF"}', football_sport_id),
    (chelsea_id, 'Chelsea', 'CHE', 'https://cdn.mydomain.com/logos/chelsea.png', '{"primary": "#034694", "secondary": "#FFFFFF"}', football_sport_id),
    (liverpool_id, 'Liverpool', 'LIV', 'https://cdn.mydomain.com/logos/liverpool.png', '{"primary": "#C8102E", "secondary": "#FFFFFF"}', football_sport_id),
    (mancity_id, 'Manchester City', 'MCI', 'https://cdn.mydomain.com/logos/mancity.png', '{"primary": "#6CABDD", "secondary": "#FFFFFF"}', football_sport_id),
    (manutd_id, 'Manchester United', 'MUN', 'https://cdn.mydomain.com/logos/manutd.png', '{"primary": "#DA020E", "secondary": "#FFFFFF"}', football_sport_id),
    (tottenham_id, 'Tottenham', 'TOT', 'https://cdn.mydomain.com/logos/tottenham.png', '{"primary": "#132257", "secondary": "#FFFFFF"}', football_sport_id);
    
    -- La Liga Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    (barcelona_id, 'Barcelona', 'BAR', 'https://cdn.mydomain.com/logos/barcelona.png', '{"primary": "#A50044", "secondary": "#004D98"}', football_sport_id),
    (realmadrid_id, 'Real Madrid', 'RMA', 'https://cdn.mydomain.com/logos/realmadrid.png', '{"primary": "#FFFFFF", "secondary": "#FEBE10"}', football_sport_id);
    
    -- Champions League Teams
    INSERT INTO teams (team_id, name, short_name, logo_url, colors, sport_id) VALUES
    (psg_id, 'PSG', 'PSG', 'https://cdn.mydomain.com/logos/psg.png', '{"primary": "#004170", "secondary": "#DA020E"}', football_sport_id),
    (bayern_id, 'Bayern Munich', 'BAY', 'https://cdn.mydomain.com/logos/bayern.png', '{"primary": "#DC052D", "secondary": "#FFFFFF"}', football_sport_id);

    -- Store team IDs in a temporary table for later use
    CREATE TEMP TABLE IF NOT EXISTS temp_team_ids (
        name VARCHAR(50),
        team_id UUID
    );
    
    INSERT INTO temp_team_ids VALUES
    ('Arsenal', arsenal_id),
    ('Chelsea', chelsea_id),
    ('Liverpool', liverpool_id),
    ('Manchester City', mancity_id),
    ('Manchester United', manutd_id),
    ('Tottenham', tottenham_id),
    ('Barcelona', barcelona_id),
    ('Real Madrid', realmadrid_id),
    ('PSG', psg_id),
    ('Bayern Munich', bayern_id);
END $$;

-- =====================================================
-- SAMPLE EVENTS DATA
-- =====================================================

DO $$
DECLARE
    football_sport_id UUID;
    premier_league_id UUID := uuid_generate_v4();
    champions_league_id UUID := uuid_generate_v4();
    la_liga_id UUID := uuid_generate_v4();
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    INSERT INTO events (event_id, name, description, sport_id, start_date, end_date, location, organizer, is_featured) VALUES
    (premier_league_id, 'Premier League 2024/25', 'English Premier League Season 2024/25', football_sport_id, '2024-08-01 00:00:00+00', '2025-05-31 23:59:59+00', 'England', 'Premier League', true),
    (champions_league_id, 'UEFA Champions League 2024/25', 'UEFA Champions League Season 2024/25', football_sport_id, '2024-09-01 00:00:00+00', '2025-06-30 23:59:59+00', 'Europe', 'UEFA', true),
    (la_liga_id, 'La Liga 2024/25', 'Spanish La Liga Season 2024/25', football_sport_id, '2024-08-01 00:00:00+00', '2025-05-31 23:59:59+00', 'Spain', 'La Liga', true);

    -- Store event IDs for later use
    CREATE TEMP TABLE IF NOT EXISTS temp_event_ids (
        name VARCHAR(50),
        event_id UUID
    );
    
    INSERT INTO temp_event_ids VALUES
    ('Premier League', premier_league_id),
    ('Champions League', champions_league_id),
    ('La Liga', la_liga_id);
END $$;

-- =====================================================
-- SAMPLE MATCHES DATA (Based on Mock Data)
-- =====================================================

DO $$
DECLARE
    premier_league_id UUID;
    champions_league_id UUID;
    la_liga_id UUID;
    football_sport_id UUID;
    arsenal_id UUID;
    chelsea_id UUID;
    liverpool_id UUID;
    mancity_id UUID;
    manutd_id UUID;
    tottenham_id UUID;
    barcelona_id UUID;
    realmadrid_id UUID;
    psg_id UUID;
    bayern_id UUID;
    match1_id UUID := uuid_generate_v4();
    match2_id UUID := uuid_generate_v4();
    match3_id UUID := uuid_generate_v4();
    match4_id UUID := uuid_generate_v4();
    match5_id UUID := uuid_generate_v4();
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    SELECT event_id INTO premier_league_id FROM temp_event_ids WHERE name = 'Premier League';
    SELECT event_id INTO champions_league_id FROM temp_event_ids WHERE name = 'Champions League';
    SELECT event_id INTO la_liga_id FROM temp_event_ids WHERE name = 'La Liga';
    
    SELECT team_id INTO arsenal_id FROM temp_team_ids WHERE name = 'Arsenal';
    SELECT team_id INTO chelsea_id FROM temp_team_ids WHERE name = 'Chelsea';
    SELECT team_id INTO liverpool_id FROM temp_team_ids WHERE name = 'Liverpool';
    SELECT team_id INTO mancity_id FROM temp_team_ids WHERE name = 'Manchester City';
    SELECT team_id INTO manutd_id FROM temp_team_ids WHERE name = 'Manchester United';
    SELECT team_id INTO tottenham_id FROM temp_team_ids WHERE name = 'Tottenham';
    SELECT team_id INTO barcelona_id FROM temp_team_ids WHERE name = 'Barcelona';
    SELECT team_id INTO realmadrid_id FROM temp_team_ids WHERE name = 'Real Madrid';
    SELECT team_id INTO psg_id FROM temp_team_ids WHERE name = 'PSG';
    SELECT team_id INTO bayern_id FROM temp_team_ids WHERE name = 'Bayern Munich';
    
    -- Current Live Match (Arsenal vs Chelsea)
    INSERT INTO matches (match_id, event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, thumbnail_url) VALUES
    (match1_id, premier_league_id, arsenal_id, chelsea_id, football_sport_id, 'live', CURRENT_TIMESTAMP - INTERVAL '67 minutes', 'Emirates Stadium', 'Premier League', 'https://stream.example.com/match001', 12847, true, '/api/placeholder/400/225');
    
    -- Other Live/Featured Matches from Mock Data
    INSERT INTO matches (match_id, event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, is_trending, thumbnail_url) VALUES
    (match2_id, premier_league_id, liverpool_id, mancity_id, football_sport_id, 'live', CURRENT_TIMESTAMP - INTERVAL '73 minutes', 'Anfield', 'Premier League', 'https://stream.example.com/match002', 18500, true, true, '/api/placeholder/400/225'),
    (match3_id, premier_league_id, manutd_id, tottenham_id, football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '3 hours', 'Old Trafford', 'Premier League', 'https://stream.example.com/match003', 0, false, false, '/api/placeholder/400/225'),
    (match4_id, la_liga_id, barcelona_id, realmadrid_id, football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '6 hours', 'Camp Nou', 'La Liga', 'https://stream.example.com/match004', 0, true, false, '/api/placeholder/400/225'),
    (match5_id, champions_league_id, psg_id, bayern_id, football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '8 hours 45 minutes', 'Parc des Princes', 'UEFA Champions League', 'https://stream.example.com/match005', 0, true, false, '/api/placeholder/400/225');

    -- Store match IDs for later use
    CREATE TEMP TABLE IF NOT EXISTS temp_match_ids (
        name VARCHAR(50),
        match_id UUID
    );
    
    INSERT INTO temp_match_ids VALUES
    ('Arsenal vs Chelsea', match1_id),
    ('Liverpool vs Man City', match2_id),
    ('Man Utd vs Tottenham', match3_id),
    ('Barcelona vs Real Madrid', match4_id),
    ('PSG vs Bayern', match5_id);
END $$;

-- =====================================================
-- SAMPLE MATCH SCORES
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
    match2_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    SELECT match_id INTO match2_id FROM temp_match_ids WHERE name = 'Liverpool vs Man City';
    
    -- Current live match score (Arsenal 2-1 Chelsea)
    INSERT INTO match_scores (match_id, home_score, away_score, match_time) VALUES
    (match1_id, 2, 1, '67''');

    -- Liverpool vs Man City live score
    INSERT INTO match_scores (match_id, home_score, away_score, match_time) VALUES
    (match2_id, 1, 1, '73''');
END $$;

-- =====================================================
-- SAMPLE MATCH EVENTS (Arsenal vs Chelsea)
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
    arsenal_id UUID;
    chelsea_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    SELECT team_id INTO arsenal_id FROM temp_team_ids WHERE name = 'Arsenal';
    SELECT team_id INTO chelsea_id FROM temp_team_ids WHERE name = 'Chelsea';
    
    INSERT INTO match_events (match_id, event_type, minute, team_id, player_name, description, details, impact) VALUES
    (match1_id, 'goal', 12, arsenal_id, 'Bukayo Saka', 'Goal', 'Right footed shot from the centre of the box to the bottom left corner.', 'high'),
    (match1_id, 'goal', 34, chelsea_id, 'Raheem Sterling', 'Goal', 'Left footed shot from outside the box to the top right corner.', 'high'),
    (match1_id, 'card', 45, chelsea_id, 'Enzo Fernández', 'Yellow Card', 'Foul on Declan Rice', 'medium'),
    (match1_id, 'goal', 56, arsenal_id, 'Gabriel Jesus', 'Goal', 'Header from close range after corner kick.', 'high'),
    (match1_id, 'substitution', 62, arsenal_id, 'Leandro Trossard', 'Substitution', 'Leandro Trossard replaces Gabriel Martinelli', 'low');
END $$;

-- =====================================================
-- SAMPLE MATCH STATISTICS (Arsenal vs Chelsea)
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    
    INSERT INTO match_statistics (match_id, stat_type, home_value, away_value, home_display, away_display) VALUES
    (match1_id, 'possession', 58, 42, '58%', '42%'),
    (match1_id, 'shots', 12, 8, '12', '8'),
    (match1_id, 'shots_on_target', 6, 3, '6', '3'),
    (match1_id, 'corners', 7, 4, '7', '4'),
    (match1_id, 'fouls', 11, 9, '11', '9'),
    (match1_id, 'yellow_cards', 2, 1, '2', '1');
END $$;

-- =====================================================
-- SAMPLE TEAM LINEUPS
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
    arsenal_id UUID;
    chelsea_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    SELECT team_id INTO arsenal_id FROM temp_team_ids WHERE name = 'Arsenal';
    SELECT team_id INTO chelsea_id FROM temp_team_ids WHERE name = 'Chelsea';
    
    -- Arsenal lineup (4-3-3 formation)
    INSERT INTO match_lineups (match_id, team_id, formation, players) VALUES
    (match1_id, arsenal_id, '4-3-3', '[
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
    (match1_id, chelsea_id, '4-2-3-1', '[
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
END $$;

-- =====================================================
-- SAMPLE STREAM QUALITIES
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    
    -- Stream qualities for the live match
    INSERT INTO stream_qualities (match_id, quality_name, stream_url, bitrate, resolution, is_default) VALUES
    (match1_id, '4K', 'https://stream.example.com/match001/4k', 15000, '3840x2160', false),
    (match1_id, 'HD', 'https://stream.example.com/match001/hd', 8000, '1920x1080', false),
    (match1_id, '720p', 'https://stream.example.com/match001/720p', 4000, '1280x720', true),
    (match1_id, '480p', 'https://stream.example.com/match001/480p', 2000, '854x480', false),
    (match1_id, 'Auto', 'https://stream.example.com/match001/auto', 0, 'adaptive', false);
END $$;

-- =====================================================
-- SAMPLE HIGHLIGHTS
-- =====================================================

DO $$
DECLARE
    match1_id UUID;
BEGIN
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    
    INSERT INTO highlights (match_id, title, description, video_url, thumbnail_url, duration, tags, view_count) VALUES
    (match1_id, 'Bukayo Saka opens the scoring', 'Beautiful finish from Bukayo Saka in the 12th minute', 'https://highlights.example.com/match001/goal1', 'https://thumbnails.example.com/match001/goal1.jpg', 45, '{"goal", "saka", "arsenal"}', 1250),
    (match1_id, 'Sterling equalizes for Chelsea', 'Stunning strike from Raheem Sterling from outside the box', 'https://highlights.example.com/match001/goal2', 'https://thumbnails.example.com/match001/goal2.jpg', 38, '{"goal", "sterling", "chelsea"}', 980),
    (match1_id, 'Gabriel Jesus gives Arsenal the lead', 'Header from close range after a perfect corner kick delivery', 'https://highlights.example.com/match001/goal3', 'https://thumbnails.example.com/match001/goal3.jpg', 42, '{"goal", "jesus", "arsenal", "header"}', 756);
END $$;

-- =====================================================
-- SAMPLE USER DATA (For Testing)
-- =====================================================

DO $$
DECLARE
    user1_id UUID := uuid_generate_v4();
    user2_id UUID := uuid_generate_v4();
    user3_id UUID := uuid_generate_v4();
    user4_id UUID := uuid_generate_v4();
    premier_league_id UUID;
    match1_id UUID;
    emoji1_id UUID;
    emoji2_id UUID;
    emoji3_id UUID;
    emoji4_id UUID;
    emoji5_id UUID;
    emoji6_id UUID;
BEGIN
    SELECT event_id INTO premier_league_id FROM temp_event_ids WHERE name = 'Premier League';
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Arsenal vs Chelsea';
    
    -- Create test users
    INSERT INTO users (user_id, email, username, password_hash, full_name, role) VALUES
    (user1_id, 'admin@sportstelecast.com', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'System Admin', 'admin'),
    (user2_id, 'sportsf4n@example.com', 'SportsF4n', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Sports Fan', 'user'),
    (user3_id, 'footyexpert@example.com', 'FootyExpert', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Football Expert', 'user'),
    (user4_id, 'goalmachine@example.com', 'GoalMachine', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Goal Machine', 'user');

    -- Create user preferences
    INSERT INTO user_preferences (user_id, favorite_teams, favorite_sports, notification_settings) VALUES
    (user2_id, '{"Arsenal", "Liverpool"}', '{"football"}', '{"match_start": true, "goals": true, "final_score": true}'),
    (user3_id, '{"Chelsea", "Manchester City"}', '{"football"}', '{"match_start": true, "goals": true, "cards": true}'),
    (user4_id, '{"Arsenal", "Barcelona"}', '{"football"}', '{"goals": true, "highlights": true}');

    -- Get emoji IDs
    SELECT emoji_id INTO emoji1_id FROM emoji_assets WHERE emoji_type = 'heart';
    SELECT emoji_id INTO emoji2_id FROM emoji_assets WHERE emoji_type = 'laugh';
    SELECT emoji_id INTO emoji3_id FROM emoji_assets WHERE emoji_type = 'shocked';
    SELECT emoji_id INTO emoji4_id FROM emoji_assets WHERE emoji_type = 'clap';
    SELECT emoji_id INTO emoji5_id FROM emoji_assets WHERE emoji_type = 'fire';
    SELECT emoji_id INTO emoji6_id FROM emoji_assets WHERE emoji_type = 'goal';

    -- Sample emoji reactions for the live match
    INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id) VALUES
    (user2_id, premier_league_id, match1_id, emoji1_id), -- love
    (user2_id, premier_league_id, match1_id, emoji4_id), -- clap
    (user3_id, premier_league_id, match1_id, emoji2_id), -- laugh
    (user4_id, premier_league_id, match1_id, emoji1_id), -- love
    (user4_id, premier_league_id, match1_id, emoji5_id); -- fire

    -- Populate emoji reaction summary
    INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count) VALUES
    (premier_league_id, match1_id, emoji1_id, 342), -- love: 342
    (premier_league_id, match1_id, emoji2_id, 128), -- laugh: 128
    (premier_league_id, match1_id, emoji3_id, 89),  -- wow: 89
    (premier_league_id, match1_id, emoji4_id, 205), -- clap: 205
    (premier_league_id, match1_id, emoji5_id, 167), -- fire: 167
    (premier_league_id, match1_id, emoji6_id, 95);  -- soccer: 95

    -- Sample chat messages
    INSERT INTO chat_messages (event_id, match_id, user_id, message) VALUES
    (premier_league_id, match1_id, user2_id, 'Great goal by Arsenal! 🔥'),
    (premier_league_id, match1_id, user3_id, 'Chelsea needs to step up their game'),
    (premier_league_id, match1_id, user4_id, 'This match is incredible!'),
    (premier_league_id, match1_id, user2_id, 'Arsenal looking strong today');

    -- Current viewer sessions for the live match
    INSERT INTO viewer_sessions (user_id, match_id, join_time, quality_watched) VALUES
    (user2_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '30 minutes', '720p'),
    (user3_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '45 minutes', 'HD'),
    (user4_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '20 minutes', '720p');

    -- Viewer count snapshots
    INSERT INTO viewer_count_snapshots (match_id, viewer_count) VALUES
    (match1_id, 12847);
    
    SELECT match_id INTO match1_id FROM temp_match_ids WHERE name = 'Liverpool vs Man City';
    INSERT INTO viewer_count_snapshots (match_id, viewer_count) VALUES
    (match1_id, 18500);
END $$;

-- Clean up temp tables
DROP TABLE IF EXISTS temp_team_ids;
DROP TABLE IF EXISTS temp_event_ids;
DROP TABLE IF EXISTS temp_match_ids;
