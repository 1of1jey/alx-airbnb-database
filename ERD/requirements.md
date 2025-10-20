# Airbnb Database Requirements

## Project Overview
This document outlines the database requirements for the Airbnb clone application. The database is designed to support core functionalities including user management, property listings, bookings, payments, reviews, and messaging.

## Entities and Attributes

### User
Represents all users in the system (guests, hosts, and administrators).

**Attributes:**
- `user_id`: Primary Key, UUID, Indexed
- `first_name`: VARCHAR, NOT NULL
- `last_name`: VARCHAR, NOT NULL
- `email`: VARCHAR, UNIQUE, NOT NULL
- `password_hash`: VARCHAR, NOT NULL
- `phone_number`: VARCHAR, NULL
- `role`: ENUM (`guest`, `host`, `admin`), NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Property
Represents properties listed by hosts.

**Attributes:**
- `property_id`: Primary Key, UUID, Indexed
- `host_id`: Foreign Key, references `User(user_id)`
- `name`: VARCHAR, NOT NULL
- `description`: TEXT, NOT NULL
- `location`: VARCHAR, NOT NULL
- `pricepernight`: DECIMAL, NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at`: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

### Booking
Represents reservations made by users for properties.

**Attributes:**
- `booking_id`: Primary Key, UUID, Indexed
- `property_id`: Foreign Key, references `Property(property_id)`
- `user_id`: Foreign Key, references `User(user_id)`
- `start_date`: DATE, NOT NULL
- `end_date`: DATE, NOT NULL
- `total_price`: DECIMAL, NOT NULL
- `status`: ENUM (`pending`, `confirmed`, `canceled`), NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Payment
Represents payment transactions for bookings.

**Attributes:**
- `payment_id`: Primary Key, UUID, Indexed
- `booking_id`: Foreign Key, references `Booking(booking_id)`
- `amount`: DECIMAL, NOT NULL
- `payment_date`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `payment_method`: ENUM (`credit_card`, `paypal`, `stripe`), NOT NULL

### Review
Represents reviews written by users for properties.

**Attributes:**
- `review_id`: Primary Key, UUID, Indexed
- `property_id`: Foreign Key, references `Property(property_id)`
- `user_id`: Foreign Key, references `User(user_id)`
- `rating`: INTEGER, CHECK: `rating >= 1 AND rating <= 5`, NOT NULL
- `comment`: TEXT, NOT NULL
- `created_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Message
Represents messages exchanged between users.

**Attributes:**
- `message_id`: Primary Key, UUID, Indexed
- `sender_id`: Foreign Key, references `User(user_id)`
- `recipient_id`: Foreign Key, references `User(user_id)`
- `message_body`: TEXT, NOT NULL
- `sent_at`: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

## Relationships

1. **User to Property**: One-to-Many
   - A user (host) can list multiple properties
   - Each property belongs to one host

2. **User to Booking**: One-to-Many
   - A user can make multiple bookings
   - Each booking is made by one user

3. **Property to Booking**: One-to-Many
   - A property can have multiple bookings
   - Each booking is for one property

4. **Booking to Payment**: One-to-One
   - Each booking has one payment
   - Each payment is linked to one booking

5. **User to Review**: One-to-Many
   - A user can write multiple reviews
   - Each review is written by one user

6. **Property to Review**: One-to-Many
   - A property can receive multiple reviews
   - Each review is for one property

7. **User to Message**: One-to-Many (for both sender and recipient)
   - A user can send multiple messages
   - A user can receive multiple messages
   - Each message has one sender and one recipient

## Constraints

### User Table
- `email` must be unique across all users
- `first_name`, `last_name`, `email`, `password_hash`, and `role` are required fields
- `role` must be one of: `guest`, `host`, or `admin`

### Property Table
- `host_id` must reference a valid `user_id` from the User table
- `name`, `description`, `location`, and `pricepernight` are required fields
- `pricepernight` must be a positive decimal value

### Booking Table
- `property_id` must reference a valid `property_id` from the Property table
- `user_id` must reference a valid `user_id` from the User table
- `start_date`, `end_date`, `total_price`, and `status` are required fields
- `status` must be one of: `pending`, `confirmed`, or `canceled`
- `end_date` should be after `start_date` (application-level validation)

### Payment Table
- `booking_id` must reference a valid `booking_id` from the Booking table
- Each booking can only have one payment record
- `amount` must be a positive decimal value
- `payment_method` must be one of: `credit_card`, `paypal`, or `stripe`

### Review Table
- `property_id` must reference a valid `property_id` from the Property table
- `user_id` must reference a valid `user_id` from the User table
- `rating` must be an integer between 1 and 5 (inclusive)
- `comment` is required

### Message Table
- `sender_id` must reference a valid `user_id` from the User table
- `recipient_id` must reference a valid `user_id` from the User table
- `sender_id` and `recipient_id` must be different (application-level validation)
- `message_body` is required

## Indexing Strategy

### Primary Keys
All primary keys are automatically indexed for optimal lookup performance:
- `user_id`
- `property_id`
- `booking_id`
- `payment_id`
- `review_id`
- `message_id`

### Additional Indexes
To optimize common query patterns:
- **User table**: `email` (for login and uniqueness checks)
- **Property table**: `host_id` (for retrieving all properties by a host)
- **Booking table**: `property_id`, `user_id` (for retrieving bookings by property or user)
- **Payment table**: `booking_id` (for retrieving payment information by booking)
- **Review table**: `property_id`, `user_id` (for retrieving reviews by property or user)
- **Message table**: `sender_id`, `recipient_id` (for retrieving messages by sender or recipient)

## Data Types and Standards

- **UUID**: Used for all primary keys to ensure uniqueness across distributed systems
- **VARCHAR**: Variable-length strings for names, emails, etc.
- **TEXT**: Large text fields for descriptions, comments, and message bodies
- **DECIMAL**: For monetary values (prices, amounts) to ensure precision
- **DATE**: For booking dates
- **TIMESTAMP**: For recording creation and update times
- **INTEGER**: For ratings
- **ENUM**: For fields with predefined values (role, status, payment_method)

## Security Considerations

1. **Password Storage**: Only `password_hash` is stored, never plain-text passwords
2. **Email Uniqueness**: Enforced at database level to prevent duplicate accounts
3. **Foreign Key Constraints**: Maintain referential integrity across all relationships
4. **Role-Based Access**: User roles enable permission-based access control

## Future Enhancements

Potential additions to consider:
- Property amenities (many-to-many relationship)
- Property images (one-to-many relationship)
- Booking cancellation policies
- User verification status
- Property availability calendar
- Favorite/saved properties (many-to-many relationship)
- Notification preferences
