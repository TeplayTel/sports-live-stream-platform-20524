# PostgreSQL Slow Query Logging and Performance Monitoring

## Overview

Optimizing query performance is critical for the sports telecast application's user responsiveness and scalability. PostgreSQL provides powerful slow query logging mechanisms to detect and analyze inefficient database statements.

---

## 1. Enabling Slow Query Logging in PostgreSQL

**Connection:**  
- The database runs on port 5000. Connect as the `postgres` system user or a superuser.

**Setting up logging parameters**:

Add the following configuration to your `postgresql.conf` file (location depends on your installation, usually `/etc/postgresql/<version>/main/postgresql.conf` or `/var/lib/postgresql/data/postgresql.conf`):

```conf
# Log all queries that run for longer than 200ms (adjust as needed)
log_min_duration_statement = 200          # logs queries running >200ms
log_statement = 'none'                    # log only slow queries, not all
log_line_prefix = '%m [%p] %u@%d '        # timestamp, PID, user, database
```

**To reload the configuration:**
```bash
sudo systemctl reload postgresql
# OR if running Docker or custom script, restart the process
```

If you are using the local startup scripts provided:
- Make these changes in the postgresql.conf (or consult hosting provider/container docs for mounting a custom config).

---

## 2. Viewing and Analyzing Slow Queries

PostgreSQL logs are typically stored at:
- `/var/log/postgresql/postgresql-<version>-main.log`
- Or as specified by `log_directory`/`log_filename` in `postgresql.conf`.

To filter slow queries:
```bash
grep duration /var/log/postgresql/postgresql.log
```

Or, to see only truly slow (e.g., >1s) queries:
```bash
cat /var/log/postgresql/postgresql.log | grep -E 'duration: [1-9][0-9]{2,}\.?[0-9]* ms'
```

**Tip:** Always review the execution plan for slow queries.

```sql
EXPLAIN ANALYZE <your-query>;
```

---

## 3. Detecting Inefficient Queries

Typical causes:
- Missing indexes on WHERE/JOIN columns
- N+1 query patterns (especially in backend code, e.g., fetching match+team/player details in a loop)
- Unnecessary full table scans or subqueries

#### Suggestions:
- Use indexes on fields commonly queried (the schema already indexes status, start_time, etc. for matches/events/statistics).
- Pre-aggregate reactions and view counts where possible (as already done in `emoji_reaction_summary`, `viewer_count_snapshots`).

---

## 4. Refactoring Problematic Queries

When a slow query is detected:
1. Use `EXPLAIN ANALYZE` to check if the query uses indexes.
2. If not, consider adding the missing index (ALTER TABLE ... ADD INDEX ...).
3. For frequent filter/aggregation, maintain summary tables and triggers (see how `emoji_reaction_summary` is maintained).
4. In backend API code, avoid repeated in-Python loops with DB queries — prefer `JOIN` or `IN` clauses for bulk fetching.

---

## 5. Integrating Monitoring with the Backend

- For FastAPI (Python backend), consider using [SQLAlchemy's event hooks](https://docs.sqlalchemy.org/en/14/core/events.html) or [asyncpg logging](https://magicstack.github.io/asyncpg/current/api/index.html#logging) to log all slow queries from the Python side as well.
- Use middleware to log query times per request and warn for outliers in the server logs.

---

## 6. Useful SQL for Analytics

- Most IO-bound tables:  
```sql
SELECT relname AS "Table",
       seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC LIMIT 10;
```

- Detect long running queries (from active sessions):  
```sql
SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
FROM pg_stat_activity
WHERE state='active' AND (now() - query_start) > interval '500 ms';
```

---

## 7. Regular Maintenance

- Run `VACUUM ANALYZE` regularly to keep query planner stats accurate.
- Use `pg_stat_statements` extension for historical query analysis:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;
```

---

## 8. Further Optimization Steps

- Add application-level monitoring (e.g., APM like NewRelic, Datadog) for end-to-end detection if needed.
- If INSERT-heavy, batch writes and commit in groups.
- If many concurrent streaming viewers: ensure `viewer_sessions` and `viewer_count_snapshots` are partitioned or indexed on `match_id`.

---

> **Summary**: Use PostgreSQL slow query logging, review logs regularly, index access patterns, and work with backend developers to refactor inefficient query code!  
> Backend optimization often requires both database schema work and API/business-logic refactoring.
