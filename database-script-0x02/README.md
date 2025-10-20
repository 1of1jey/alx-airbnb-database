# Database Seed Data

## Overview

SQL script to populate the Airbnb database with minimal sample data for testing (one record per table).

## Sample Data

### Users (3 records)

- **Admin**: barbara sackey (barbara.sackey@email.com)
- **Host**: Jeffrey eshun (jeffrey.eshun@email.com)
- **Guest**: Alice Williams (alice.w@email.com)

**Password for all users**: `password123`

### Other Records (1 each)

- **Location**: 123 Broadway, New York, NY
- **Property**: Luxury Manhattan Loft ($250/night, owned by John)
- **Booking**: Alice books the loft, Dec 20-25, 2024 ($1,250 total)
- **Payment**: Credit card payment for $1,250
- **Review**: 5-star review from Alice
- **Message**: Alice inquires about booking

## Installation

```bash
# Run schema first (if needed)
psql -d airbnb_db -f ../database-script-0x01/schema.sql

# Load sample data
psql -d airbnb_db -f seed.sql
```

## Verification

```sql
-- Check all tables
SELECT 'Users' as table_name, COUNT(*) FROM "User"
UNION ALL SELECT 'Locations', COUNT(*) FROM Location
UNION ALL SELECT 'Properties', COUNT(*) FROM Property
UNION ALL SELECT 'Bookings', COUNT(*) FROM Booking
UNION ALL SELECT 'Payments', COUNT(*) FROM Payment
UNION ALL SELECT 'Reviews', COUNT(*) FROM Review
UNION ALL SELECT 'Messages', COUNT(*) FROM Message;
```

## Sample Queries

### View Property Details

```sql
SELECT p.name, p.pricepernight, l.city, u.first_name || ' ' || u.last_name AS host
FROM Property p
JOIN Location l ON p.location_id = l.location_id
JOIN "User" u ON p.host_id = u.user_id;
```

### View Booking with Payment

```sql
SELECT b.booking_id, p.name, b.total_price, pay.payment_method, b.status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN Payment pay ON pay.booking_id = b.booking_id;
```

### View Reviews

```sql
SELECT r.rating, r.comment, p.name AS property, u.first_name AS reviewer
FROM Review r
JOIN Property p ON r.property_id = p.property_id
JOIN "User" u ON r.user_id = u.user_id;
```

## Reset Data

```bash
# Clear and reload
psql -d airbnb_db -f seed.sql
```

## Notes

- All IDs use UUID format
- Passwords are bcrypt hashed
- Data respects all foreign key constraints
- Insert order: User → Location → Property → Booking → Payment → Review → Message
