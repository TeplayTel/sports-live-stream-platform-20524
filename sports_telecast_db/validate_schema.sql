-- Sports Telecast Database Schema Validation
-- This script validates the database schema integrity and constraints

-- =====================================================
-- SCHEMA VALIDATION QUERIES
-- =====================================================

-- Check all required tables exist
DO $$
DECLARE
    required_tables text[] := ARRAY[
        'users', 'user_preferences', 'sports', 'teams', 'events', 
        'matches', 'match_scores', 'match_events', 'match_statistics', 
        'match_lineups', 'highlights', 'stream_qualities', 'emoji_assets', 
        'emoji_reactions', 'emoji_reaction_summary', 'chat_messages', 
        'viewer_sessions', 'viewer_count_snapshots'
    ];
    table_name text;
    table_exists boolean;
    missing_tables text[] := '{}';
BEGIN
    RAISE NOTICE 'Validating database schema for Sports Telecast application...';
    
    FOREACH table_name IN ARRAY required_tables
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = table_name
        ) INTO table_exists;
        
        IF NOT table_exists THEN
            missing_tables := array_append(missing_tables, table_name);
        END IF;
    END LOOP;
    
    IF array_length(missing_tables, 1) > 0 THEN
        RAISE EXCEPTION 'Missing required tables: %', array_to_string(missing_tables, ', ');
    ELSE
        RAISE NOTICE 'All required tables exist ✓';
    END IF;
END $$;

-- Validate foreign key constraints
SELECT 
    conname as constraint_name,
    conrelid::regclass as table_name,
    confrelid::regclass as referenced_table
FROM pg_constraint 
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text;

-- Check indexes for performance
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Validate enum types
SELECT 
    t.typname as enum_name,
    array_agg(e.enumlabel ORDER BY e.enumsortorder) as enum_values
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typnamespace = 'public'::regnamespace
GROUP BY t.typname
ORDER BY t.typname;

-- Check trigger functions
SELECT 
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' AND p.prokind = 'f'
ORDER BY p.proname;

-- Validate data integrity with sample counts
SELECT 
    'users' as table_name, 
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END as status
FROM users
UNION ALL
SELECT 'sports', count(*), CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END FROM sports
UNION ALL
SELECT 'teams', count(*), CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END FROM teams
UNION ALL
SELECT 'events', count(*), CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END FROM events
UNION ALL
SELECT 'matches', count(*), CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END FROM matches
UNION ALL
SELECT 'emoji_assets', count(*), CASE WHEN count(*) > 0 THEN 'Has Data' ELSE 'Empty' END FROM emoji_assets
ORDER BY table_name;

-- Performance check: Identify tables without primary keys (should be none)
SELECT 
    schemaname,
    tablename
FROM pg_tables
WHERE schemaname = 'public'
AND tablename NOT IN (
    SELECT t.table_name
    FROM information_schema.table_constraints t
    WHERE t.constraint_type = 'PRIMARY KEY' 
    AND t.table_schema = 'public'
);

-- Check for proper UUID usage
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
AND data_type = 'uuid'
ORDER BY table_name, column_name;

-- Verify presence of singular "user" table (created by migration 013)
-- This is a non-fatal presence check to aid CI visibility.
DO $$
DECLARE
    user_tbl regclass;
BEGIN
    SELECT to_regclass('public.user') INTO user_tbl;
    IF user_tbl IS NULL THEN
        RAISE NOTICE '"user" table not found (ok if not used by current backend).';
    ELSE
        RAISE NOTICE '"user" table exists ✓';
    END IF;
END $$;

RAISE NOTICE 'Schema validation completed successfully ✓';
