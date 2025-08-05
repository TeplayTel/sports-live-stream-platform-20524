# Backend Query Optimization Guidelines: Sports Telecast DB

## Overview

This file documents best-practices for backend developers integrating with the sports telecast PostgreSQL database to avoid inefficient queries and bottlenecks.

---

## 1. Common Inefficient Query Patterns (to avoid)

### N+1 Query Problem (Backend Loops)
**Anti-pattern:**

```python
for match in matches:
    team = get_team(match.team_id)   # Triggers separate query for each
```

**Fix**:  
Use SQL JOINs or `IN` clauses to fetch all necessary data in one query.

### Fetch-all + Filter-in-Python

**Anti-pattern:**
```python
matches = db.query("SELECT * FROM matches")      # Fetches all rows!
filtered = [m for m in matches if m["status"] == "live"]
```

**Fix**:  
```sql
SELECT * FROM matches WHERE status = 'live';
```

---

## 2. Recommendations for API Query Design

- **Always filter at query level**  
  Use SQL WHERE clauses and proper LIMIT/OFFSET for pagination.
- **JOIN for display lists**  
  If you need UI details for matches/teams/players, join relevant tables and fetch all columns at once.
- **Aggregations**  
  Use the `emoji_reaction_summary` and `viewer_count_snapshots` tables for fast metrics — don't aggregate emoji_reactions or viewer_sessions on-the-fly for trending stats.
- **Field selection**  
  Only request columns needed for the API response. Use `SELECT col1, col2` instead of `SELECT *`.

---

## 3. Logging and Analyzing Inefficient Queries

- Use the PostgreSQL slow query logs (see `db_slow_query_monitoring.md`) to observe queries >200ms.
- In API code, log the response time for each request and record queries taking over 300ms as warning level in the backend logs.
- When you spot a slow query, run it with `EXPLAIN ANALYZE` in psql and look for:
  - Sequential scan on large table? (missing index)
  - Multiple nested loops with many rows? (bad join/filter)
- If you must run a complex aggregation, consider:
  - Creating a summary/rollup table with a trigger (several already exist).

---

## 4. Example Query Improvements

**Original Inefficient Query** (e.g. fetching all emoji_reactions for a match and counting in Python):

```python
# SLOW: Fetches 10,000+ rows if match is popular
rows = db.query("SELECT * FROM emoji_reactions WHERE match_id = %s", (match_id,))
summary = {}
for r in rows:
    # Python-side counting...
```

**Better: Let DB count and group**

```sql
SELECT emoji_id, COUNT(*) as reaction_count
FROM emoji_reactions
WHERE match_id = 'MATCH001'
GROUP BY emoji_id;
```
Or use pre-aggregated `emoji_reaction_summary` for instant results.

---

## 5. Schema and Index Reference

- All primary/foreign key columns and major filter columns are indexed.
- For filtering by status, time, event, user, emoji — always use the index.
- If your use-case has new, repeated filter patterns not covered, propose a schema index change rather than working around it in Python.

---

## 6. Refactoring Inefficient Backend Code

- Refactor Python or Node.js backend queries to use bulk or set-based operations.
- Avoid ORM lazy-loading in high-cardinality data.
- Document in backend code with comments: if a particular endpoint has known perf issues, describe the workaround/proposed refactor.

---

## 7. When to Involve DBAs

- If you observe unavoidable long queries after EXPLAINing and adding appropriate indexes, escalate to a DBA to discuss schema or hardware changes.

---

## 8. References

- [SQLAlchemy Optimization Patterns](https://docs.sqlalchemy.org/en/14/orm/tutorial.html#selecting)
- [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html)
- [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html)

---

> **Key Point:** Profile your queries, leverage indexes, use set logic in SQL, and read slow query logs regularly. Backend code is often the root cause of database performance bottlenecks!
