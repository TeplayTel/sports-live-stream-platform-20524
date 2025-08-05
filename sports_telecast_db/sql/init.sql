-- Sports Telecast Database Initialization
-- Sample Emoji Data and Reactions

-- Insert sample emoji assets
INSERT INTO emoji_assets (emoji_type, name, image_url, description, unicode_char, color, gradient_class, sound_config, sort_order) VALUES
('heart'::emoji_type, 'Love', 'https://cdn.sportstelecast.com/emojis/heart.png', 'Love and appreciation', '❤️', '#ff1744', 'from-pink-500 via-red-500 to-rose-600', '{"frequency": 523.25, "type": "sine", "duration": 0.3}', 1),
('laugh'::emoji_type, 'Laugh', 'https://cdn.sportstelecast.com/emojis/laugh.png', 'Laughter and joy', '😂', '#ffc107', 'from-yellow-400 via-orange-400 to-red-400', '{"frequency": 659.25, "type": "triangle", "duration": 0.4}', 2),
('shocked'::emoji_type, 'Wow', 'https://cdn.sportstelecast.com/emojis/wow.png', 'Surprise and amazement', '😮', '#2196f3', 'from-blue-400 via-purple-500 to-indigo-600', '{"frequency": 783.99, "type": "sawtooth", "duration": 0.5}', 3),
('clap'::emoji_type, 'Clap', 'https://cdn.sportstelecast.com/emojis/clap.png', 'Applause and approval', '👏', '#4caf50', 'from-green-400 via-emerald-500 to-teal-600', '{"frequency": 392.00, "type": "square", "duration": 0.2}', 4),
('fire'::emoji_type, 'Fire', 'https://cdn.sportstelecast.com/emojis/fire.png', 'Excitement and intensity', '🔥', '#ff5722', 'from-orange-500 via-red-500 to-pink-500', '{"frequency": 698.46, "type": "sine", "duration": 0.6}', 5),
('goal'::emoji_type, 'Soccer', 'https://cdn.sportstelecast.com/emojis/soccer.png', 'Football/soccer celebration', '⚽', '#8bc34a', 'from-green-500 via-lime-500 to-emerald-500', '{"frequency": 440.00, "type": "triangle", "duration": 0.8}', 6),
('thumbs_up'::emoji_type, 'Thumbs Up', 'https://cdn.sportstelecast.com/emojis/thumbs_up.png', 'Approval and positive reaction', '👍', '#4caf50', 'from-green-400 via-emerald-400 to-teal-500', '{"frequency": 440.00, "type": "sine", "duration": 0.3}', 7),
('celebration'::emoji_type, 'Celebration', 'https://cdn.sportstelecast.com/emojis/celebration.png', 'Victory and celebration', '🎉', '#ff9800', 'from-yellow-400 via-orange-500 to-red-500', '{"frequency": 523.25, "type": "triangle", "duration": 0.7}', 8),
('angry'::emoji_type, 'Angry', 'https://cdn.sportstelecast.com/emojis/angry.png', 'Frustration and anger', '😠', '#f44336', 'from-red-500 via-red-600 to-red-700', '{"frequency": 220.00, "type": "sawtooth", "duration": 0.4}', 9),
('sad'::emoji_type, 'Sad', 'https://cdn.sportstelecast.com/emojis/sad.png', 'Disappointment and sadness', '😢', '#607d8b', 'from-gray-400 via-blue-400 to-blue-500', '{"frequency": 261.63, "type": "sine", "duration": 0.5}', 10)
ON CONFLICT (emoji_type, name) DO NOTHING;

-- Sample reaction counts for demonstration (using dummy event/match IDs)
-- These will be populated with real IDs when events and matches are created
DO $$
DECLARE
    sample_event_id UUID := '11111111-1111-1111-1111-111111111111';
    sample_match_id UUID := '22222222-2222-2222-2222-222222222222';
    heart_emoji_id UUID;
    fire_emoji_id UUID;
    clap_emoji_id UUID;
    goal_emoji_id UUID;
    laugh_emoji_id UUID;
    shocked_emoji_id UUID;
BEGIN
    -- Get emoji IDs for sample data
    SELECT emoji_id INTO heart_emoji_id FROM emoji_assets WHERE emoji_type = 'heart' LIMIT 1;
    SELECT emoji_id INTO fire_emoji_id FROM emoji_assets WHERE emoji_type = 'fire' LIMIT 1;
    SELECT emoji_id INTO clap_emoji_id FROM emoji_assets WHERE emoji_type = 'clap' LIMIT 1;
    SELECT emoji_id INTO goal_emoji_id FROM emoji_assets WHERE emoji_type = 'goal' LIMIT 1;
    SELECT emoji_id INTO laugh_emoji_id FROM emoji_assets WHERE emoji_type = 'laugh' LIMIT 1;
    SELECT emoji_id INTO shocked_emoji_id FROM emoji_assets WHERE emoji_type = 'shocked' LIMIT 1;

    -- Sample emoji reaction summary data
    -- Note: This requires actual event and match IDs to be valid
    -- Uncomment and modify when real data is available
    /*
    INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count, last_updated) VALUES
    (sample_event_id, sample_match_id, heart_emoji_id, 342),
    (sample_event_id, sample_match_id, fire_emoji_id, 287),
    (sample_event_id, sample_match_id, clap_emoji_id, 205),
    (sample_event_id, sample_match_id, goal_emoji_id, 156),
    (sample_event_id, sample_match_id, laugh_emoji_id, 128),
    (sample_event_id, sample_match_id, shocked_emoji_id, 89)
    ON CONFLICT (event_id, match_id, emoji_id) DO NOTHING;
    */
END $$;

-- Create a view for easy emoji reaction statistics
CREATE OR REPLACE VIEW emoji_reaction_stats AS
SELECT 
    ea.emoji_type,
    ea.name as emoji_name,
    ea.unicode_char,
    ea.color,
    COALESCE(SUM(ers.reaction_count), 0) as total_reactions,
    COUNT(ers.summary_id) as events_with_reactions
FROM emoji_assets ea
LEFT JOIN emoji_reaction_summary ers ON ea.emoji_id = ers.emoji_id
WHERE ea.is_active = true
GROUP BY ea.emoji_id, ea.emoji_type, ea.name, ea.unicode_char, ea.color, ea.sort_order
ORDER BY ea.sort_order;

-- Create a function to get top emoji reactions for an event
CREATE OR REPLACE FUNCTION get_top_emoji_reactions(p_event_id UUID, p_match_id UUID DEFAULT NULL, p_limit INTEGER DEFAULT 5)
RETURNS TABLE(
    emoji_type emoji_type,
    emoji_name VARCHAR(50),
    unicode_char VARCHAR(10),
    color VARCHAR(7),
    reaction_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ea.emoji_type,
        ea.name,
        ea.unicode_char,
        ea.color,
        ers.reaction_count
    FROM emoji_reaction_summary ers
    JOIN emoji_assets ea ON ers.emoji_id = ea.emoji_id
    WHERE ers.event_id = p_event_id
    AND (p_match_id IS NULL OR ers.match_id = p_match_id)
    AND ea.is_active = true
    ORDER BY ers.reaction_count DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Create a function to add an emoji reaction
CREATE OR REPLACE FUNCTION add_emoji_reaction(
    p_user_id UUID,
    p_event_id UUID,
    p_match_id UUID,
    p_emoji_type emoji_type
) RETURNS BOOLEAN AS $$
DECLARE
    v_emoji_id UUID;
BEGIN
    -- Get the emoji_id for the given emoji_type
    SELECT emoji_id INTO v_emoji_id 
    FROM emoji_assets 
    WHERE emoji_type = p_emoji_type AND is_active = true 
    LIMIT 1;
    
    IF v_emoji_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Insert the reaction
    INSERT INTO emoji_reactions (user_id, event_id, match_id, emoji_id)
    VALUES (p_user_id, p_event_id, p_match_id, v_emoji_id);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed for your setup)
-- GRANT SELECT, INSERT, UPDATE ON emoji_assets TO your_app_user;
-- GRANT SELECT, INSERT ON emoji_reactions TO your_app_user;
-- GRANT SELECT ON emoji_reaction_summary TO your_app_user;
-- GRANT EXECUTE ON FUNCTION get_top_emoji_reactions TO your_app_user;
-- GRANT EXECUTE ON FUNCTION add_emoji_reaction TO your_app_user;
