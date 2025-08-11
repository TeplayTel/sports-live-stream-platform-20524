-- Schema for emoji_assets and emoji_reactions tables for the sports telecast platform

-- Table: emoji_assets
CREATE TABLE IF NOT EXISTS emoji_assets (
    emoji_id SERIAL PRIMARY KEY,
    emoji_type VARCHAR(50) NOT NULL UNIQUE,
    emoji_path TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: emoji_reactions
CREATE TABLE IF NOT EXISTS emoji_reactions (
    reaction_id SERIAL PRIMARY KEY,
    event_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100),
    emoji_id INT,
    emoji_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emoji_type FOREIGN KEY (emoji_type) REFERENCES emoji_assets(emoji_type)
);

-- Optionally, you may want to ensure emoji_id in emoji_reactions references emoji_assets. 
-- If so, uncomment the below line:
-- ALTER TABLE emoji_reactions ADD CONSTRAINT fk_emoji_id FOREIGN KEY (emoji_id) REFERENCES emoji_assets(emoji_id);

-- Notes:
-- - emoji_assets must exist before emoji_reactions due to foreign key dependency.
-- - emoji_type is the enforced reference between the two tables.
-- - All constraints and field types follow requirements.
