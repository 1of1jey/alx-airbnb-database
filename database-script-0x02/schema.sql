
DELETE FROM Message;
DELETE FROM Review;
DELETE FROM Payment;
DELETE FROM Booking;
DELETE FROM Property;
DELETE FROM Location;
DELETE FROM "User";


INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Admin
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'barbara', 'sackey', 'barbara.sackey@gmail.com', '$2b$10$rQ3Kj9Z3vX.jZqP5X5HqJeK3RzYzY3xY4xY5xY6xY7xY8xY9xYAxY', '+1-555-0100', 'admin', '2023-01-15 10:00:00'),

-- Host
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Jeffrey', 'Eshun', 'jeffrey.eshun@email.com', '$2b$10$rQ3Kj9Z3vX.jZqP5X5HqJeK3RzYzY3xY4xY5xY6xY7xY8xY9xYAxY', '+1-555-0101', 'host', '2023-02-10 09:30:00'),

-- Guest
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'Alice', 'Williams', 'alice.w@email.com', '$2b$10$rQ3Kj9Z3vX.jZqP5X5HqJeK3RzYzY3xY4xY5xY6xY7xY8xY9xYAxY', '+1-555-0201', 'guest', '2023-04-01 08:00:00');


INSERT INTO Location (location_id, street_address, city, state, country, postal_code, latitude, longitude, created_at) VALUES
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', '123 Broadway', 'New York', 'New York', 'USA', '10001', 40.7589, -73.9851, '2023-02-15 10:00:00');


INSERT INTO Property (property_id, host_id, location_id, name, description, pricepernight, created_at, updated_at) VALUES
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', 
'Luxury Manhattan Loft', 
'Stunning 2-bedroom loft in the heart of Manhattan with skyline views. Modern amenities, fully equipped kitchen, and walking distance to Times Square.',
250.00, '2023-02-20 10:00:00', '2023-02-20 10:00:00');


INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 
'2024-12-20', '2024-12-25', 1250.00, 'confirmed', '2024-10-15 14:30:00');



INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 
1250.00, '2024-10-15 14:35:00', 'credit_card');


INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 
5, 'Amazing place! The views were spectacular and the location was perfect. Host was very responsive and helpful. Highly recommend!', 
'2024-12-26 10:00:00');



INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380g11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 
'Hi John, I am interested in booking your Manhattan Loft for December. Is it available?', 
'2024-10-10 09:15:00');



-- Display inserted data summary
DO $$
DECLARE
    user_count INTEGER;
    location_count INTEGER;
    property_count INTEGER;
    booking_count INTEGER;
    payment_count INTEGER;
    review_count INTEGER;
    message_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM "User";
    SELECT COUNT(*) INTO location_count FROM Location;
    SELECT COUNT(*) INTO property_count FROM Property;
    SELECT COUNT(*) INTO booking_count FROM Booking;
    SELECT COUNT(*) INTO payment_count FROM Payment;
    SELECT COUNT(*) INTO review_count FROM Review;
    SELECT COUNT(*) INTO message_count FROM Message;
    
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Sample Data Inserted Successfully';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Users: %', user_count;
    RAISE NOTICE 'Locations: %', location_count;
    RAISE NOTICE 'Properties: %', property_count;
    RAISE NOTICE 'Bookings: %', booking_count;
    RAISE NOTICE 'Payments: %', payment_count;
    RAISE NOTICE 'Reviews: %', review_count;
    RAISE NOTICE 'Messages: %', message_count;
    RAISE NOTICE '===========================================';
END $$;