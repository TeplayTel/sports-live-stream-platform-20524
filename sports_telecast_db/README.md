# Sports Telecast Database

This directory contains the PostgreSQL database setup for the Sports Telecast application. The database is designed to persist all data categories previously used as mock data in the frontend.

## Database Overview

The sports telecast database supports a comprehensive sports streaming platform with the following key features:

- **User Management**: Authentication, profiles, and preferences
- **Sports & Teams**: Multiple sports with team information and branding
- **Events & Matches**: Tournaments, leagues, and individual matches
- **Live Streaming**: Stream URLs, quality options, and viewer tracking
- **Fan Engagement**: Emoji reactions, live chat, and real-time interactions
- **Match Data**: Scores, events, statistics, lineups, and highlights
- **Analytics**: Viewer sessions, engagement metrics, and historical data

## Database Schema

### Core Tables

#### Users & Authentication
- `users` - User accounts and authentication data
- `user_preferences` - User preferences and personalization settings

#### Sports Data
- `sports` - Available sports types (football, basketball, tennis, etc.)
- `teams` - Teams with logos, colors, and sport associations
- `events` - Sports events, tournaments, and competitions
- `matches` - Individual matches within events

#### Match Details
- `match_scores` - Current and historical match scores
- `match_events` - Match events (goals, cards, substitutions)
- `match_statistics` - Real-time match statistics
- `match_lineups` - Team lineups and formations

#### Media & Streaming
- `highlights` - Match highlights and video content
- `stream_qualities` - Available streaming quality options per match

#### Fan Engagement
- `emoji_assets` - Available emoji types for reactions
- `emoji_reactions` - User emoji reactions during events
- `emoji_reaction_summary` - Aggregated reaction counts for performance
- `chat_messages` - Live chat messages during events

#### Analytics
- `viewer_sessions` - User viewing sessions for analytics
- `viewer_count_snapshots` - Historical viewer count data

## Database Connection

The database runs on PostgreSQL with the following default configuration:

- **Host**: localhost
- **Port**: 5000
- **Database**: myapp
- **User**: appuser
- **Password**: dbuser123

Connection string: `postgresql://appuser:dbuser123@localhost:5000/myapp`

## Setup Instructions

### 1. Start PostgreSQL Server

Run the startup script to initialize and start PostgreSQL:

```bash
./startup.sh
```

This script will:
- Initialize PostgreSQL if not already done
- Start the PostgreSQL server on port 5000
- Create the database and user with proper permissions
- Save connection information to `db_connection.txt`

### 2. Run Database Migrations

Use the database management script to set up the schema and seed data:

```bash
# Make the script executable
chmod +x manage_db.sh

# Run all migrations
./manage_db.sh migrate
```

### 3. Verify Setup

Check the database status:

```bash
./manage_db.sh status
```

## Migration Files

### `migrations/013_create_user_table.sql`
Creates a singular table named "user" with:
- id SERIAL PRIMARY KEY
- email (unique), username (unique), password_hash
- full_name, avatar_url
- role (default 'user'), preferences JSONB
- is_active, created_at, updated_at
Includes indices on email and username and a trigger to auto-update updated_at.
Note: The existing schema also uses a pluralized "users" table in other contexts; both can coexist.

### `migrations/001_initial_schema.sql`
Creates the complete database schema including:
- All tables with proper relationships
- Indexes for performance optimization
- Triggers for automatic timestamp updates
- Custom functions for emoji reaction aggregation
- Comments for documentation

### `migrations/002_seed_data.sql`
Populates the database with initial data:
- Sports types (football, basketball, tennis, etc.)
- Emoji assets for user reactions
- Sample teams (Arsenal, Chelsea, Liverpool, etc.)
- Sample events (Premier League, Champions League, La Liga)
- Live match data matching frontend mock data
- Test users and sample interactions

## Database Management

The `manage_db.sh` script provides several commands:

```bash
# Run migrations
./manage_db.sh migrate

# Show database status
./manage_db.sh status

# Create backup
./manage_db.sh backup

# Reset database (WARNING: Deletes all data)
./manage_db.sh reset

# Show help
./manage_db.sh help
```

## Data Mapping from Frontend Mock Data

The database schema maps directly to the frontend mock data categories:

### Match Data (App.js)
- `matches` table stores current match information
- `match_scores` table stores live scores
- `teams` table stores team information

### Sports Cards (SportsCards.js)
- `matches` table with filtering and pagination
- `events` table for competition information
- `highlights` table for thumbnails and media

### Live Streaming (VideoPlayer.js)
- `matches.stream_url` for main video source
- `stream_qualities` table for quality options
- `viewer_sessions` for analytics

### Emoji Reactions (VideoPlayer.js)
- `emoji_assets` table for available emojis
- `emoji_reactions` table for user reactions
- `emoji_reaction_summary` table for aggregated counts

### Match Statistics (AnalyticsPanel.js)
- `match_statistics` table for live stats
- `match_events` table for timeline events

### Chat Messages (AnalyticsPanel.js)
- `chat_messages` table for live chat
- `users` table for user information

### Schedules (AnalyticsPanel.js)
- `matches` table with status filtering
- `events` table for competition information

### Team Lineups (MatchSummary.js)
- `match_lineups` table with JSONB player data
- Formation and player position information

## API Integration

The database schema is designed to work seamlessly with the existing FastAPI backend endpoints:

- `/matches/*` - Match data and statistics
- `/matches/events/*` - Event and tournament data
- `/fan-engagement/emoji/*` - Emoji reactions
- `/highlights/*` - Match highlights
- `/auth/*` - User authentication
- WebSocket connections for real-time updates

## Performance Optimizations

### Indexes
- All primary keys and foreign keys are indexed
- Status fields (`matches.status`, `users.is_active`) are indexed
- Time-based queries (`matches.start_time`, `emoji_reactions.created_at`) are indexed
- Search fields are indexed with trigram support

### Aggregation Tables
- `emoji_reaction_summary` provides pre-aggregated reaction counts
- `viewer_count_snapshots` stores historical viewer data
- Triggers automatically maintain summary data

### JSONB Usage
- `user_preferences.notification_settings` for flexible preferences
- `teams.colors` for team branding information
- `match_lineups.players` for complex player data
- `emoji_assets.sound_config` for reaction sound settings

## Environment Variables

The database can be configured using environment variables:

```bash
export POSTGRES_URL="postgresql://localhost:5000/myapp"
export POSTGRES_USER="appuser" 
export POSTGRES_PASSWORD="dbuser123"
export POSTGRES_DB="myapp"
export POSTGRES_PORT="5000"
```

These variables are automatically set by the startup script and saved to `db_visualizer/postgres.env`.

## Database Visualization

The `db_visualizer` directory contains a Node.js application for viewing database contents:

```bash
cd db_visualizer
npm install
npm start
```

This provides a web interface at `http://localhost:3000` for exploring the database structure and data.

## Backup and Recovery

### Creating Backups
```bash
# Using the management script
./manage_db.sh backup

# Manual backup
pg_dump -h localhost -p 5000 -U appuser -d myapp > backup.sql
```

### Restoring from Backup
```bash
# Reset database first
./manage_db.sh reset

# Restore from backup
PGPASSWORD=dbuser123 psql -h localhost -p 5000 -U appuser -d myapp < backup.sql
```

## Troubleshooting

### Connection Issues
1. Ensure PostgreSQL is running: `./startup.sh`
2. Check port availability: `netstat -an | grep 5000`
3. Verify user permissions in PostgreSQL logs

### Migration Issues
1. Check migration history: `./manage_db.sh status`
2. Reset database if needed: `./manage_db.sh reset`
3. Re-run migrations: `./manage_db.sh migrate`

### Performance Issues
1. Check index usage with `EXPLAIN ANALYZE`
2. Monitor slow queries in PostgreSQL logs
3. Consider adding additional indexes for specific query patterns

## Security Considerations

- Database user has limited permissions (no superuser access)
- Passwords should be changed in production environments
- Consider SSL connections for production deployments
- Implement proper backup encryption for sensitive data

## Development Notes

- The schema supports both live and historical data
- JSONB fields provide flexibility for evolving data structures
- Triggers maintain data consistency automatically
- The design supports horizontal scaling with proper partitioning

## Docker initialization scripts

The official Postgres image runs any .sql files in docker-entrypoint-initdb.d/ on first-time container initialization. This repository includes:
- docker-entrypoint-initdb.d/01_widen_alembic_version.sql

Behavior of the alembic_version patch:
- If public.alembic_version or the version_num column does not exist, it does nothing.
- If version_num is already VARCHAR with length >= 64 (or unbounded), it does nothing.
- Otherwise, it alters the column to VARCHAR(64).

This script is idempotent and safe to keep in source control. It prevents migration failures when revision identifiers exceed the previous column length.

## Next Steps

1. **Backend Integration**: Update FastAPI models to use database instead of mock data
2. **Real-time Updates**: Implement WebSocket connections for live data
3. **Performance Monitoring**: Set up query performance monitoring
4. **Data Validation**: Add additional constraints and validation rules
5. **Scaling**: Consider read replicas and connection pooling for production
