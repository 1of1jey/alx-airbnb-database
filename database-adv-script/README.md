# SQL Joins Practice - Airbnb Database

## Overview
This directory contains SQL queries demonstrating different types of joins (INNER JOIN, LEFT JOIN, FULL OUTER JOIN) using the Airbnb database schema.

---

## File Structure

```
database-adv-script/
├── joins_queries.sql          # All SQL join queries
└── README.md                  # This documentation
```

---

## Prerequisites

- PostgreSQL database with Airbnb schema created
- Sample data populated (from `database-script-0x02/seed.sql`)
- Database connection established

---

## Understanding SQL Joins

### Visual Guide

```
Table A          Table B
┌─────┐          ┌─────┐
│  1  │          │  1  │
│  2  │          │  3  │
│  3  │          │  4  │
└─────┘          └─────┘

INNER JOIN:      LEFT JOIN:       RIGHT JOIN:      FULL OUTER JOIN:
┌─────┐          ┌─────┐          ┌─────┐          ┌─────┐
│  1  │          │  1  │          │  1  │          │  1  │
│  3  │          │  2  │ (NULL)   │  3  │          │  2  │ (NULL)
└─────┘          │  3  │          │  4  │ (NULL)   │  3  │
                 └─────┘          └─────┘          │  4  │ (NULL)
                                                   └─────┘
```

---

## 1. INNER JOIN

### Purpose
Returns only records that have matching values in both tables.

### When to Use
- When you only want records that exist in both tables
- Finding relationships that definitely exist
- Data integrity checks

### Query 1.1: Basic Bookings with Users

```sql
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM 
    Booking b
INNER JOIN 
    "User" u ON b.user_id = u.user_id;
```

**What it returns:**
- All bookings that have a valid user
- Excludes orphaned bookings (if any)
- Only shows matched records

**Use Case**: Get a list of all bookings with customer information for reporting.

---

### Query 1.2: Multi-Table INNER JOIN

```sql
SELECT 
    b.booking_id,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    p.pricepernight
FROM 
    Booking b
INNER JOIN "User" u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id;
```

**What it returns:**
- Complete booking information
- Guest details
- Property details
- Only valid bookings with both user and property

**Use Case**: Generate comprehensive booking reports.

---

### Query 1.3: INNER JOIN with Aggregation

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent
FROM 
    "User" u
INNER JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(b.booking_id) > 0;
```

**What it returns:**
- User statistics
- Only users who have made bookings
- Excludes users without bookings

**Use Case**: Identify active customers and their spending patterns.

---

## 2. LEFT JOIN (LEFT OUTER JOIN)

### Purpose
Returns all records from the left table, and matching records from the right table. If no match, NULL values are returned for right table columns.

### When to Use
- When you want all records from the primary table
- Finding records that don't have relationships
- Optional relationships

### Query 2.1: All Properties with Reviews

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id;
```

**What it returns:**
- ALL properties (even without reviews)
- Review details where available
- NULL for review columns if property has no reviews

**Use Case**: Display all properties on website, with reviews if available.

---

### Query 2.2: Properties with Review Statistics

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS average_rating,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'No Reviews'
        WHEN AVG(r.rating) >= 4.5 THEN 'Excellent'
        ELSE 'Good'
    END AS rating_category
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name;
```

**What it returns:**
- ALL properties with statistics
- Properties without reviews show 0 count
- Rating categorization

**Use Case**: Property ranking and categorization.

---

### Query 2.3: Find Properties WITHOUT Reviews

```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
WHERE 
    r.review_id IS NULL;
```

**What it returns:**
- Only properties that have NO reviews
- Useful for identifying new listings

**Use Case**: Target properties that need review solicitation.

---

## 3. FULL OUTER JOIN

### Purpose
Returns all records when there is a match in either left or right table. Returns NULL for non-matching sides.

### When to Use
- Data quality checks
- Finding orphaned records
- Complete data reconciliation

### Query 3.1: All Users and All Bookings

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.start_date,
    b.total_price,
    b.status
FROM 
    "User" u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id;
```

**What it returns:**
- ALL users (including those without bookings)
- ALL bookings (including orphaned ones)
- NULL where no match exists

**Use Case**: Complete user activity audit.

---

### Query 3.2: Identify Data Issues

```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    CASE 
        WHEN u.user_id IS NULL THEN 'Orphaned Booking'
        WHEN b.booking_id IS NULL THEN 'User Without Booking'
        ELSE 'Valid Booking'
    END AS record_type
FROM 
    "User" u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
WHERE 
    u.user_id IS NULL OR b.booking_id IS NULL;
```

**What it returns:**
- Users without bookings
- Bookings without valid users
- Data integrity issues

**Use Case**: Database maintenance and cleanup.

---

### Query 3.3: Complete User Statistics

```sql
SELECT 
    COALESCE(u.user_id::TEXT, 'No User') AS user_id,
    COALESCE(u.first_name, 'Unknown') AS first_name,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.total_price), 0) AS total_spent
FROM 
    "User" u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name;
```

**What it returns:**
- Statistics for ALL users
- Handles NULL values with COALESCE
- Shows 0 for users without bookings

**Use Case**: Complete user engagement metrics.

---

## Running the Queries

### Using psql

```bash
# Connect to database
psql -U postgres -d airbnb_db

# Run all queries
\i database-adv-script/joins_queries.sql

# Run specific query (copy-paste from file)
```

### Using pgAdmin
1. Open pgAdmin
2. Connect to airbnb_db
3. Open Query Tool
4. Load `joins_queries.sql`
5. Execute queries (select and run)

---

## Query Comparison Table

| Join Type | Returns | Use Case | Performance |
|-----------|---------|----------|-------------|
| INNER JOIN | Only matching records | Most common, when match required | Fast |
| LEFT JOIN | All left + matching right | Optional relationships | Medium |
| RIGHT JOIN | All right + matching left | Less common (use LEFT instead) | Medium |
| FULL OUTER JOIN | All from both tables | Data audits, reconciliation | Slower |

---

## Performance Tips

### 1. Use Proper Indexes
```sql
-- Ensure foreign keys are indexed
CREATE INDEX idx_booking_user ON Booking(user_id);
CREATE INDEX idx_booking_property ON Booking(property_id);
CREATE INDEX idx_review_property ON Review(property_id);
```

### 2. Limit Result Sets
```sql
-- Add WHERE clause before joining when possible
SELECT ...
FROM Property p
WHERE p.created_at > '2024-01-01'
LEFT JOIN Review r ON p.property_id = r.property_id;
```

### 3. Use EXPLAIN ANALYZE
```sql
EXPLAIN ANALYZE
SELECT ...
FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id;
```

---

## Common Patterns

### Pattern 1: Find Records Without Relationship
```sql
-- Properties without bookings
SELECT p.*
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE b.booking_id IS NULL;
```

### Pattern 2: Aggregate with Optional Relationship
```sql
-- Users with booking count (including 0)
SELECT 
    u.user_id,
    COUNT(b.booking_id) AS booking_count
FROM "User" u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id;
```

### Pattern 3: Multi-Level Hierarchy
```sql
-- Bookings with property and location
SELECT ...
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN Location l ON p.location_id = l.location_id;
```

---

## Expected Results

### Sample INNER JOIN Output
```
booking_id | first_name | last_name | property_name        | total_price
-----------|------------|-----------|---------------------|------------
uuid-1     | Alice      | Williams  | Manhattan Loft      | 1250.00
uuid-2     | Robert     | Taylor    | Miami Beach Condo   | 1750.00
```

### Sample LEFT JOIN Output
```
property_name        | review_id | rating | comment
---------------------|-----------|--------|------------------
Manhattan Loft       | uuid-1    | 5      | Amazing place!
Miami Beach Condo    | uuid-2    | 4      | Great location
Chicago Apartment    | NULL      | NULL   | NULL
```

### Sample FULL OUTER JOIN Output
```
first_name | last_name | booking_id | record_type
-----------|-----------|------------|--------------------
Alice      | Williams  | uuid-1     | Valid Booking
Bob        | Smith     | NULL       | User Without Booking
NULL       | NULL      | uuid-9     | Orphaned Booking
```

---

## Troubleshooting

### Issue: No results from INNER JOIN
**Solution**: Check if matching records exist in both tables.

### Issue: Too many NULL values in LEFT JOIN
**Solution**: This is expected if many left records don't have matches.

### Issue: FULL OUTER JOIN slow performance
**Solution**: Add indexes on join columns, or use UNION of LEFT and RIGHT joins.

### Issue: Ambiguous column names
**Solution**: Always use table aliases and qualify column names.

---

## Testing Queries

```sql
-- Verify INNER JOIN returns only matches
SELECT COUNT(*) FROM Booking b
INNER JOIN "User" u ON b.user_id = u.user_id;
-- Should equal: SELECT COUNT(*) FROM Booking WHERE user_id IN (SELECT user_id FROM "User");

-- Verify LEFT JOIN returns all left records
SELECT COUNT(DISTINCT p.property_id) FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id;
-- Should equal: SELECT COUNT(*) FROM Property;

-- Verify FULL OUTER JOIN completeness
SELECT COUNT(*) FROM "User" u FULL OUTER JOIN Booking b ON u.user_id = b.user_id;
-- Should equal: (SELECT COUNT(*) FROM "User") + (SELECT COUNT(*) FROM Booking WHERE user_id NOT IN (SELECT user_id FROM "User"));
```

