-- 1. Check query performance before indexing
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM "users" u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.status = 'confirmed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

-- 2. Property ranking query before indexing
EXPLAIN ANALYZE
SELECT
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS property_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY property_rank;

-- ==========================================================
-- CREATE INDEXES TO IMPROVE PERFORMANCE
-- ==========================================================

-- "users" table indexes
CREATE INDEX IF NOT EXISTS idx_users_user_id ON "users"(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON "users"(email);

-- "Booking" table indexes
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);
CREATE INDEX IF NOT EXISTS idx_booking_booking_date ON Booking(booking_date);

-- "Property" table indexes
CREATE INDEX IF NOT EXISTS idx_property_property_id ON Property(property_id);
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);
CREATE INDEX IF NOT EXISTS idx_property_price_per_night ON Property(price_per_night);

-- Composite indexes for frequent combined filters
CREATE INDEX IF NOT EXISTS idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX IF NOT EXISTS idx_property_host_price ON Property(host_id, price_per_night);

-- ==========================================================
-- AFTER INDEX CREATION
-- ==========================================================

-- 3. Re-run same queries to measure performance improvement

-- User bookings query (after indexing)
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM "users" u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.status = 'confirmed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

-- Property ranking query (after indexing)
EXPLAIN ANALYZE
SELECT
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS property_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY property_rank;

