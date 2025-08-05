-- Sports Telecast Database Schema
-- Emoji Assets and Reactions Implementation

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create emoji_type enum if it doesn't exist
DO $$ BEGIN
    CREATE TYPE emoji_type AS ENUM ('clap','fire','heart','thumbs_up','celebration','shocked','angry','sad','laugh','goal');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create match_status enum if it doesn't exist  
DO $$ BEGIN
    CREATE TYPE match_status AS ENUM ('scheduled', 'live', 'finished', 'cancelled', 'postponed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Emoji Assets Table
CREATE TABLE IF NOT EXISTS emoji_assets (
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

-- Emoji Reactions Table
CREATE TABLE IF NOT EXISTS emoji_reactions (
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

-- Emoji Reaction Summary Table for Performance
CREATE TABLE IF NOT EXISTS emoji_reaction_summary (
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

-- Performance Indices
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_event_id ON emoji_reactions(event_id);
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_user_id ON emoji_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_emoji_reactions_created_at ON emoji_reactions(created_at);
CREATE INDEX IF NOT EXISTS idx_emoji_summary_event_id ON emoji_reaction_summary(event_id);

-- Trigger function to update emoji reaction summary
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
DROP TRIGGER IF EXISTS update_emoji_summary_on_reaction ON emoji_reactions;
CREATE TRIGGER update_emoji_summary_on_reaction 
    AFTER INSERT ON emoji_reactions
    FOR EACH ROW EXECUTE FUNCTION update_emoji_reaction_summary();

-- Table comments
COMMENT ON TABLE emoji_assets IS 'Available emoji types for user reactions';
COMMENT ON TABLE emoji_reactions IS 'User emoji reactions during events';
COMMENT ON TABLE emoji_reaction_summary IS 'Aggregated emoji reaction counts for performance';
