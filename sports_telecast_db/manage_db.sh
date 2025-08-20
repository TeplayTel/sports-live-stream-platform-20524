#!/bin/bash

# Sports Telecast Database Management Script
# This script helps manage database migrations and operations

set -e

# Configuration
DB_HOST="localhost"
DB_PORT="5000"
DB_NAME="myapp"
DB_USER="appuser"
DB_PASSWORD="dbuser123"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if PostgreSQL is running
check_postgres() {
    print_status "Checking PostgreSQL connection..."
    if pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > /dev/null 2>&1; then
        print_status "PostgreSQL is running and accessible"
        return 0
    else
        print_error "PostgreSQL is not accessible. Please start the database first."
        return 1
    fi
}

# Function to run a SQL file
run_sql_file() {
    local sql_file=$1
    local description=$2
    
    if [ ! -f "$sql_file" ]; then
        print_error "SQL file not found: $sql_file"
        return 1
    fi
    
    print_status "$description"
    
    if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$sql_file"; then
        print_status "Successfully executed: $sql_file"
        return 0
    else
        print_error "Failed to execute: $sql_file"
        return 1
    fi
}

# Function to create migration tracking table
create_migration_table() {
    print_status "Creating migration tracking table..."
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
CREATE TABLE IF NOT EXISTS migration_history (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) UNIQUE NOT NULL,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT true
);
EOF
    
    if [ $? -eq 0 ]; then
        print_status "Migration tracking table created successfully"
    else
        print_error "Failed to create migration tracking table"
        return 1
    fi
}

# Function to check if migration was already run
is_migration_executed() {
    local migration_name=$1
    local count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM migration_history WHERE migration_name='$migration_name' AND success=true;" 2>/dev/null | tr -d ' ')
    
    if [ "$count" = "1" ]; then
        return 0  # Already executed
    else
        return 1  # Not executed
    fi
}

# Function to record migration execution
record_migration() {
    local migration_name=$1
    local success=$2
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "INSERT INTO migration_history (migration_name, success) VALUES ('$migration_name', $success) ON CONFLICT (migration_name) DO UPDATE SET executed_at = CURRENT_TIMESTAMP, success = $success;"
}

# Function to run migrations
run_migrations() {
    print_status "Starting database migrations..."
    
    if ! check_postgres; then
        return 1
    fi
    
    create_migration_table
    
    # List of migrations in order
    migrations=(
        "001_initial_schema.sql:Initial database schema"
        "002_seed_data.sql:Seed data population"
        "008_emoji_schema_indices.sql:Emoji schema alignment, FKs, and indices"
        "009_seed_emoji_assets_basic.sql:Seed core emoji assets (heart, clap, fire, wow/love)"
        "010_upsert_core_emojis.sql:Upsert/refresh core emoji assets and ensure emoji_path"
        "011_create_emoji_reactions_table.sql:Create/align emoji_reactions table with FKs, indices, and triggers"
    )
    
    for migration in "${migrations[@]}"; do
        IFS=':' read -r file description <<< "$migration"
        migration_path="migrations/$file"
        
        if is_migration_executed "$file"; then
            print_warning "Migration already executed: $file"
            continue
        fi
        
        print_status "Running migration: $file - $description"
        
        if run_sql_file "$migration_path" "$description"; then
            record_migration "$file" "true"
            print_status "Migration completed: $file"
        else
            record_migration "$file" "false"
            print_error "Migration failed: $file"
            return 1
        fi
    done
    
    print_status "All migrations completed successfully!"
}

# Function to reset database (WARNING: This will delete all data)
reset_database() {
    print_warning "WARNING: This will delete all data in the database!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Database reset cancelled"
        return 0
    fi
    
    if ! check_postgres; then
        return 1
    fi
    
    print_status "Dropping all tables..."
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
-- Drop all tables in the correct order (reverse of creation due to foreign keys)
DROP TABLE IF EXISTS viewer_count_snapshots CASCADE;
DROP TABLE IF EXISTS viewer_sessions CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS emoji_reaction_summary CASCADE;
DROP TABLE IF EXISTS emoji_reactions CASCADE;
DROP TABLE IF EXISTS emoji_assets CASCADE;
DROP TABLE IF EXISTS stream_qualities CASCADE;
DROP TABLE IF EXISTS highlights CASCADE;
DROP TABLE IF EXISTS match_lineups CASCADE;
DROP TABLE IF EXISTS match_statistics CASCADE;
DROP TABLE IF EXISTS match_events CASCADE;
DROP TABLE IF EXISTS match_scores CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS sports CASCADE;
DROP TABLE IF EXISTS user_preferences CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS migration_history CASCADE;

-- Drop custom types
DROP TYPE IF EXISTS match_status CASCADE;
DROP TYPE IF EXISTS emoji_type CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_emoji_reaction_summary() CASCADE;
EOF
    
    if [ $? -eq 0 ]; then
        print_status "Database reset completed"
    else
        print_error "Database reset failed"
        return 1
    fi
}

# Function to show database status
show_status() {
    if ! check_postgres; then
        return 1
    fi
    
    print_status "Database Status:"
    
    # Check if tables exist
    table_count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    
    echo "  Tables: $table_count"
    
    # Show migration history if it exists
    if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt migration_history" > /dev/null 2>&1; then
        echo "  Migration History:"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT migration_name, executed_at, success FROM migration_history ORDER BY executed_at;"
    fi
    
    # Show table row counts
    if [ "$table_count" -gt 0 ]; then
        echo "  Row Counts:"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
SELECT 
    schemaname,
    tablename,
    n_tup_ins - n_tup_del as row_count
FROM pg_stat_user_tables 
WHERE schemaname = 'public'
ORDER BY tablename;
EOF
    fi
}

# Function to backup database
backup_database() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    
    print_status "Creating database backup: $backup_file"
    
    if PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > "$backup_file"; then
        print_status "Backup created successfully: $backup_file"
    else
        print_error "Backup failed"
        return 1
    fi
}

# Function to show help
show_help() {
    echo "Sports Telecast Database Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  migrate     Run all pending migrations"
    echo "  reset       Reset database (WARNING: Deletes all data)"
    echo "  status      Show database status and migration history"
    echo "  backup      Create a database backup"
    echo "  help        Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DB_HOST     Database host (default: localhost)"
    echo "  DB_PORT     Database port (default: 5000)"
    echo "  DB_NAME     Database name (default: myapp)"
    echo "  DB_USER     Database user (default: appuser)"
    echo "  DB_PASSWORD Database password (default: dbuser123)"
}

# Main script execution
case "${1:-help}" in
    migrate)
        run_migrations
        ;;
    reset)
        reset_database
        ;;
    status)
        show_status
        ;;
    backup)
        backup_database
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
