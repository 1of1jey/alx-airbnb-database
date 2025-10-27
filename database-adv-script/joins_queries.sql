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
    "User" u ON b.user_id = u.user_id
ORDER BY 
    b.created_at DESC;


-- Enhanced INNER JOIN: Include property details as well
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    p.property_id,
    p.name AS property_name,
    p.pricepernight
FROM 
    Booking b
INNER JOIN 
    "User" u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
ORDER BY 
    b.created_at DESC;


SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_price,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS last_booking_date
FROM 
    "User" u
INNER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
HAVING 
    COUNT(b.booking_id) > 0
ORDER BY 
    total_bookings DESC;


SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
ORDER BY 
    p.property_id, r.created_at DESC;


SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date,
    u.first_name AS reviewer_first_name,
    u.last_name AS reviewer_last_name,
    u.email AS reviewer_email
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
LEFT JOIN 
    "User" u ON r.user_id = u.user_id
ORDER BY 
    p.property_id, r.created_at DESC;

SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS average_rating,
    MAX(r.created_at) AS latest_review_date,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'No Reviews'
        WHEN AVG(r.rating) >= 4.5 THEN 'Excellent'
        WHEN AVG(r.rating) >= 4.0 THEN 'Very Good'
        WHEN AVG(r.rating) >= 3.0 THEN 'Good'
        ELSE 'Fair'
    END AS rating_category
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name, p.pricepernight
ORDER BY 
    average_rating DESC NULLS LAST, total_reviews DESC;


SELECT 
    p.property_id,
    p.name AS property_name,
    p.pricepernight,
    p.created_at AS listed_date,
    u.first_name AS host_first_name,
    u.last_name AS host_last_name
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
LEFT JOIN 
    "User" u ON p.host_id = u.user_id
WHERE 
    r.review_id IS NULL
ORDER BY 
    p.created_at DESC;

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_date
FROM 
    "User" u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
ORDER BY 
    u.user_id NULLS LAST, b.created_at DESC;


SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.total_price,
    b.status,
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
    u.user_id IS NULL OR b.booking_id IS NULL
ORDER BY 
    record_type, u.user_id NULLS LAST;


SELECT 
    COALESCE(u.user_id::TEXT, 'No User') AS user_id,
    COALESCE(u.first_name, 'Unknown') AS first_name,
    COALESCE(u.last_name, 'Unknown') AS last_name,
    COALESCE(u.email, 'No Email') AS email,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.total_price), 0) AS total_spent,
    COALESCE(AVG(b.total_price), 0) AS average_booking_price,
    MAX(b.start_date) AS last_booking_date
FROM 
    "User" u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY 
    total_bookings DESC;

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    -- Guest Information
    guest.first_name AS guest_first_name,
    guest.last_name AS guest_last_name,
    guest.email AS guest_email,
    -- Property Information
    p.name AS property_name,
    p.pricepernight,
    -- Host Information
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    -- Location Information
    l.city,
    l.state,
    l.country,
    -- Payment Information
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM 
    Booking b
INNER JOIN "User" guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN "User" host ON p.host_id = host.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.created_at DESC;


SELECT DISTINCT
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    'Guest & Host' AS user_type
FROM 
    "User" u
INNER JOIN Booking b ON u.user_id = b.user_id
INNER JOIN Property p ON u.user_id = p.host_id
ORDER BY 
    u.first_name, u.last_name;


SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(DISTINCT b.user_id) AS unique_guests,
    COUNT(b.booking_id) AS total_bookings,
    AVG(r.rating) AS average_rating
FROM 
    Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name
HAVING 
    COUNT(b.booking_id) > 0
ORDER BY 
    total_bookings DESC, average_rating DESC NULLS LAST;


