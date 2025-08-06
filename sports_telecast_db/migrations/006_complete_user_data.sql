-- Complete User Data and Emoji Reactions - Fixed
-- This script completes the data loading with proper conflict handling

DO $$
DECLARE
    user1_id UUID := uuid_generate_v4();
    user2_id UUID := uuid_generate_v4();
    user3_id UUID := uuid_generate_v4();
    user4_id UUID := uuid_generate_v4();
    premier_league_id UUID;
    match1_id UUID;
    match2_id UUID;
    emoji1_id UUID;
    emoji2_id UUID;
    emoji3_id UUID;
    emoji4_id UUID;
    emoji5_id UUID;
    emoji6_id UUID;
BEGIN
    -- Get event and match IDs
    SELECT event_id INTO premier_league_id FROM events WHERE name = 'Premier League 2024/25';
    SELECT match_id INTO match1_id FROM matches WHERE venue = 'Emirates Stadium';
    SELECT match_id INTO match2_id FROM matches WHERE venue = 'Anfield';
    
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
    -- These will automatically trigger the summary update through triggers
    INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id) VALUES
    (user2_id, premier_league_id, match1_id, emoji1_id), -- love
    (user2_id, premier_league_id, match1_id, emoji4_id), -- clap
    (user3_id, premier_league_id, match1_id, emoji2_id), -- laugh
    (user4_id, premier_league_id, match1_id, emoji1_id), -- love
    (user4_id, premier_league_id, match1_id, emoji5_id), -- fire
    (user2_id, premier_league_id, match1_id, emoji6_id), -- goal
    (user3_id, premier_league_id, match1_id, emoji3_id), -- shocked
    (user4_id, premier_league_id, match1_id, emoji4_id), -- clap
    (user2_id, premier_league_id, match1_id, emoji5_id), -- fire
    (user3_id, premier_league_id, match1_id, emoji1_id); -- love

    -- Sample chat messages
    INSERT INTO chat_messages (event_id, match_id, user_id, message) VALUES
    (premier_league_id, match1_id, user2_id, 'Great goal by Arsenal! 🔥'),
    (premier_league_id, match1_id, user3_id, 'Chelsea needs to step up their game'),
    (premier_league_id, match1_id, user4_id, 'This match is incredible!'),
    (premier_league_id, match1_id, user2_id, 'Arsenal looking strong today'),
    (premier_league_id, match2_id, user3_id, 'Liverpool vs City is always a classic!'),
    (premier_league_id, match2_id, user4_id, 'Amazing atmosphere at Anfield');

    -- Current viewer sessions for the live matches
    INSERT INTO viewer_sessions (user_id, match_id, join_time, quality_watched) VALUES
    (user2_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '30 minutes', '720p'),
    (user3_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '45 minutes', 'HD'),
    (user4_id, match1_id, CURRENT_TIMESTAMP - INTERVAL '20 minutes', '720p'),
    (user2_id, match2_id, CURRENT_TIMESTAMP - INTERVAL '35 minutes', 'HD'),
    (user3_id, match2_id, CURRENT_TIMESTAMP - INTERVAL '25 minutes', '720p');

    -- Viewer count snapshots (historical data)
    INSERT INTO viewer_count_snapshots (match_id, viewer_count) VALUES
    (match1_id, 12847),
    (match2_id, 18500);

    -- Update emoji reaction summary with realistic counts
    -- First, manually add more realistic counts (beyond what triggers created)
    UPDATE emoji_reaction_summary SET reaction_count = 342 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji1_id;
    UPDATE emoji_reaction_summary SET reaction_count = 128 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji2_id;
    UPDATE emoji_reaction_summary SET reaction_count = 89 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji3_id;
    UPDATE emoji_reaction_summary SET reaction_count = 205 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji4_id;
    UPDATE emoji_reaction_summary SET reaction_count = 167 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji5_id;
    UPDATE emoji_reaction_summary SET reaction_count = 95 WHERE event_id = premier_league_id AND match_id = match1_id AND emoji_id = emoji6_id;

    -- Add emoji reactions for the second match as well
    INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count) VALUES
    (premier_league_id, match2_id, emoji1_id, 456),
    (premier_league_id, match2_id, emoji2_id, 234),
    (premier_league_id, match2_id, emoji3_id, 178),
    (premier_league_id, match2_id, emoji4_id, 312),
    (premier_league_id, match2_id, emoji5_id, 289),
    (premier_league_id, match2_id, emoji6_id, 156);

END $$;

-- Verify data was inserted correctly
SELECT 'Users inserted: ' || COUNT(*) FROM users;
SELECT 'User preferences inserted: ' || COUNT(*) FROM user_preferences;
SELECT 'Emoji reactions inserted: ' || COUNT(*) FROM emoji_reactions;
SELECT 'Chat messages inserted: ' || COUNT(*) FROM chat_messages;
SELECT 'Viewer sessions inserted: ' || COUNT(*) FROM viewer_sessions;
SELECT 'Emoji reaction summaries: ' || COUNT(*) FROM emoji_reaction_summary;
