-- ==========================================================
-- database_index.sql
-- Purpose: Create indexes to improve performance on frequent
--          JOIN, WHERE, and ORDER BY operations.
-- ==========================================================

-- 1. Indexes on "users" table
-- ----------------------------------------------------------
-- Commonly used in JOINs (user_id) and search (email)
CREATE INDEX idx_users_user_id ON "users"(user_id);
CREATE INDEX idx_users_email ON "users"(email);

-- 2. Indexes on "Booking" table
-- ----------------------------------------------------------
-- user_id and property_id are used in JOINs
-- status and booking_date are often used in filters or sorting
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_booking_date ON Booking(booking_date);

-- 3. Indexes on "Property" table
-- ----------------------------------------------------------
-- property_id and host_id are used in JOINs
-- name and price_per_night might be used in search/sorting
CREATE INDEX idx_property_property_id ON Property(property_id);
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_price_per_night ON Property(price_per_night);

-- 4. Optional: Composite Indexes for common combinations
-- ----------------------------------------------------------
-- For frequent queries like:
-- SELECT * FROM Booking WHERE user_id = ? AND status = 'confirmed';
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- For queries filtering properties by host and price
CREATE INDEX idx_property_host_price ON Property(host_id, price_per_night);
