-- Sports Telecast Database Maintenance Procedures
-- Run these procedures regularly for optimal database performance

-- =====================================================
-- PERFORMANCE OPTIMIZATION PROCEDURES
-- =====================================================

-- Function to analyze and optimize table statistics
CREATE OR REPLACE FUNCTION optimize_database_statistics()
RETURNS void AS $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE 'Starting database statistics optimization...';
    
    -- Update statistics for all user tables
    FOR table_record IN 
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ANALYZE %I.%I', table_record.schemaname, table_record.tablename);
        RAISE NOTICE 'Analyzed table: %', table_record.tablename;
    END LOOP;
    
    RAISE NOTICE 'Database statistics optimization completed';
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old viewer sessions and snapshots
CREATE OR REPLACE FUNCTION cleanup_old_analytics_data(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_sessions INTEGER;
    deleted_snapshots INTEGER;
    cutoff_date TIMESTAMP WITH TIME ZONE;
BEGIN
    cutoff_date := CURRENT_TIMESTAMP - INTERVAL '1 day' * days_to_keep;
    
    -- Clean up old viewer sessions
    DELETE FROM viewer_sessions 
    WHERE leave_time IS NOT NULL AND leave_time < cutoff_date;
    GET DIAGNOSTICS deleted_sessions = ROW_COUNT;
    
    -- Clean up old viewer count snapshots (keep daily snapshots)
    DELETE FROM viewer_count_snapshots 
    WHERE timestamp < cutoff_date 
    AND extract(hour from timestamp) != 0; -- Keep midnight snapshots as daily records
    GET DIAGNOSTICS deleted_snapshots = ROW_COUNT;
    
    RAISE NOTICE 'Cleaned up % old viewer sessions and % old snapshots', 
                 deleted_sessions, deleted_snapshots;
                 
    RETURN deleted_sessions + deleted_snapshots;
END;
$$ LANGUAGE plpgsql;

-- Function to update emoji reaction summary tables
CREATE OR REPLACE FUNCTION recalculate_emoji_summary()
RETURNS void AS $$
BEGIN
    RAISE NOTICE 'Recalculating emoji reaction summary...';
    
    -- Delete existing summary data
    DELETE FROM emoji_reaction_summary;
    
    -- Recalculate from individual reactions
    INSERT INTO emoji_reaction_summary (event_id, match_id, emoji_id, reaction_count, last_updated)
    SELECT 
        event_id,
        match_id,
        emoji_id,
        count(*) as reaction_count,
        CURRENT_TIMESTAMP
    FROM emoji_reactions
    GROUP BY event_id, match_id, emoji_id;
    
    RAISE NOTICE 'Emoji reaction summary recalculation completed';
END;
$$ LANGUAGE plpgsql;

-- Function to vacuum and reindex database
CREATE OR REPLACE FUNCTION vacuum_database()
RETURNS void AS $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE 'Starting database vacuum and reindex...';
    
    -- Vacuum all user tables
    FOR table_record IN 
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
        AND tablename != 'migration_history'
    LOOP
        EXECUTE format('VACUUM ANALYZE %I.%I', table_record.schemaname, table_record.tablename);
        RAISE NOTICE 'Vacuumed table: %', table_record.tablename;
    END LOOP;
    
    RAISE NOTICE 'Database vacuum completed';
END;
$$ LANGUAGE plpgsql;

-- Function to generate database health report
CREATE OR REPLACE FUNCTION generate_health_report()
RETURNS TABLE (
    metric_name text,
    metric_value text,
    status text
) AS $$
BEGIN
    RETURN QUERY
    WITH metrics AS (
        SELECT 'Total Users' as metric, count(*)::text as value, 
               CASE WHEN count(*) > 0 THEN 'OK' ELSE 'WARNING' END as status
        FROM users
        
        UNION ALL
        SELECT 'Active Matches', count(*)::text, 
               CASE WHEN count(*) > 0 THEN 'OK' ELSE 'INFO' END
        FROM matches WHERE status = 'live'
        
        UNION ALL
        SELECT 'Total Events', count(*)::text, 
               CASE WHEN count(*) > 0 THEN 'OK' ELSE 'WARNING' END
        FROM events WHERE is_active = true
        
        UNION ALL
        SELECT 'Database Size', 
               pg_size_pretty(pg_database_size(current_database()))::text,
               'INFO'
        
        UNION ALL
        SELECT 'Active Connections', 
               count(*)::text,
               CASE WHEN count(*) < 80 THEN 'OK' ELSE 'WARNING' END
        FROM pg_stat_activity 
        WHERE state = 'active' AND pid <> pg_backend_pid()
        
        UNION ALL
        SELECT 'Emoji Reactions (24h)', 
               count(*)::text,
               'INFO'
        FROM emoji_reactions 
        WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
    )
    SELECT m.metric, m.value, m.status FROM metrics m;
END;
$$ LANGUAGE plpgsql;

-- Create scheduled maintenance view
CREATE OR REPLACE VIEW maintenance_schedule AS
SELECT 
    'Daily' as frequency,
    'optimize_database_statistics' as procedure_name,
    'Update table statistics for query planner' as description
UNION ALL
SELECT 'Weekly', 'cleanup_old_analytics_data', 'Remove old viewer session data'
UNION ALL
SELECT 'Weekly', 'recalculate_emoji_summary', 'Recalculate emoji reaction summaries'
UNION ALL
SELECT 'Monthly', 'vacuum_database', 'Vacuum and reindex database tables';

-- Grant execute permissions
-- GRANT EXECUTE ON FUNCTION optimize_database_statistics() TO your_app_user;
-- GRANT EXECUTE ON FUNCTION cleanup_old_analytics_data(INTEGER) TO your_app_user;
-- GRANT EXECUTE ON FUNCTION recalculate_emoji_summary() TO your_app_user;
-- GRANT EXECUTE ON FUNCTION vacuum_database() TO your_app_user;
-- GRANT EXECUTE ON FUNCTION generate_health_report() TO your_app_user;
