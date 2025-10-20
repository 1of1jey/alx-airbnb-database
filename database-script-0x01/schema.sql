DROP TABLE IF EXISTS Message CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Property CASCADE;
DROP TABLE IF EXISTS Location CASCADE;
DROP TABLE IF EXISTS User CASCADE;


CREATE TABLE User (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('guest', 'host', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);

COMMENT ON TABLE User IS 'Stores all user accounts including guests, hosts, and administrators';
COMMENT ON COLUMN User.user_id IS 'Unique identifier for each user';
COMMENT ON COLUMN User.email IS 'User email address, must be unique';
COMMENT ON COLUMN User.role IS 'User role: guest, host, or admin';


CREATE TABLE Location (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    street_address VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_latitude CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT chk_longitude CHECK (longitude >= -180 AND longitude <= 180)
);

CREATE INDEX idx_location_city ON Location(city);
CREATE INDEX idx_location_state ON Location(state);
CREATE INDEX idx_location_country ON Location(country);
CREATE INDEX idx_location_coords ON Location(latitude, longitude);

-- Comments for Location table
COMMENT ON TABLE Location IS 'Normalized location data for properties';
COMMENT ON COLUMN Location.latitude IS 'Latitude coordinate (-90 to 90)';
COMMENT ON COLUMN Location.longitude IS 'Longitude coordinate (-180 to 180)';


CREATE TABLE Property (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID NOT NULL,
    location_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_property_host FOREIGN KEY (host_id) 
        REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_property_location FOREIGN KEY (location_id) 
        REFERENCES Location(location_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_pricepernight CHECK (pricepernight > 0)
);

CREATE INDEX idx_property_host ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location_id);
CREATE INDEX idx_property_price ON Property(pricepernight);
CREATE INDEX idx_property_created ON Property(created_at);

-- Trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_property_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_property_updated_at
    BEFORE UPDATE ON Property
    FOR EACH ROW
    EXECUTE FUNCTION update_property_updated_at();

COMMENT ON TABLE Property IS 'Property listings created by hosts';
COMMENT ON COLUMN Property.pricepernight IS 'Price per night in decimal format (must be positive)';



CREATE TABLE Booking (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_booking_property FOREIGN KEY (property_id) 
        REFERENCES Property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) 
        REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_total_price CHECK (total_price > 0)
);

-- Indexes for Booking table
CREATE INDEX idx_booking_property ON Booking(property_id);
CREATE INDEX idx_booking_user ON Booking(user_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_created ON Booking(created_at);

-- Comments for Booking table
COMMENT ON TABLE Booking IS 'Stores all booking/reservation records';
COMMENT ON COLUMN Booking.status IS 'Booking status: pending, confirmed, or canceled';
COMMENT ON COLUMN Booking.total_price IS 'Total price for the entire booking period';



CREATE TABLE Payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'stripe')),
    
    -- Foreign Keys
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) 
        REFERENCES Booking(booking_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

-- Indexes for Payment table
CREATE INDEX idx_payment_booking ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Comments for Payment table
COMMENT ON TABLE Payment IS 'Payment transaction records for bookings';
COMMENT ON COLUMN Payment.payment_method IS 'Payment method: credit_card, paypal, or stripe';



CREATE TABLE Review (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_review_property FOREIGN KEY (property_id) 
        REFERENCES Property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) 
        REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT uq_user_property_review UNIQUE (property_id, user_id)
);

CREATE INDEX idx_review_property ON Review(property_id);
CREATE INDEX idx_review_user ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created ON Review(created_at);

-- Comments for Review table
COMMENT ON TABLE Review IS 'User reviews and ratings for properties';
COMMENT ON COLUMN Review.rating IS 'Rating from 1 to 5 stars';
COMMENT ON CONSTRAINT uq_user_property_review ON Review IS 'One review per user per property';



CREATE TABLE Message (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) 
        REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_message_recipient FOREIGN KEY (recipient_id) 
        REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id)
);