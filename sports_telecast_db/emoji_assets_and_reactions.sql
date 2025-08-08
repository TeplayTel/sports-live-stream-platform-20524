-- SQL CREATE TABLE statements for emoji_assets and emoji_reactions tables
-- These statements follow the exact structure specified in the requirements

CREATE TABLE emoji_assets (
    emoji_id SERIAL PRIMARY KEY,
    emoji_type VARCHAR(50) NOT NULL UNIQUE,
    emoji_path TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE emoji_reactions (
    reaction_id SERIAL PRIMARY KEY,
    event_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100), -- nullable
    emoji_type VARCHAR(50) NOT NULL REFERENCES emoji_assets(emoji_type),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
