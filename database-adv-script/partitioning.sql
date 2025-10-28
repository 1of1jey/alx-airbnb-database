CREATE TABLE Booking_backup AS
SELECT * FROM Booking;


DROP TABLE IF EXISTS Booking CASCADE;

CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    property_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50),
    total_amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
)
PARTITION BY RANGE (start_date);

CREATE TABLE Booking_2023 PARTITION OF Booking
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE Booking_2024 PARTITION OF Booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE Booking_2025 PARTITION OF Booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Default partition for future years
CREATE TABLE Booking_future PARTITION OF Booking
    FOR VALUES FROM ('2026-01-01') TO (MAXVALUE);

INSERT INTO Booking (booking_id, user_id, property_id, start_date, end_date, status, total_amount, created_at)
SELECT booking_id, user_id, property_id, start_date, end_date, status, total_amount, created_at
FROM Booking_backup;


-- Query BEFORE partitioning (for comparison)
-- (You can run this on Booking_backup)
EXPLAIN ANALYZE
SELECT * FROM Booking_backup
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND status = 'confirmed';

-- Query AFTER partitioning (optimized)
EXPLAIN ANALYZE
SELECT * FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND status = 'confirmed';


-- Indexing start_date and status columns inside partitions
CREATE INDEX IF NOT EXISTS idx_booking_2024_start_date ON Booking_2024(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2024_status ON Booking_2024(status);


