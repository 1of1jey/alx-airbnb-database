# Index Performance Analysis

This report evaluates query performance before and after adding indexes
to frequently used columns in the `users`, `Booking`, and `Property` tables.

---

## 1. High-Usage Columns

| Table | Columns Used | Typical Use |
|--------|---------------|-------------|
| users | `user_id`, `email` | JOIN with bookings, login search |
| Booking | `user_id`, `property_id`, `status`, `booking_date` | JOINs, filters, date sorting |
| Property | `property_id`, `host_id`, `price_per_night` | JOINs, filters, price sorting |

---

## 2. Performance Measurement Method

We used PostgreSQL’s `EXPLAIN ANALYZE` command to measure query performance:

```sql
-- Before adding indexes
EXPLAIN ANALYZE
SELECT u.first_name, u.last_name, COUNT(b.booking_id)
FROM "users" u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.status = 'confirmed'
GROUP BY u.user_id;

-- After adding indexes
EXPLAIN ANALYZE
SELECT u.first_name, u.last_name, COUNT(b.booking_id)
FROM "users" u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.status = 'confirmed'
GROUP BY u.user_id;
