# Database Performance Monitoring and Optimization

## Objective
Continuously monitor and refine database performance by analyzing query execution plans and applying schema or index improvements to reduce query execution time.

---

## 1. Monitoring Tools Used

### EXPLAIN ANALYZE
Used to view the query execution plan, row scans, index usage, and total execution time.

### SHOW PROFILE (optional in MySQL)
In PostgreSQL (used for this project), EXPLAIN ANALYZE provides similar functionality by displaying each step’s timing and cost.

---

## 2. Queries Monitored

### **Query 1: Retrieve all confirmed bookings for a given user**
```sql
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_amount,
    p.name AS property_name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = 1024
  AND b.status = 'confirmed';
