EXPLAIN ANALYZE
SELECT
    b.booking_id,
    b.booking_date,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    pay.payment_id,
    pay.amount,
    pay.payment_status
FROM Booking b
JOIN "users" u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
  AND p.is_active = TRUE
  AND pay.payment_status = 'successful'
ORDER BY b.booking_date DESC;


EXPLAIN ANALYZE
SELECT
    b.booking_id,
    b.booking_date,
    u.first_name || ' ' || u.last_name AS full_name,
    p.name AS property_name,
    pay.amount
FROM Booking b
INNER JOIN "users" u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
  AND p.is_active = TRUE
  AND pay.payment_status = 'successful'
ORDER BY b.booking_date DESC;



