# Partition Performance Report

## Objective
To optimize query performance on the `Booking` table, which contains a large dataset, by implementing **range partitioning** on the `start_date` column.

---

## Implementation
- The `Booking` table was recreated as a **partitioned table** using **RANGE (start_date)**.
- Yearly partitions were created:
  - `Booking_2023`
  - `Booking_2024`
  - `Booking_2025`
  - `Booking_future` (for data beyond 2025)
- Existing data was migrated from `Booking_backup` into the new structure.
- Indexes were added on `start_date` and `status` columns within partitions.

---

## Performance Testing

### Query Tested
```sql
SELECT * FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND status = 'confirmed';
