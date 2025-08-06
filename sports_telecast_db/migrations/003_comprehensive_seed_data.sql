-- Sports Telecast Database - Comprehensive Mock Data
-- This script populates the database with extensive realistic data for all tables

-- =====================================================
-- ADDITIONAL SPORTS DATA
-- =====================================================

-- Add more sports beyond the basic ones
INSERT INTO sports (sport_id, name, display_name, description) VALUES
(uuid_generate_v4(), 'american_football', 'American Football', 'National Football League (NFL)'),
(uuid_generate_v4(), 'rugby', 'Rugby', 'Rugby Union and League'),
(uuid_generate_v4(), 'volleyball', 'Volleyball', 'Indoor and Beach Volleyball'),
(uuid_generate_v4(), 'golf', 'Golf', 'Professional Golf'),
(uuid_generate_v4(), 'formula1', 'Formula 1', 'Formula 1 Racing'),
(uuid_generate_v4(), 'mma', 'MMA', 'Mixed Martial Arts');

-- =====================================================
-- ADDITIONAL EMOJI ASSETS WITH MORE VARIETY
-- =====================================================

INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, color, gradient_class, sound_config, sort_order) VALUES
('thumbs_up'::emoji_type, 'Thumbs Up', 'https://cdn.sportstream.com/emojis/thumbs_up.png', 'Approval and agreement', '👍', '#4caf50', 'from-green-400 via-emerald-500 to-teal-600', '{"frequency": 440.00, "type": "sine", "duration": 0.3}', 7),
('celebration'::emoji_type, 'Celebration', 'https://cdn.sportstream.com/emojis/celebration.png', 'Victory and celebration', '🎉', '#ff9800', 'from-yellow-400 via-orange-400 to-red-400', '{"frequency": 587.33, "type": "triangle", "duration": 0.7}', 8),
('angry'::emoji_type, 'Angry', 'https://cdn.sportstream.com/emojis/angry.png', 'Frustration and anger', '😠', '#f44336', 'from-red-500 via-pink-500 to-rose-600', '{"frequency": 311.13, "type": "square", "duration": 0.4}', 9),
('sad'::emoji_type, 'Sad', 'https://cdn.sportstream.com/emojis/sad.png', 'Disappointment and sadness', '😢', '#607d8b', 'from-gray-400 via-blue-gray-500 to-slate-600', '{"frequency": 246.94, "type": "sine", "duration": 0.6}', 10);

-- =====================================================
-- COMPREHENSIVE TEAMS DATA
-- =====================================================

DO $$
DECLARE
    football_sport_id UUID;
    basketball_sport_id UUID;
    tennis_sport_id UUID;
    american_football_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    SELECT sport_id INTO basketball_sport_id FROM sports WHERE name = 'basketball';
    SELECT sport_id INTO tennis_sport_id FROM sports WHERE name = 'tennis';
    SELECT sport_id INTO american_football_sport_id FROM sports WHERE name = 'american_football';
    
    -- Additional Premier League Teams
    INSERT INTO teams (name, short_name, logo_url, colors, sport_id) VALUES
    ('Newcastle United', 'NEW', 'https://cdn.sportstream.com/logos/newcastle.png', '{"primary": "#241F20", "secondary": "#FFFFFF"}', football_sport_id),
    ('Brighton & Hove Albion', 'BRI', 'https://cdn.sportstream.com/logos/brighton.png', '{"primary": "#0057B8", "secondary": "#FFCD00"}', football_sport_id),
    ('West Ham United', 'WHU', 'https://cdn.sportstream.com/logos/westham.png', '{"primary": "#7A263A", "secondary": "#1BB1E7"}', football_sport_id),
    ('Aston Villa', 'AVL', 'https://cdn.sportstream.com/logos/villa.png', '{"primary": "#95BFE5", "secondary": "#670E36"}', football_sport_id),
    ('Crystal Palace', 'CRY', 'https://cdn.sportstream.com/logos/palace.png', '{"primary": "#1B458F", "secondary": "#C4122E"}', football_sport_id),
    ('Fulham', 'FUL', 'https://cdn.sportstream.com/logos/fulham.png', '{"primary": "#FFFFFF", "secondary": "#000000"}', football_sport_id);
    
    -- Serie A Teams
    INSERT INTO teams (name, short_name, logo_url, colors, sport_id) VALUES
    ('Juventus', 'JUV', 'https://cdn.sportstream.com/logos/juventus.png', '{"primary": "#FFFFFF", "secondary": "#000000"}', football_sport_id),
    ('AC Milan', 'MIL', 'https://cdn.sportstream.com/logos/milan.png', '{"primary": "#FB090B", "secondary": "#000000"}', football_sport_id),
    ('Inter Milan', 'INT', 'https://cdn.sportstream.com/logos/inter.png', '{"primary": "#0068A8", "secondary": "#000000"}', football_sport_id),
    ('AS Roma', 'ROM', 'https://cdn.sportstream.com/logos/roma.png', '{"primary": "#ASB821", "secondary": "#F7DC6F"}', football_sport_id),
    ('Napoli', 'NAP', 'https://cdn.sportstream.com/logos/napoli.png', '{"primary": "#026CB6", "secondary": "#FFFFFF"}', football_sport_id);
    
    -- Bundesliga Teams
    INSERT INTO teams (name, short_name, logo_url, colors, sport_id) VALUES
    ('Borussia Dortmund', 'BVB', 'https://cdn.sportstream.com/logos/dortmund.png', '{"primary": "#FDE100", "secondary": "#000000"}', football_sport_id),
    ('RB Leipzig', 'RBL', 'https://cdn.sportstream.com/logos/leipzig.png', '{"primary": "#DD0741", "secondary": "#FFFFFF"}', football_sport_id),
    ('Bayer Leverkusen', 'B04', 'https://cdn.sportstream.com/logos/leverkusen.png', '{"primary": "#E32221", "secondary": "#000000"}', football_sport_id);
    
    -- NBA Teams
    INSERT INTO teams (name, short_name, logo_url, colors, sport_id) VALUES
    ('Los Angeles Lakers', 'LAL', 'https://cdn.sportstream.com/logos/lakers.png', '{"primary": "#552583", "secondary": "#FDB927"}', basketball_sport_id),
    ('Golden State Warriors', 'GSW', 'https://cdn.sportstream.com/logos/warriors.png', '{"primary": "#1D428A", "secondary": "#FFC72C"}', basketball_sport_id),
    ('Boston Celtics', 'BOS', 'https://cdn.sportstream.com/logos/celtics.png', '{"primary": "#007A33", "secondary": "#BA9653"}', basketball_sport_id),
    ('Miami Heat', 'MIA', 'https://cdn.sportstream.com/logos/heat.png', '{"primary": "#98002E", "secondary": "#F9A01B"}', basketball_sport_id),
    ('Chicago Bulls', 'CHI', 'https://cdn.sportstream.com/logos/bulls.png', '{"primary": "#CE1141", "secondary": "#000000"}', basketball_sport_id),
    ('New York Knicks', 'NYK', 'https://cdn.sportstream.com/logos/knicks.png', '{"primary": "#006BB6", "secondary": "#F58426"}', basketball_sport_id);
    
    -- NFL Teams
    INSERT INTO teams (name, short_name, logo_url, colors, sport_id) VALUES
    ('New England Patriots', 'NE', 'https://cdn.sportstream.com/logos/patriots.png', '{"primary": "#002244", "secondary": "#C60C30"}', american_football_sport_id),
    ('Dallas Cowboys', 'DAL', 'https://cdn.sportstream.com/logos/cowboys.png', '{"primary": "#041E42", "secondary": "#869397"}', american_football_sport_id),
    ('Green Bay Packers', 'GB', 'https://cdn.sportstream.com/logos/packers.png', '{"primary": "#203731", "secondary": "#FFB612"}', american_football_sport_id),
    ('Kansas City Chiefs', 'KC', 'https://cdn.sportstream.com/logos/chiefs.png', '{"primary": "#E31837", "secondary": "#FFB81C"}', american_football_sport_id);
END $$;

-- =====================================================
-- COMPREHENSIVE EVENTS DATA
-- =====================================================

DO $$
DECLARE
    football_sport_id UUID;
    basketball_sport_id UUID;
    american_football_sport_id UUID;
    tennis_sport_id UUID;
    formula1_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    SELECT sport_id INTO basketball_sport_id FROM sports WHERE name = 'basketball';
    SELECT sport_id INTO american_football_sport_id FROM sports WHERE name = 'american_football';
    SELECT sport_id INTO tennis_sport_id FROM sports WHERE name = 'tennis';
    SELECT sport_id INTO formula1_sport_id FROM sports WHERE name = 'formula1';
    
    INSERT INTO events (name, description, sport_id, start_date, end_date, location, organizer, logo_url, banner_url, is_featured) VALUES
    -- Football Events
    ('Serie A 2024/25', 'Italian Serie A Championship', football_sport_id, '2024-08-15 00:00:00+00', '2025-05-25 23:59:59+00', 'Italy', 'Lega Serie A', 'https://cdn.sportstream.com/events/seriea_logo.png', 'https://cdn.sportstream.com/events/seriea_banner.jpg', true),
    ('Bundesliga 2024/25', 'German Bundesliga Championship', football_sport_id, '2024-08-20 00:00:00+00', '2025-05-20 23:59:59+00', 'Germany', 'DFL', 'https://cdn.sportstream.com/events/bundesliga_logo.png', 'https://cdn.sportstream.com/events/bundesliga_banner.jpg', true),
    ('Europa League 2024/25', 'UEFA Europa League', football_sport_id, '2024-09-15 00:00:00+00', '2025-05-30 23:59:59+00', 'Europe', 'UEFA', 'https://cdn.sportstream.com/events/europa_logo.png', 'https://cdn.sportstream.com/events/europa_banner.jpg', false),
    ('FA Cup 2024/25', 'English FA Cup', football_sport_id, '2024-11-01 00:00:00+00', '2025-05-17 23:59:59+00', 'England', 'The FA', 'https://cdn.sportstream.com/events/facup_logo.png', 'https://cdn.sportstream.com/events/facup_banner.jpg', false),
    
    -- Basketball Events
    ('NBA Regular Season 2024/25', 'NBA Regular Season', basketball_sport_id, '2024-10-15 00:00:00+00', '2025-04-15 23:59:59+00', 'USA/Canada', 'NBA', 'https://cdn.sportstream.com/events/nba_logo.png', 'https://cdn.sportstream.com/events/nba_banner.jpg', true),
    ('NBA Playoffs 2025', 'NBA Playoffs', basketball_sport_id, '2025-04-16 00:00:00+00', '2025-06-30 23:59:59+00', 'USA/Canada', 'NBA', 'https://cdn.sportstream.com/events/nba_playoffs_logo.png', 'https://cdn.sportstream.com/events/nba_playoffs_banner.jpg', true),
    
    -- American Football Events
    ('NFL Regular Season 2024', 'NFL Regular Season', american_football_sport_id, '2024-09-05 00:00:00+00', '2025-01-05 23:59:59+00', 'USA', 'NFL', 'https://cdn.sportstream.com/events/nfl_logo.png', 'https://cdn.sportstream.com/events/nfl_banner.jpg', true),
    ('NFL Playoffs 2025', 'NFL Playoffs leading to Super Bowl', american_football_sport_id, '2025-01-11 00:00:00+00', '2025-02-09 23:59:59+00', 'USA', 'NFL', 'https://cdn.sportstream.com/events/nfl_playoffs_logo.png', 'https://cdn.sportstream.com/events/nfl_playoffs_banner.jpg', true),
    
    -- Tennis Events
    ('Australian Open 2025', 'Australian Open Grand Slam', tennis_sport_id, '2025-01-13 00:00:00+00', '2025-01-26 23:59:59+00', 'Melbourne, Australia', 'Tennis Australia', 'https://cdn.sportstream.com/events/ausopen_logo.png', 'https://cdn.sportstream.com/events/ausopen_banner.jpg', true),
    ('Wimbledon 2025', 'The Championships, Wimbledon', tennis_sport_id, '2025-06-23 00:00:00+00', '2025-07-06 23:59:59+00', 'London, England', 'All England Club', 'https://cdn.sportstream.com/events/wimbledon_logo.png', 'https://cdn.sportstream.com/events/wimbledon_banner.jpg', true),
    
    -- Formula 1 Events
    ('Formula 1 World Championship 2024', 'F1 World Championship Season', formula1_sport_id, '2024-03-01 00:00:00+00', '2024-12-08 23:59:59+00', 'Worldwide', 'FIA', 'https://cdn.sportstream.com/events/f1_logo.png', 'https://cdn.sportstream.com/events/f1_banner.jpg', true);
END $$;

-- =====================================================
-- COMPREHENSIVE MATCHES DATA WITH VARIOUS STATUSES
-- =====================================================

DO $$
DECLARE
    premier_league_id UUID;
    serie_a_id UUID;
    bundesliga_id UUID;
    champions_league_id UUID;
    nba_id UUID;
    nfl_id UUID;
    football_sport_id UUID;
    basketball_sport_id UUID;
    american_football_sport_id UUID;
BEGIN
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    SELECT sport_id INTO basketball_sport_id FROM sports WHERE name = 'basketball';
    SELECT sport_id INTO american_football_sport_id FROM sports WHERE name = 'american_football';
    
    SELECT event_id INTO premier_league_id FROM events WHERE name = 'Premier League 2024/25';
    SELECT event_id INTO serie_a_id FROM events WHERE name = 'Serie A 2024/25';
    SELECT event_id INTO bundesliga_id FROM events WHERE name = 'Bundesliga 2024/25';
    SELECT event_id INTO champions_league_id FROM events WHERE name = 'UEFA Champions League 2024/25';
    SELECT event_id INTO nba_id FROM events WHERE name = 'NBA Regular Season 2024/25';
    SELECT event_id INTO nfl_id FROM events WHERE name = 'NFL Regular Season 2024';
    
    -- More Premier League matches with different statuses
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, end_time, venue, competition, stream_url, viewer_count, is_featured, is_trending, thumbnail_url) VALUES
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'Newcastle United'), (SELECT team_id FROM teams WHERE name = 'Brighton & Hove Albion'), football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '2 hours', 'St. James Park', 'Premier League', 'https://stream.example.com/newcastle_brighton', 8750, false, false, '/api/placeholder/400/225'),
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'West Ham United'), (SELECT team_id FROM teams WHERE name = 'Crystal Palace'), football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '2 days', NULL, 'London Stadium', 'Premier League', 'https://stream.example.com/westham_palace', 0, false, false, '/api/placeholder/400/225'),
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'Aston Villa'), (SELECT team_id FROM teams WHERE name = 'Fulham'), football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '4 days', NULL, 'Villa Park', 'Premier League', 'https://stream.example.com/villa_fulham', 0, true, false, '/api/placeholder/400/225');
    
    -- Serie A matches
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, thumbnail_url) VALUES
    (serie_a_id, (SELECT team_id FROM teams WHERE name = 'Juventus'), (SELECT team_id FROM teams WHERE name = 'AC Milan'), football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '3 days 20 hours', 'Allianz Stadium', 'Serie A', 'https://stream.example.com/juventus_milan', 0, true, '/api/placeholder/400/225'),
    (serie_a_id, (SELECT team_id FROM teams WHERE name = 'Inter Milan'), (SELECT team_id FROM teams WHERE name = 'Napoli'), football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '5 days 14 hours', 'San Siro', 'Serie A', 'https://stream.example.com/inter_napoli', 0, true, '/api/placeholder/400/225');
    
    -- Bundesliga matches
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, thumbnail_url) VALUES
    (bundesliga_id, (SELECT team_id FROM teams WHERE name = 'Bayern Munich'), (SELECT team_id FROM teams WHERE name = 'Borussia Dortmund'), football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '6 days 15 hours 30 minutes', 'Allianz Arena', 'Bundesliga', 'https://stream.example.com/bayern_dortmund', 0, true, '/api/placeholder/400/225'),
    (bundesliga_id, (SELECT team_id FROM teams WHERE name = 'RB Leipzig'), (SELECT team_id FROM teams WHERE name = 'Bayer Leverkusen'), football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Red Bull Arena', 'Bundesliga', 'https://stream.example.com/leipzig_leverkusen', 6500, false, false, '/api/placeholder/400/225');
    
    -- NBA matches
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, is_trending, thumbnail_url) VALUES
    (nba_id, (SELECT team_id FROM teams WHERE name = 'Los Angeles Lakers'), (SELECT team_id FROM teams WHERE name = 'Boston Celtics'), basketball_sport_id, 'live', CURRENT_TIMESTAMP - INTERVAL '45 minutes', 'Crypto.com Arena', 'NBA', 'https://stream.example.com/lakers_celtics', 24500, true, true, '/api/placeholder/400/225'),
    (nba_id, (SELECT team_id FROM teams WHERE name = 'Golden State Warriors'), (SELECT team_id FROM teams WHERE name = 'Miami Heat'), basketball_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '1 day 2 hours', 'Chase Center', 'NBA', 'https://stream.example.com/warriors_heat', 0, true, false, '/api/placeholder/400/225'),
    (nba_id, (SELECT team_id FROM teams WHERE name = 'Chicago Bulls'), (SELECT team_id FROM teams WHERE name = 'New York Knicks'), basketball_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '18 hours', 'United Center', 'NBA', 'https://stream.example.com/bulls_knicks', 15200, false, false, '/api/placeholder/400/225');
    
    -- NFL matches
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, venue, competition, stream_url, viewer_count, is_featured, is_trending, thumbnail_url) VALUES
    (nfl_id, (SELECT team_id FROM teams WHERE name = 'New England Patriots'), (SELECT team_id FROM teams WHERE name = 'Dallas Cowboys'), american_football_sport_id, 'scheduled', CURRENT_TIMESTAMP + INTERVAL '3 days 20 hours', 'Gillette Stadium', 'NFL', 'https://stream.example.com/patriots_cowboys', 0, true, false, '/api/placeholder/400/225'),
    (nfl_id, (SELECT team_id FROM teams WHERE name = 'Green Bay Packers'), (SELECT team_id FROM teams WHERE name = 'Kansas City Chiefs'), american_football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '3 days', 'Lambeau Field', 'NFL', 'https://stream.example.com/packers_chiefs', 32000, true, false, '/api/placeholder/400/225');
END $$;

-- =====================================================
-- COMPREHENSIVE MATCH SCORES FOR VARIOUS SPORTS
-- =====================================================

DO $$
DECLARE
    lakers_celtics_match_id UUID;
    bulls_knicks_match_id UUID;
    packers_chiefs_match_id UUID;
    leipzig_leverkusen_match_id UUID;
    newcastle_brighton_match_id UUID;
BEGIN
    SELECT match_id INTO lakers_celtics_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'Los Angeles Lakers' AND at.name = 'Boston Celtics';
    
    SELECT match_id INTO bulls_knicks_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'Chicago Bulls' AND at.name = 'New York Knicks';
    
    SELECT match_id INTO packers_chiefs_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'Green Bay Packers' AND at.name = 'Kansas City Chiefs';
    
    SELECT match_id INTO leipzig_leverkusen_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'RB Leipzig' AND at.name = 'Bayer Leverkusen';
    
    SELECT match_id INTO newcastle_brighton_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'Newcastle United' AND at.name = 'Brighton & Hove Albion';
    
    -- Basketball scores (live game)
    INSERT INTO match_scores (match_id, home_score, away_score, period_scores, match_time) VALUES
    (lakers_celtics_match_id, 89, 82, '[{"quarter": 1, "home": 28, "away": 24}, {"quarter": 2, "home": 23, "away": 19}, {"quarter": 3, "home": 25, "away": 22}, {"quarter": 4, "home": 13, "away": 17}]', 'Q4 3:45');
    
    -- Basketball finished game
    INSERT INTO match_scores (match_id, home_score, away_score, period_scores, match_time) VALUES
    (bulls_knicks_match_id, 108, 115, '[{"quarter": 1, "home": 25, "away": 30}, {"quarter": 2, "home": 27, "away": 28}, {"quarter": 3, "home": 29, "away": 25}, {"quarter": 4, "home": 27, "away": 32}]', 'Final');
    
    -- NFL finished game
    INSERT INTO match_scores (match_id, home_score, away_score, period_scores, match_time) VALUES
    (packers_chiefs_match_id, 21, 28, '[{"quarter": 1, "home": 0, "away": 7}, {"quarter": 2, "home": 14, "away": 7}, {"quarter": 3, "home": 7, "away": 7}, {"quarter": 4, "home": 0, "away": 7}]', 'Final');
    
    -- Football finished games
    INSERT INTO match_scores (match_id, home_score, away_score, match_time) VALUES
    (leipzig_leverkusen_match_id, 2, 1, 'Full Time'),
    (newcastle_brighton_match_id, 3, 0, 'Full Time');
END $$;

-- =====================================================
-- COMPREHENSIVE MATCH EVENTS FOR DIFFERENT SPORTS
-- =====================================================

DO $$
DECLARE
    lakers_celtics_match_id UUID;
    leipzig_leverkusen_match_id UUID;
    packers_chiefs_match_id UUID;
    lakers_team_id UUID;
    celtics_team_id UUID;
    leipzig_team_id UUID;
    leverkusen_team_id UUID;
    packers_team_id UUID;
    chiefs_team_id UUID;
BEGIN
    SELECT team_id INTO lakers_team_id FROM teams WHERE name = 'Los Angeles Lakers';
    SELECT team_id INTO celtics_team_id FROM teams WHERE name = 'Boston Celtics';
    SELECT team_id INTO leipzig_team_id FROM teams WHERE name = 'RB Leipzig';
    SELECT team_id INTO leverkusen_team_id FROM teams WHERE name = 'Bayer Leverkusen';
    SELECT team_id INTO packers_team_id FROM teams WHERE name = 'Green Bay Packers';
    SELECT team_id INTO chiefs_team_id FROM teams WHERE name = 'Kansas City Chiefs';
    
    SELECT match_id INTO lakers_celtics_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Los Angeles Lakers';
    
    SELECT match_id INTO leipzig_leverkusen_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'RB Leipzig';
    
    SELECT match_id INTO packers_chiefs_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Green Bay Packers';
    
    -- Basketball events (Lakers vs Celtics - Live)
    INSERT INTO match_events (match_id, event_type, minute, team_id, player_name, description, details, impact) VALUES
    (lakers_celtics_match_id, 'basket', 3, lakers_team_id, 'LeBron James', '3-pointer', 'Three-point shot from the top of the arc', 'high'),
    (lakers_celtics_match_id, 'basket', 7, celtics_team_id, 'Jayson Tatum', 'Dunk', 'Powerful slam dunk', 'high'),
    (lakers_celtics_match_id, 'foul', 12, lakers_team_id, 'Anthony Davis', 'Personal Foul', 'Blocking foul on Jaylen Brown', 'medium'),
    (lakers_celtics_match_id, 'basket', 18, celtics_team_id, 'Marcus Smart', 'Free Throw', 'Made 1 of 2 free throws', 'low'),
    (lakers_celtics_match_id, 'timeout', 25, lakers_team_id, 'Darvin Ham', 'Timeout', 'Coach timeout called', 'low'),
    (lakers_celtics_match_id, 'basket', 31, lakers_team_id, 'Russell Westbrook', '2-pointer', 'Mid-range jumper', 'medium'),
    (lakers_celtics_match_id, 'substitution', 36, celtics_team_id, 'Robert Williams III', 'Substitution', 'Robert Williams III in for Al Horford', 'low');
    
    -- Football events (Leipzig vs Leverkusen - Finished)
    INSERT INTO match_events (match_id, event_type, minute, team_id, player_name, description, details, impact) VALUES
    (leipzig_leverkusen_match_id, 'goal', 23, leipzig_team_id, 'Christopher Nkunku', 'Goal', 'Left footed shot from inside the box', 'high'),
    (leipzig_leverkusen_match_id, 'card', 35, leverkusen_team_id, 'Florian Wirtz', 'Yellow Card', 'Unsporting behavior', 'medium'),
    (leipzig_leverkusen_match_id, 'goal', 58, leverkusen_team_id, 'Patrik Schick', 'Goal', 'Header from 6 yard box', 'high'),
    (leipzig_leverkusen_match_id, 'substitution', 67, leipzig_team_id, 'Timo Werner', 'Substitution', 'Timo Werner replaces Dani Olmo', 'low'),
    (leipzig_leverkusen_match_id, 'goal', 84, leipzig_team_id, 'Emil Forsberg', 'Goal', 'Right footed shot from outside the box', 'high'),
    (leipzig_leverkusen_match_id, 'card', 90, leipzig_team_id, 'Willi Orban', 'Yellow Card', 'Time wasting', 'low');
    
    -- American Football events (Packers vs Chiefs - Finished)
    INSERT INTO match_events (match_id, event_type, minute, team_id, player_name, description, details, impact) VALUES
    (packers_chiefs_match_id, 'touchdown', 8, chiefs_team_id, 'Patrick Mahomes', 'Touchdown Pass', '15-yard touchdown pass to Travis Kelce', 'high'),
    (packers_chiefs_match_id, 'touchdown', 23, packers_team_id, 'Aaron Rodgers', 'Touchdown Pass', '8-yard touchdown pass to Davante Adams', 'high'),
    (packers_chiefs_match_id, 'field_goal', 31, packers_team_id, 'Mason Crosby', 'Field Goal', '35-yard field goal', 'medium'),
    (packers_chiefs_match_id, 'touchdown', 45, chiefs_team_id, 'Clyde Edwards-Helaire', 'Rushing Touchdown', '3-yard rushing touchdown', 'high'),
    (packers_chiefs_match_id, 'touchdown', 52, packers_team_id, 'Aaron Jones', 'Rushing Touchdown', '12-yard rushing touchdown', 'high'),
    (packers_chiefs_match_id, 'touchdown', 67, chiefs_team_id, 'Tyreek Hill', 'Touchdown Reception', '42-yard touchdown reception', 'high');
END $$;

-- =====================================================
-- COMPREHENSIVE MATCH STATISTICS
-- =====================================================

DO $$
DECLARE
    lakers_celtics_match_id UUID;
    leipzig_leverkusen_match_id UUID;
BEGIN
    SELECT match_id INTO lakers_celtics_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Los Angeles Lakers';
    
    SELECT match_id INTO leipzig_leverkusen_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'RB Leipzig';
    
    -- Basketball statistics (Lakers vs Celtics)
    INSERT INTO match_statistics (match_id, stat_type, home_value, away_value, home_display, away_display) VALUES
    (lakers_celtics_match_id, 'field_goal_percentage', 48, 52, '48%', '52%'),
    (lakers_celtics_match_id, 'three_point_percentage', 35, 42, '35%', '42%'),
    (lakers_celtics_match_id, 'free_throw_percentage', 78, 83, '78%', '83%'),
    (lakers_celtics_match_id, 'rebounds', 42, 38, '42', '38'),
    (lakers_celtics_match_id, 'assists', 26, 29, '26', '29'),
    (lakers_celtics_match_id, 'steals', 8, 6, '8', '6'),
    (lakers_celtics_match_id, 'blocks', 5, 3, '5', '3'),
    (lakers_celtics_match_id, 'turnovers', 12, 15, '12', '15');
    
    -- Football statistics (Leipzig vs Leverkusen)
    INSERT INTO match_statistics (match_id, stat_type, home_value, away_value, home_display, away_display) VALUES
    (leipzig_leverkusen_match_id, 'possession', 62, 38, '62%', '38%'),
    (leipzig_leverkusen_match_id, 'shots', 18, 11, '18', '11'),
    (leipzig_leverkusen_match_id, 'shots_on_target', 8, 4, '8', '4'),
    (leipzig_leverkusen_match_id, 'corners', 9, 3, '9', '3'),
    (leipzig_leverkusen_match_id, 'fouls', 13, 16, '13', '16'),
    (leipzig_leverkusen_match_id, 'offsides', 2, 4, '2', '4'),
    (leipzig_leverkusen_match_id, 'yellow_cards', 1, 1, '1', '1'),
    (leipzig_leverkusen_match_id, 'passes', 548, 312, '548', '312'),
    (leipzig_leverkusen_match_id, 'pass_accuracy', 87, 78, '87%', '78%');
END $$;

-- =====================================================
-- ADDITIONAL USER DATA FOR TESTING
-- =====================================================

DO $$
DECLARE
    user_ids UUID[] := ARRAY[uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4(), uuid_generate_v4()];
    basketball_sport_id UUID;
    american_football_sport_id UUID;
BEGIN
    SELECT sport_id INTO basketball_sport_id FROM sports WHERE name = 'basketball';
    SELECT sport_id INTO american_football_sport_id FROM sports WHERE name = 'american_football';
    
    -- Create additional test users with varied profiles
    INSERT INTO users (user_id, email, username, password_hash, full_name, avatar_url, role) VALUES
    (user_ids[1], 'basketballfan@example.com', 'BasketballFan92', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Michael Johnson', 'https://cdn.sportstream.com/avatars/user1.png', 'user'),
    (user_ids[2], 'nflfanatic@example.com', 'NFLFanatic', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Sarah Williams', 'https://cdn.sportstream.com/avatars/user2.png', 'user'),
    (user_ids[3], 'sportsmoderator@example.com', 'SportsMod', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'David Brown', 'https://cdn.sportstream.com/avatars/user3.png', 'moderator'),
    (user_ids[4], 'casualviewer@example.com', 'CasualViewer', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Emma Davis', 'https://cdn.sportstream.com/avatars/user4.png', 'user'),
    (user_ids[5], 'seriafan@example.com', 'SeriaAFan', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Marco Rossi', 'https://cdn.sportstream.com/avatars/user5.png', 'user'),
    (user_ids[6], 'bundesligafan@example.com', 'BundesligaFan', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Hans Mueller', 'https://cdn.sportstream.com/avatars/user6.png', 'user'),
    (user_ids[7], 'allsports@example.com', 'AllSportsLover', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Alex Thompson', 'https://cdn.sportstream.com/avatars/user7.png', 'user'),
    (user_ids[8], 'inactivefan@example.com', 'InactiveFan', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Inactive User', 'https://cdn.sportstream.com/avatars/user8.png', 'user');
    
    -- Set one user as inactive
    UPDATE users SET is_active = false WHERE user_id = user_ids[8];
    
    -- Create user preferences with varied interests
    INSERT INTO user_preferences (user_id, favorite_teams, favorite_sports, notification_settings, preferred_language, timezone) VALUES
    (user_ids[1], '{"Los Angeles Lakers", "Golden State Warriors"}', '{"basketball"}', '{"match_start": true, "scores": true, "highlights": true}', 'en', 'America/Los_Angeles'),
    (user_ids[2], '{"New England Patriots", "Dallas Cowboys"}', '{"american_football"}', '{"match_start": true, "touchdowns": true, "final_score": true}', 'en', 'America/New_York'),
    (user_ids[3], '{"Arsenal", "Liverpool", "Manchester City"}', '{"football"}', '{"match_start": true, "goals": true, "cards": true, "final_score": true}', 'en', 'Europe/London'),
    (user_ids[4], '{"Chelsea"}', '{"football"}', '{"goals": true}', 'en', 'UTC'),
    (user_ids[5], '{"Juventus", "AC Milan", "Inter Milan"}', '{"football"}', '{"match_start": true, "goals": true, "final_score": true}', 'it', 'Europe/Rome'),
    (user_ids[6], '{"Bayern Munich", "Borussia Dortmund"}', '{"football"}', '{"match_start": true, "goals": true, "cards": true}', 'de', 'Europe/Berlin'),
    (user_ids[7], '{"Arsenal", "Los Angeles Lakers", "New England Patriots"}', '{"football", "basketball", "american_football"}', '{"match_start": true, "goals": true, "scores": true, "highlights": true}', 'en', 'UTC');
END $$;

-- =====================================================
-- COMPREHENSIVE HIGHLIGHTS DATA
-- =====================================================

DO $$
DECLARE
    lakers_celtics_match_id UUID;
    bulls_knicks_match_id UUID;
    packers_chiefs_match_id UUID;
    leipzig_leverkusen_match_id UUID;
BEGIN
    SELECT match_id INTO lakers_celtics_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Los Angeles Lakers';
    
    SELECT match_id INTO bulls_knicks_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Chicago Bulls';
    
    SELECT match_id INTO packers_chiefs_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Green Bay Packers';
    
    SELECT match_id INTO leipzig_leverkusen_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'RB Leipzig';
    
    -- Basketball highlights
    INSERT INTO highlights (match_id, title, description, video_url, thumbnail_url, duration, tags, view_count, is_featured) VALUES
    (lakers_celtics_match_id, 'LeBron James Amazing 3-Pointer', 'LeBron drains a deep three from the logo', 'https://highlights.sportstream.com/lebron_three.mp4', 'https://thumbnails.sportstream.com/lebron_three.jpg', 25, '{"basketball", "lebron", "three-pointer", "lakers"}', 3450, true),
    (lakers_celtics_match_id, 'Jayson Tatum Thunderous Dunk', 'Tatum with a powerful slam dunk over defenders', 'https://highlights.sportstream.com/tatum_dunk.mp4', 'https://thumbnails.sportstream.com/tatum_dunk.jpg', 18, '{"basketball", "tatum", "dunk", "celtics"}', 2890, false),
    (bulls_knicks_match_id, 'Fourth Quarter Comeback', 'Knicks amazing 4th quarter rally to win the game', 'https://highlights.sportstream.com/knicks_comeback.mp4', 'https://thumbnails.sportstream.com/knicks_comeback.jpg', 180, '{"basketball", "knicks", "comeback", "fourth-quarter"}', 5670, true),
    
    -- Football highlights
    (leipzig_leverkusen_match_id, 'Nkunku Opening Goal', 'Christopher Nkunku opens the scoring with a brilliant finish', 'https://highlights.sportstream.com/nkunku_goal.mp4', 'https://thumbnails.sportstream.com/nkunku_goal.jpg', 35, '{"football", "nkunku", "goal", "leipzig"}', 1890, false),
    (leipzig_leverkusen_match_id, 'Forsberg Winner', 'Emil Forsberg scores the winner with a stunning long-range effort', 'https://highlights.sportstream.com/forsberg_winner.mp4', 'https://thumbnails.sportstream.com/forsberg_winner.jpg', 42, '{"football", "forsberg", "goal", "winner", "long-range"}', 2340, true),
    
    -- American Football highlights
    (packers_chiefs_match_id, 'Mahomes to Kelce Touchdown', 'Patrick Mahomes finds Travis Kelce for the touchdown', 'https://highlights.sportstream.com/mahomes_kelce_td.mp4', 'https://thumbnails.sportstream.com/mahomes_kelce_td.jpg', 28, '{"nfl", "mahomes", "kelce", "touchdown", "chiefs"}', 7890, true),
    (packers_chiefs_match_id, 'Tyreek Hill Long Touchdown', 'Tyreek Hill burns the defense for a 42-yard touchdown', 'https://highlights.sportstream.com/hill_long_td.mp4', 'https://thumbnails.sportstream.com/hill_long_td.jpg', 32, '{"nfl", "hill", "touchdown", "long", "speed"}', 6540, true);
END $$;

-- =====================================================
-- COMPREHENSIVE EMOJI REACTIONS AND CHAT DATA
-- =====================================================

DO $$
DECLARE
    premier_league_id UUID;
    nba_id UUID;
    nfl_id UUID;
    arsenal_chelsea_match_id UUID;
    lakers_celtics_match_id UUID;
    packers_chiefs_match_id UUID;
    user_ids UUID[];
    emoji_ids UUID[];
BEGIN
    SELECT event_id INTO premier_league_id FROM events WHERE name = 'Premier League 2024/25';
    SELECT event_id INTO nba_id FROM events WHERE name = 'NBA Regular Season 2024/25';
    SELECT event_id INTO nfl_id FROM events WHERE name = 'NFL Regular Season 2024';
    
    SELECT match_id INTO arsenal_chelsea_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    JOIN teams at ON m.away_team_id = at.team_id 
    WHERE ht.name = 'Arsenal' AND at.name = 'Chelsea';
    
    SELECT match_id INTO lakers_celtics_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Los Angeles Lakers';
    
    SELECT match_id INTO packers_chiefs_match_id FROM matches m 
    JOIN teams ht ON m.home_team_id = ht.team_id 
    WHERE ht.name = 'Green Bay Packers';
    
    SELECT array_agg(user_id) INTO user_ids FROM users WHERE role = 'user' AND is_active = true LIMIT 6;
    SELECT array_agg(emoji_id) INTO emoji_ids FROM emoji_assets WHERE is_active = true;
    
    -- More diverse emoji reactions across different matches
    INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id) 
    SELECT 
        user_ids[1 + (random() * (array_length(user_ids, 1) - 1))::int],
        premier_league_id,
        arsenal_chelsea_match_id,
        emoji_ids[1 + (random() * (array_length(emoji_ids, 1) - 1))::int]
    FROM generate_series(1, 50);
    
    INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id) 
    SELECT 
        user_ids[1 + (random() * (array_length(user_ids, 1) - 1))::int],
        nba_id,
        lakers_celtics_match_id,
        emoji_ids[1 + (random() * (array_length(emoji_ids, 1) - 1))::int]
    FROM generate_series(1, 75);
    
    -- Chat messages for different matches
    INSERT INTO chat_messages (event_id, match_id, user_id, message) VALUES
    (nba_id, lakers_celtics_match_id, user_ids[1], 'LeBron is still the king! 👑'),
    (nba_id, lakers_celtics_match_id, user_ids[2], 'Tatum is playing amazing tonight'),
    (nba_id, lakers_celtics_match_id, user_ids[3], 'This is going to be a classic game!'),
    (nba_id, lakers_celtics_match_id, user_ids[4], 'Defense needs to step up'),
    (nba_id, lakers_celtics_match_id, user_ids[5], 'What a shot by LeBron! 🔥'),
    (premier_league_id, arsenal_chelsea_match_id, user_ids[1], 'Arsenal playing with great intensity'),
    (premier_league_id, arsenal_chelsea_match_id, user_ids[2], 'Chelsea needs more creativity in midfield'),
    (premier_league_id, arsenal_chelsea_match_id, user_ids[3], 'This referee is making questionable calls'),
    (premier_league_id, arsenal_chelsea_match_id, user_ids[4], 'Loving this pace of the game!');
END $$;

-- =====================================================
-- COMPREHENSIVE VIEWER DATA
-- =====================================================

DO $$
DECLARE
    match_ids UUID[];
    user_ids UUID[];
    i INTEGER;
BEGIN
    SELECT array_agg(match_id) INTO match_ids FROM matches WHERE status IN ('live', 'finished') LIMIT 10;
    SELECT array_agg(user_id) INTO user_ids FROM users WHERE is_active = true;
    
    -- Generate viewer sessions for multiple matches
    FOR i IN 1..100 LOOP
        INSERT INTO viewer_sessions (
            user_id, 
            match_id, 
            ip_address,
            user_agent,
            join_time, 
            leave_time,
            duration,
            quality_watched
        ) VALUES (
            CASE WHEN random() < 0.7 THEN user_ids[1 + (random() * (array_length(user_ids, 1) - 1))::int] ELSE NULL END,
            match_ids[1 + (random() * (array_length(match_ids, 1) - 1))::int],
            ('192.168.' || floor(random() * 255) || '.' || floor(random() * 255))::inet,
            CASE floor(random() * 4)
                WHEN 0 THEN 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                WHEN 1 THEN 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
                WHEN 2 THEN 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15'
                ELSE 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36'
            END,
            CURRENT_TIMESTAMP - INTERVAL '1 hour' - (random() * INTERVAL '3 hours'),
            CASE WHEN random() < 0.8 THEN CURRENT_TIMESTAMP - INTERVAL '30 minutes' - (random() * INTERVAL '2 hours') ELSE NULL END,
            CASE WHEN random() < 0.8 THEN (30 + random() * 120)::int ELSE NULL END,
            CASE floor(random() * 5)
                WHEN 0 THEN '4K'
                WHEN 1 THEN 'HD'
                WHEN 2 THEN '720p'
                WHEN 3 THEN '480p'
                ELSE 'Auto'
            END
        );
    END LOOP;
    
    -- Generate viewer count snapshots for active matches
    INSERT INTO viewer_count_snapshots (match_id, viewer_count, timestamp)
    SELECT 
        match_id,
        (5000 + random() * 25000)::int,
        CURRENT_TIMESTAMP - (random() * INTERVAL '2 hours')
    FROM matches 
    WHERE status = 'live';
END $$;

-- =====================================================
-- STREAM QUALITIES FOR ALL MATCHES
-- =====================================================

DO $$
DECLARE
    match_record RECORD;
BEGIN
    FOR match_record IN SELECT match_id FROM matches WHERE stream_url IS NOT NULL LOOP
        INSERT INTO stream_qualities (match_id, quality_name, stream_url, bitrate, resolution, is_default) VALUES
        (match_record.match_id, '4K', replace(stream_url, 'https://stream.example.com/', 'https://stream.example.com/4k/'), 15000, '3840x2160', false),
        (match_record.match_id, 'HD', replace(stream_url, 'https://stream.example.com/', 'https://stream.example.com/hd/'), 8000, '1920x1080', false),
        (match_record.match_id, '720p', replace(stream_url, 'https://stream.example.com/', 'https://stream.example.com/720p/'), 4000, '1280x720', true),
        (match_record.match_id, '480p', replace(stream_url, 'https://stream.example.com/', 'https://stream.example.com/480p/'), 2000, '854x480', false),
        (match_record.match_id, 'Auto', replace(stream_url, 'https://stream.example.com/', 'https://stream.example.com/auto/'), 0, 'adaptive', false)
        FROM matches WHERE match_id = match_record.match_id;
    END LOOP;
END $$;

-- =====================================================
-- UPDATE STATISTICS AND FINAL DATA CONSISTENCY
-- =====================================================

-- Update match viewer counts based on actual viewer sessions
UPDATE matches SET viewer_count = (
    SELECT COUNT(*) 
    FROM viewer_sessions vs 
    WHERE vs.match_id = matches.match_id 
    AND vs.leave_time IS NULL
) WHERE status = 'live';

-- Update emoji reaction summary with accurate counts
INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count, last_updated)
SELECT 
    er.event_id,
    er.match_id,
    er.emoji_id,
    COUNT(*),
    MAX(er.created_at)
FROM emoji_reactions er
GROUP BY er.event_id, er.match_id, er.emoji_id
ON CONFLICT (event_id, match_id, emoji_id) 
DO UPDATE SET 
    reaction_count = EXCLUDED.reaction_count,
    last_updated = EXCLUDED.last_updated;

-- Add some finished matches with older dates for historical data
DO $$
DECLARE
    premier_league_id UUID;
    football_sport_id UUID;
BEGIN
    SELECT event_id INTO premier_league_id FROM events WHERE name = 'Premier League 2024/25';
    SELECT sport_id INTO football_sport_id FROM sports WHERE name = 'football';
    
    INSERT INTO matches (event_id, home_team_id, away_team_id, sport_id, status, start_time, end_time, venue, competition, viewer_count, is_featured, thumbnail_url) VALUES
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'Manchester United'), (SELECT team_id FROM teams WHERE name = 'Liverpool'), football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '1 week', CURRENT_TIMESTAMP - INTERVAL '1 week' + INTERVAL '2 hours', 'Old Trafford', 'Premier League', 28500, true, '/api/placeholder/400/225'),
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'Manchester City'), (SELECT team_id FROM teams WHERE name = 'Arsenal'), football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '2 hours', 'Etihad Stadium', 'Premier League', 31200, true, '/api/placeholder/400/225'),
    (premier_league_id, (SELECT team_id FROM teams WHERE name = 'Tottenham'), (SELECT team_id FROM teams WHERE name = 'Chelsea'), football_sport_id, 'finished', CURRENT_TIMESTAMP - INTERVAL '2 weeks', CURRENT_TIMESTAMP - INTERVAL '2 weeks' + INTERVAL '2 hours', 'Tottenham Hotspur Stadium', 'Premier League', 22800, false, '/api/placeholder/400/225');
END $$;

COMMIT;

-- =====================================================
-- VERIFICATION QUERIES (Optional - for testing)
-- =====================================================

-- Uncomment these to verify data was inserted correctly
-- SELECT 'Sports Count: ' || COUNT(*) FROM sports;
-- SELECT 'Teams Count: ' || COUNT(*) FROM teams;
-- SELECT 'Events Count: ' || COUNT(*) FROM events;
-- SELECT 'Matches Count: ' || COUNT(*) FROM matches;
-- SELECT 'Users Count: ' || COUNT(*) FROM users;
-- SELECT 'Match Events Count: ' || COUNT(*) FROM match_events;
-- SELECT 'Highlights Count: ' || COUNT(*) FROM highlights;
-- SELECT 'Chat Messages Count: ' || COUNT(*) FROM chat_messages;
-- SELECT 'Emoji Reactions Count: ' || COUNT(*) FROM emoji_reactions;
-- SELECT 'Viewer Sessions Count: ' || COUNT(*) FROM viewer_sessions;
