Database Schema Scripts
Overview
This directory contains SQL scripts for creating and managing the Airbnb database schema. The schema is designed to support a full-featured property rental platform with users, properties, bookings, payments, reviews, and messaging.
Files
schema.sql
Complete database schema definition including:

Table creation statements
Primary and foreign key constraints
Check constraints for data validation
Indexes for performance optimization
Database views for common queries
Triggers for automatic timestamp updates

Database Structure
Tables
1. User
Stores all user accounts (guests, hosts, and administrators).
Columns:

user_id (UUID, PK) - Unique identifier
first_name (VARCHAR) - User's first name
last_name (VARCHAR) - User's last name
email (VARCHAR, UNIQUE) - Email address with format validation
password_hash (VARCHAR) - Hashed password
phone_number (VARCHAR, NULL) - Optional phone number
role (VARCHAR) - User role: 'guest', 'host', or 'admin'
created_at (TIMESTAMP) - Account creation timestamp

Indexes:

Primary key on user_id
Unique index on email
Index on role


2. Location
Normalized location data for properties (3NF compliant).
Columns:

location_id (UUID, PK) - Unique identifier
street_address (VARCHAR) - Street address
city (VARCHAR) - City name
state (VARCHAR) - State/province
country (VARCHAR) - Country name
postal_code (VARCHAR) - Postal/ZIP code
latitude (DECIMAL) - Geographic latitude (-90 to 90)
longitude (DECIMAL) - Geographic longitude (-180 to 180)
created_at (TIMESTAMP) - Record creation timestamp

Indexes:

Primary key on location_id
Index on city
Index on state
Index on country
Composite index on latitude, longitude (for geospatial queries)

Constraints:

Latitude must be between -90 and 90
Longitude must be between -180 and 180


3. Property
Property listings created by hosts.
Columns:

property_id (UUID, PK) - Unique identifier
host_id (UUID, FK) - References User(user_id)
location_id (UUID, FK) - References Location(location_id)
name (VARCHAR) - Property name
description (TEXT) - Detailed description
pricepernight (DECIMAL) - Price per night (must be positive)
created_at (TIMESTAMP) - Listing creation timestamp
updated_at (TIMESTAMP) - Last update timestamp (auto-updated)

Indexes:

Primary key on property_id
Index on host_id
Index on location_id
Index on pricepernight
Index on created_at

Relationships:

Belongs to User (host)
Belongs to Location
Has many Bookings
Has many Reviews

Special Features:

Auto-updating updated_at trigger
Cascade delete when host is deleted


4. Booking
Reservation records for properties.
Columns:

booking_id (UUID, PK) - Unique identifier
property_id (UUID, FK) - References Property(property_id)
user_id (UUID, FK) - References User(user_id)
start_date (DATE) - Check-in date
end_date (DATE) - Check-out date
total_price (DECIMAL) - Total booking price
status (VARCHAR) - 'pending', 'confirmed', or 'canceled'
created_at (TIMESTAMP) - Booking creation timestamp

Indexes:

Primary key on booking_id
Index on property_id
Index on user_id
Index on status
Composite index on start_date, end_date
Index on created_at

Constraints:

end_date must be after start_date
total_price must be positive

Relationships:

Belongs to Property
Belongs to User (guest)
Has one Payment


5. Payment
Payment transaction records.
Columns:

payment_id (UUID, PK) - Unique identifier
booking_id (UUID, FK, UNIQUE) - References Booking(booking_id)
amount (DECIMAL) - Payment amount
payment_date (TIMESTAMP) - Transaction timestamp
payment_method (VARCHAR) - 'credit_card', 'paypal', or 'stripe'

Indexes:

Primary key on payment_id
Unique index on booking_id
Index on payment_method
Index on payment_date

Constraints:

amount must be positive
One-to-one relationship with Booking (UNIQUE constraint)

Relationships:

Belongs to Booking (one-to-one)


6. Review
Property reviews and ratings from guests.
Columns:

review_id (UUID, PK) - Unique identifier
property_id (UUID, FK) - References Property(property_id)
user_id (UUID, FK) - References User(user_id)
rating (INTEGER) - Rating from 1 to 5
comment (TEXT) - Review text
created_at (TIMESTAMP) - Review creation timestamp

Indexes:

Primary key on review_id
Index on property_id
Index on user_id
Index on rating
Index on created_at

Constraints:

rating must be between 1 and 5
Unique constraint on (property_id, user_id) - one review per user per property

Relationships:

Belongs to Property
Belongs to User


7. Message
Messages exchanged between users.
Columns:

message_id (UUID, PK) - Unique identifier
sender_id (UUID, FK) - References User(user_id)
recipient_id (UUID, FK) - References User(user_id)
message_body (TEXT) - Message content
sent_at (TIMESTAMP) - Message timestamp

Indexes:

Primary key on message_id
Index on sender_id
Index on recipient_id
Index on sent_at
Composite index on (sender_id, recipient_id, sent_at) for conversation queries

Constraints:

sender_id must differ from recipient_id

Relationships:

Belongs to User (sender)
Belongs to User (recipient)


Database Views
vw_property_details
Combines property, host, and location information for easy querying.
Columns:

All property details
Host name and email
Complete location information
Geographic coordinates

Use Case: Display property listings with full details

vw_booking_summary
Aggregates booking information with property and guest details.
Columns:

Booking details
Property name
Guest name and email
Booking status

Use Case: Dashboard views, booking management

Installation
Prerequisites

PostgreSQL 12+ (recommended)
Database user with CREATE privileges
psql client or database management tool

Steps

Create Database

bash   createdb airbnb_db

Run Schema Script

bash   psql -d airbnb_db -f schema.sql

Verify Installation

sql   -- Connect to database
   \c airbnb_db
   
   -- List all tables
   \dt
   
   -- View table structure
   \d User
   \d Property
MySQL Adaptation
If using MySQL instead of PostgreSQL, make these changes:

Replace gen_random_uuid() with UUID()
Replace VARCHAR with appropriate sizes
Adjust TIMESTAMP to DATETIME if needed
Replace regex check ~* with REGEXP
Remove CASCADE keywords from DROP statements


Key Features
Security

Password stored as hash only
Email format validation
Role-based access control structure
Foreign key constraints for referential integrity

Performance Optimization

Strategic indexing on foreign keys
Composite indexes for common query patterns
Indexes on frequently filtered columns (status, dates, ratings)
Database views for complex joins

Data Integrity

CHECK constraints for value validation
NOT NULL constraints on required fields
UNIQUE constraints to prevent duplicates
Foreign key constraints with CASCADE/RESTRICT options
Trigger for automatic timestamp updates

Normalization

Third Normal Form (3NF) compliant
Normalized Location table
Elimination of data redundancy
Justified denormalization for business requirements (total_price, amount)


Foreign Key Relationships
User (1) ──────────< (Many) Property [host_id]
User (1) ──────────< (Many) Booking [user_id]
User (1) ──────────< (Many) Review [user_id]
User (1) ──────────< (Many) Message [sender_id]
User (1) ──────────< (Many) Message [recipient_id]

Location (1) ──────< (Many) Property [location_id]

Property (1) ──────< (Many) Booking [property_id]
Property (1) ──────< (Many) Review [property_id]

Booking (1) ────── (One) Payment [booking_id]

Performance Considerations
Index Strategy

All primary keys automatically indexed
Foreign keys indexed for JOIN performance
Common filter columns indexed (email, status, rating)
Date range queries optimized with composite indexes
Geospatial queries supported via latitude/longitude index

Query Optimization Tips

Use views for complex, frequently-run queries
Leverage indexes in WHERE clauses
Consider query plans for large datasets
Monitor slow query logs
Add additional indexes based on actual usage patterns


Maintenance
Regular Tasks

Vacuum (PostgreSQL): Reclaim storage

sql   VACUUM ANALYZE;

Index Maintenance: Rebuild if needed

sql   REINDEX DATABASE airbnb_db;

Statistics Update: Keep query planner informed

sql   ANALYZE;
Backup Strategy
bash# Full backup
pg_dump airbnb_db > backup_$(date +%Y%m%d).sql

# Restore
psql airbnb_db < backup_20241020.sql

Future Enhancements
Potential schema additions:

Property amenities (many-to-many)
Property images table
User verification status
Booking cancellation policies
Notification preferences
Favorites/Wishlist (many-to-many)
Property availability calendar
