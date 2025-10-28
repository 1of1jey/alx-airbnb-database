# Query Optimization Report

## Objective
Optimize a complex SQL query that retrieves all booking records along with user, property, and payment details.

## Step 1: Initial Query
The initial query joined six tables:
- **Booking**
- **users (guest and host)**
- **Property**
- **Location**
- **Payment**

It retrieved all fields and sorted by `b.created_at`.

### Performance Issue
Using `EXPLAIN ANALYZE`, the query showed:
- Sequential scans on large tables.
- Costly `Nested Loop` joins due to lack of proper indexes.
- Sorting on `created_at` without an index caused slow sorting.
- Redundant joins to `host` and `location` tables even when not always required.

**Example output (before optimization):**

