-- -- Realistic Mock Data for Sports Telecast Database
-- -- This script inserts comprehensive mock data matching the existing schema

-- BEGIN;

-- -- Clear existing data (except migration history)
-- DELETE FROM user_emoji_reactions;
-- DELETE FROM highlights;
-- DELETE FROM match_events;
-- DELETE FROM matches;
-- DELETE FROM events;
-- DELETE FROM teams;
-- DELETE FROM sports;
-- DELETE FROM users;

-- -- Insert Sports (matching existing table structure)
-- INSERT INTO sports (sport_id, name, display_name, description, is_active, created_at) VALUES
-- ('550e8400-e29b-41d4-a716-446655440001', 'football', 'Football', 'Association Football (Soccer)', true, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440002', 'basketball', 'Basketball', 'Professional Basketball', true, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440003', 'tennis', 'Tennis', 'Professional Tennis', true, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440004', 'cricket', 'Cricket', 'International Cricket', true, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440005', 'rugby', 'Rugby', 'Rugby Union and League', true, NOW());

-- -- Insert Users with correct enum values
-- INSERT INTO users (user_id, email, username, password_hash, full_name, avatar_url, role, is_active, preferences, created_at, updated_at) VALUES
-- ('user-550e8400-e29b-41d4-a716-446655440001', 'john.doe@example.com', 'johndoe', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'John Doe', 'https://cdn.sportstream.com/avatars/john.png', 'USER', true, '{"favorite_teams": ["Arsenal", "Lakers"], "notifications": true}', NOW(), NOW()),
-- ('user-550e8400-e29b-41d4-a716-446655440002', 'jane.smith@example.com', 'janesmith', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Jane Smith', 'https://cdn.sportstream.com/avatars/jane.png', 'USER', true, '{"favorite_teams": ["Chelsea", "Warriors"], "notifications": true}', NOW(), NOW()),
-- ('user-550e8400-e29b-41d4-a716-446655440003', 'admin@example.com', 'admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Admin User', 'https://cdn.sportstream.com/avatars/admin.png', 'ADMIN', true, '{"notifications": true}', NOW(), NOW()),
-- ('user-550e8400-e29b-41d4-a716-446655440004', 'moderator@example.com', 'moderator', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewM1sI2mY9kL8XE6', 'Moderator User', 'https://cdn.sportstream.com/avatars/moderator.png', 'MODERATOR', true, '{"notifications": true}', NOW(), NOW());

-- -- Insert Teams
-- INSERT INTO teams (team_id, name, short_name, logo_url, colors, created_at, updated_at) VALUES
-- -- Premier League Teams
-- ('team-550e8400-e29b-41d4-a716-446655440001', 'Arsenal', 'ARS', 'https://cdn.sportstream.com/logos/arsenal.png', '{"primary": "#EF0107", "secondary": "#FFFFFF"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440002', 'Chelsea', 'CHE', 'https://cdn.sportstream.com/logos/chelsea.png', '{"primary": "#034694", "secondary": "#FFFFFF"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440003', 'Manchester United', 'MUN', 'https://cdn.sportstream.com/logos/manutd.png', '{"primary": "#DA020E", "secondary": "#FBE122"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440004', 'Liverpool', 'LIV', 'https://cdn.sportstream.com/logos/liverpool.png', '{"primary": "#C8102E", "secondary": "#F6EB61"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440005', 'Manchester City', 'MCI', 'https://cdn.sportstream.com/logos/mancity.png', '{"primary": "#6CABDD", "secondary": "#1C2C5B"}', NOW(), NOW()),
-- -- NBA Teams
-- ('team-550e8400-e29b-41d4-a716-446655440006', 'Los Angeles Lakers', 'LAL', 'https://cdn.sportstream.com/logos/lakers.png', '{"primary": "#552583", "secondary": "#FDB927"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440007', 'Golden State Warriors', 'GSW', 'https://cdn.sportstream.com/logos/warriors.png', '{"primary": "#1D428A", "secondary": "#FFC72C"}', NOW(), NOW()),
-- ('team-550e8400-e29b-41d4-a716-446655440008', 'Boston Celtics', 'BOS', 'https://cdn.sportstream.com/logos/celtics.png', '{"primary": "#007A33", "secondary": "#BA9653"}', NOW(), NOW());

-- -- Insert Events
-- INSERT INTO events (event_id, name, description, sport_type, start_date, end_date, location, organizer, logo_url, banner_url, is_featured, created_at, updated_at) VALUES
-- ('event-550e8400-e29b-41d4-a716-446655440001', 'Premier League 2024/25', 'English Premier League Season', 'FOOTBALL', '2024-08-17 00:00:00+00', '2025-05-25 23:59:59+00', 'England', 'Premier League', 'https://cdn.sportstream.com/events/pl_logo.png', 'https://cdn.sportstream.com/events/pl_banner.jpg', true, NOW(), NOW()),
-- ('event-550e8400-e29b-41d4-a716-446655440002', 'NBA Season 2024/25', 'NBA Regular Season', 'BASKETBALL', '2024-10-15 00:00:00+00', '2025-04-15 23:59:59+00', 'USA', 'NBA', 'https://cdn.sportstream.com/events/nba_logo.png', 'https://cdn.sportstream.com/events/nba_banner.jpg', true, NOW(), NOW()),
-- ('event-550e8400-e29b-41d4-a716-446655440003', 'Wimbledon 2025', 'The Championships, Wimbledon', 'TENNIS', '2025-06-23 00:00:00+00', '2025-07-06 23:59:59+00', 'London, England', 'All England Club', 'https://cdn.sportstream.com/events/wimbledon_logo.png', 'https://cdn.sportstream.com/events/wimbledon_banner.jpg', true, NOW(), NOW());

-- -- Insert Matches with various statuses
-- INSERT INTO matches (match_id, event_id, home_team_id, away_team_id, status, start_time, end_time, venue, competition, stream_url, viewer_count, created_at, updated_at) VALUES
-- -- Premier League Matches
-- ('match-550e8400-e29b-41d4-a716-446655440001', 'event-550e8400-e29b-41d4-a716-446655440001', 'team-550e8400-e29b-41d4-a716-446655440001', 'team-550e8400-e29b-41d4-a716-446655440002', 'LIVE', NOW() - INTERVAL '30 minutes', NULL, 'Emirates Stadium', 'Premier League', 'https://stream.example.com/arsenal_chelsea', 15420, NOW(), NOW()),
-- ('match-550e8400-e29b-41d4-a716-446655440002', 'event-550e8400-e29b-41d4-a716-446655440001', 'team-550e8400-e29b-41d4-a716-446655440003', 'team-550e8400-e29b-41d4-a716-446655440004', 'FINISHED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '2 hours', 'Old Trafford', 'Premier League', 'https://stream.example.com/manutd_liverpool', 28500, NOW(), NOW()),
-- ('match-550e8400-e29b-41d4-a716-446655440003', 'event-550e8400-e29b-41d4-a716-446655440001', 'team-550e8400-e29b-41d4-a716-446655440005', 'team-550e8400-e29b-41d4-a716-446655440001', 'SCHEDULED', NOW() + INTERVAL '3 days', NULL, 'Etihad Stadium', 'Premier League', 'https://stream.example.com/mancity_arsenal', 0, NOW(), NOW()),
-- ('match-550e8400-e29b-41d4-a716-446655440004', 'event-550e8400-e29b-41d4-a716-446655440001', 'team-550e8400-e29b-41d4-a716-446655440002', 'team-550e8400-e29b-41d4-a716-446655440004', 'SCHEDULED', NOW() + INTERVAL '5 days', NULL, 'Stamford Bridge', 'Premier League', 'https://stream.example.com/chelsea_liverpool', 0, NOW(), NOW()),
-- -- NBA Matches
-- ('match-550e8400-e29b-41d4-a716-446655440005', 'event-550e8400-e29b-41d4-a716-446655440002', 'team-550e8400-e29b-41d4-a716-446655440006', 'team-550e8400-e29b-41d4-a716-446655440008', 'FINISHED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '3 hours', 'Crypto.com Arena', 'NBA', 'https://stream.example.com/lakers_celtics', 22100, NOW(), NOW()),
-- ('match-550e8400-e29b-41d4-a716-446655440006', 'event-550e8400-e29b-41d4-a716-446655440002', 'team-550e8400-e29b-41d4-a716-446655440007', 'team-550e8400-e29b-41d4-a716-446655440006', 'SCHEDULED', NOW() + INTERVAL '2 days', NULL, 'Chase Center', 'NBA', 'https://stream.example.com/warriors_lakers', 0, NOW(), NOW());

-- -- Insert Match Events (goals, cards, etc.)
-- INSERT INTO match_events (event_id, match_id, event_type, minute, team_id, player_name, description, created_at) VALUES
-- -- Arsenal vs Chelsea (Live Match)
-- ('matchevent-550e8400-e29b-41d4-a716-446655440001', 'match-550e8400-e29b-41d4-a716-446655440001', 'goal', 23, 'team-550e8400-e29b-41d4-a716-446655440001', 'Gabriel Jesus', 'Goal scored from inside the penalty area', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440002', 'match-550e8400-e29b-41d4-a716-446655440001', 'card', 35, 'team-550e8400-e29b-41d4-a716-446655440002', 'Enzo Fernandez', 'Yellow card for unsporting behavior', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440003', 'match-550e8400-e29b-41d4-a716-446655440001', 'goal', 67, 'team-550e8400-e29b-41d4-a716-446655440002', 'Nicolas Jackson', 'Goal scored from a counter-attack', NOW()),
-- -- Man United vs Liverpool (Finished Match)
-- ('matchevent-550e8400-e29b-41d4-a716-446655440004', 'match-550e8400-e29b-41d4-a716-446655440002', 'goal', 15, 'team-550e8400-e29b-41d4-a716-446655440004', 'Mohamed Salah', 'Goal from a through ball', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440005', 'match-550e8400-e29b-41d4-a716-446655440002', 'goal', 42, 'team-550e8400-e29b-41d4-a716-446655440003', 'Marcus Rashford', 'Goal from a free kick', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440006', 'match-550e8400-e29b-41d4-a716-446655440002', 'goal', 78, 'team-550e8400-e29b-41d4-a716-446655440004', 'Darwin Nunez', 'Winning goal from a corner', NOW()),
-- -- Lakers vs Celtics (Finished NBA Match)
-- ('matchevent-550e8400-e29b-41d4-a716-446655440007', 'match-550e8400-e29b-41d4-a716-446655440005', 'basket', 5, 'team-550e8400-e29b-41d4-a716-446655440006', 'LeBron James', '3-pointer from downtown', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440008', 'match-550e8400-e29b-41d4-a716-446655440005', 'basket', 12, 'team-550e8400-e29b-41d4-a716-446655440008', 'Jayson Tatum', 'Slam dunk', NOW()),
-- ('matchevent-550e8400-e29b-41d4-a716-446655440009', 'match-550e8400-e29b-41d4-a716-446655440005', 'foul', 18, 'team-550e8400-e29b-41d4-a716-446655440006', 'Anthony Davis', 'Personal foul', NOW());

-- -- Insert Highlights
-- INSERT INTO highlights (highlight_id, match_id, title, description, video_url, thumbnail_url, duration, tags, view_count, created_at) VALUES
-- ('highlight-550e8400-e29b-41d4-a716-446655440001', 'match-550e8400-e29b-41d4-a716-446655440001', 'Gabriel Jesus Opening Goal', 'Jesus breaks the deadlock with a clinical finish', 'https://highlights.sportstream.com/jesus_goal.mp4', 'https://thumbnails.sportstream.com/jesus_goal.jpg', 45, '["football", "goal", "arsenal", "jesus"]', 2340, NOW()),
-- ('highlight-550e8400-e29b-41d4-a716-446655440002', 'match-550e8400-e29b-41d4-a716-446655440001', 'Jackson Equalizer', 'Jackson levels the score with a brilliant counter-attack goal', 'https://highlights.sportstream.com/jackson_goal.mp4', 'https://thumbnails.sportstream.com/jackson_goal.jpg', 38, '["football", "goal", "chelsea", "jackson"]', 1890, NOW()),
-- ('highlight-550e8400-e29b-41d4-a716-446655440003', 'match-550e8400-e29b-41d4-a716-446655440002', 'Salah Wonder Goal', 'Salah scores a spectacular goal to give Liverpool the lead', 'https://highlights.sportstream.com/salah_goal.mp4', 'https://thumbnails.sportstream.com/salah_goal.jpg', 52, '["football", "goal", "liverpool", "salah"]', 4520, NOW()),
-- ('highlight-550e8400-e29b-41d4-a716-446655440004', 'match-550e8400-e29b-41d4-a716-446655440002', 'Nunez Winner', 'Nunez scores the winner in dramatic fashion', 'https://highlights.sportstream.com/nunez_winner.mp4', 'https://thumbnails.sportstream.com/nunez_winner.jpg', 48, '["football", "goal", "liverpool", "nunez", "winner"]', 3670, NOW()),
-- ('highlight-550e8400-e29b-41d4-a716-446655440005', 'match-550e8400-e29b-41d4-a716-446655440005', 'LeBron Three-Pointer', 'LeBron drains a deep three-pointer', 'https://highlights.sportstream.com/lebron_three.mp4', 'https://thumbnails.sportstream.com/lebron_three.jpg', 25, '["basketball", "three-pointer", "lakers", "lebron"]', 5230, NOW()),
-- ('highlight-550e8400-e29b-41d4-a716-446655440006', 'match-550e8400-e29b-41d4-a716-446655440005', 'Tatum Slam Dunk', 'Tatum throws down a powerful slam dunk', 'https://highlights.sportstream.com/tatum_dunk.mp4', 'https://thumbnails.sportstream.com/tatum_dunk.jpg', 18, '["basketball", "dunk", "celtics", "tatum"]', 3450, NOW());

-- -- Insert Emoji Assets (matching existing table structure)
-- INSERT INTO emoji_assets (emoji_id, name, image_url, description, created_at) VALUES
-- ('emoji-550e8400-e29b-41d4-a716-446655440001', 'Fire', 'https://cdn.sportstream.com/emojis/fire.png', 'Fire emoji for exciting moments', NOW()),
-- ('emoji-550e8400-e29b-41d4-a716-446655440002', 'Clap', 'https://cdn.sportstream.com/emojis/clap.png', 'Clapping hands for applause', NOW()),
-- ('emoji-550e8400-e29b-41d4-a716-446655440003', 'Heart', 'https://cdn.sportstream.com/emojis/heart.png', 'Heart for love and support', NOW()),
-- ('emoji-550e8400-e29b-41d4-a716-446655440004', 'Thumbs Up', 'https://cdn.sportstream.com/emojis/thumbs_up.png', 'Thumbs up for approval', NOW()),
-- ('emoji-550e8400-e29b-41d4-a716-446655440005', 'Goal', 'https://cdn.sportstream.com/emojis/goal.png', 'Goal celebration emoji', NOW());

-- -- Insert User Emoji Reactions
-- INSERT INTO user_emoji_reactions (reaction_id, user_id, match_id, emoji_id, created_at) VALUES
-- ('reaction-550e8400-e29b-41d4-a716-446655440001', 'user-550e8400-e29b-41d4-a716-446655440001', 'match-550e8400-e29b-41d4-a716-446655440001', 'emoji-550e8400-e29b-41d4-a716-446655440001', NOW()),
-- ('reaction-550e8400-e29b-41d4-a716-446655440002', 'user-550e8400-e29b-41d4-a716-446655440002', 'match-550e8400-e29b-41d4-a716-446655440001', 'emoji-550e8400-e29b-41d4-a716-446655440005', NOW()),
-- ('reaction-550e8400-e29b-41d4-a716-446655440003', 'user-550e8400-e29b-41d4-a716-446655440001', 'match-550e8400-e29b-41d4-a716-446655440002', 'emoji-550e8400-e29b-41d4-a716-446655440003', NOW()),
-- ('reaction-550e8400-e29b-41d4-a716-446655440004', 'user-550e8400-e29b-41d4-a716-446655440002', 'match-550e8400-e29b-41d4-a716-446655440005', 'emoji-550e8400-e29b-41d4-a716-446655440001', NOW()),
-- ('reaction-550e8400-e29b-41d4-a716-446655440005', 'user-550e8400-e29b-41d4-a716-446655440004', 'match-550e8400-e29b-41d4-a716-446655440005', 'emoji-550e8400-e29b-41d4-a716-446655440002', NOW());

-- COMMIT;

-- -- Verification queries to confirm data insertion
-- SELECT 'Users inserted: ' || COUNT(*) FROM users;
-- SELECT 'Sports inserted: ' || COUNT(*) FROM sports;
-- SELECT 'Teams inserted: ' || COUNT(*) FROM teams;
-- SELECT 'Events inserted: ' || COUNT(*) FROM events;
-- SELECT 'Matches inserted: ' || COUNT(*) FROM matches;
-- SELECT 'Match Events inserted: ' || COUNT(*) FROM match_events;
-- SELECT 'Highlights inserted: ' || COUNT(*) FROM highlights;
-- SELECT 'Emoji Assets inserted: ' || COUNT(*) FROM emoji_assets;
-- SELECT 'User Emoji Reactions inserted: ' || COUNT(*) FROM user_emoji_reactions;
