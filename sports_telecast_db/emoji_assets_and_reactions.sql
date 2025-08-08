-- SQL CREATE TABLE statements for emoji_assets and emoji_reactions tables
-- Updated to use camelCase field names with case-sensitive (quoted) usage
-- This ensures compatibility with the API field names and maintains consistency

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS "emojiReactions" CASCADE;
DROP TABLE IF EXISTS "emojiAssets" CASCADE;

-- Create emoji assets table with camelCase column names
CREATE TABLE "emojiAssets" (
    "emojiId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "emojiType" VARCHAR(50) NOT NULL UNIQUE,
    "emojiPath" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT "chk_emojiAssets_emojiType" CHECK ("emojiType" IN ('clap','fire','heart','thumbs_up','celebration','shocked','angry','sad','laugh','goal')),
    CONSTRAINT "uq_emojiAssets_name" UNIQUE ("name"),
    CONSTRAINT "chk_emojiAssets_sortOrder" CHECK ("sortOrder" >= 0)
);

-- Create emoji reactions table with camelCase column names  
CREATE TABLE "emojiReactions" (
    "reactionId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "eventId" VARCHAR(100) NOT NULL,
    "userId" UUID, -- nullable for anonymous reactions
    "emojiId" UUID NOT NULL,
    "matchId" UUID, -- optional reference to specific match
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints (references will be added when main tables exist)
    CONSTRAINT "fk_emojiReactions_emojiId" FOREIGN KEY ("emojiId") REFERENCES "emojiAssets"("emojiId") ON DELETE CASCADE,
    
    -- Indexes for performance
    CONSTRAINT "idx_emojiReactions_eventId_emojiId" UNIQUE ("eventId", "userId", "emojiId", "createdAt")
);

-- Create indexes for performance optimization
CREATE INDEX "idx_emojiAssets_emojiType" ON "emojiAssets"("emojiType");
CREATE INDEX "idx_emojiAssets_isActive" ON "emojiAssets"("isActive") WHERE "isActive" = true;
CREATE INDEX "idx_emojiAssets_sortOrder" ON "emojiAssets"("sortOrder");

CREATE INDEX "idx_emojiReactions_eventId" ON "emojiReactions"("eventId");
CREATE INDEX "idx_emojiReactions_userId" ON "emojiReactions"("userId") WHERE "userId" IS NOT NULL;
CREATE INDEX "idx_emojiReactions_emojiId" ON "emojiReactions"("emojiId");
CREATE INDEX "idx_emojiReactions_createdAt" ON "emojiReactions"("createdAt");
CREATE INDEX "idx_emojiReactions_matchId" ON "emojiReactions"("matchId") WHERE "matchId" IS NOT NULL;

-- Add trigger for automatic updatedAt timestamp
CREATE OR REPLACE FUNCTION "update_emojiReactions_updatedAt"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trigger_emojiReactions_updatedAt" 
    BEFORE UPDATE ON "emojiReactions"
    FOR EACH ROW EXECUTE FUNCTION "update_emojiReactions_updatedAt"();

-- Add table comments for documentation
COMMENT ON TABLE "emojiAssets" IS 'Available emoji types for user reactions during live events';
COMMENT ON TABLE "emojiReactions" IS 'User emoji reactions submitted during live events and matches';

-- Add column comments for clarity
COMMENT ON COLUMN "emojiAssets"."emojiId" IS 'Unique identifier for the emoji asset';
COMMENT ON COLUMN "emojiAssets"."emojiType" IS 'Type/category of emoji (clap, fire, heart, etc.)';
COMMENT ON COLUMN "emojiAssets"."emojiPath" IS 'File system path to the emoji image';
COMMENT ON COLUMN "emojiAssets"."imageUrl" IS 'Public URL to access the emoji image';
COMMENT ON COLUMN "emojiAssets"."name" IS 'Human-readable name for the emoji';
COMMENT ON COLUMN "emojiAssets"."description" IS 'Optional description of when/how to use this emoji';
COMMENT ON COLUMN "emojiAssets"."isActive" IS 'Whether this emoji is currently available for use';
COMMENT ON COLUMN "emojiAssets"."sortOrder" IS 'Display order for emoji selection UI';

COMMENT ON COLUMN "emojiReactions"."reactionId" IS 'Unique identifier for the reaction';
COMMENT ON COLUMN "emojiReactions"."eventId" IS 'Identifier of the event being reacted to';
COMMENT ON COLUMN "emojiReactions"."userId" IS 'User who submitted the reaction (nullable for anonymous)';
COMMENT ON COLUMN "emojiReactions"."emojiId" IS 'Reference to the emoji that was used';
COMMENT ON COLUMN "emojiReactions"."matchId" IS 'Optional reference to specific match within event';
COMMENT ON COLUMN "emojiReactions"."createdAt" IS 'When the reaction was submitted';
COMMENT ON COLUMN "emojiReactions"."updatedAt" IS 'When the reaction was last modified';
