EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.user_id AS guest_id,
    guest.first_name AS guest_first_name,
    guest.last_name AS guest_last_name,
    guest.email AS guest_email,
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    l.city,
    l.state,
    l.country,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM Booking b
INNER JOIN "users" guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN "users" host ON p.host_id = host.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;


EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    p.name AS property_name,
    pay.amount AS payment_amount,
    pay.payment_method
FROM Booking b
INNER JOIN "users" u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC;



CREATE INDEX IF NOT EXISTS idx_booking_status_created ON Booking(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_booking_user_property ON Booking(user_id, property_id);
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX IF NOT EXISTS idx_property_name ON Property(name);

