
**Analysis:**
-  **1NF**: All attributes are atomic
-  **2NF**: All attributes depend on property_id
-  **3NF Issue Identified**: The `location` attribute is too generic

**Problem**: The `location` field stores an entire address as a single string (e.g., "123 Main St, New York, NY, 10001, USA"). This violates atomicity and creates potential issues:
- Difficult to search by city, state, or country
- Inconsistent formatting
- Poor indexing performance for location-based queries

**Solution - Normalize Location:**

Create a separate Location table:

```sql
Location (
    location_id (PK),
    street_address,
    city,
    state,
    country,
    postal_code,
    latitude,
    longitude
)

Property (
    property_id (PK),
    host_id (FK),
    location_id (FK),
    name,
    description,
    pricepernight,
    created_at,
    updated_at
)
```

**Benefits:**
- Enables efficient location-based searches
- Supports geocoding and mapping features
- Reduces data redundancy
- Ensures consistency in location formatting

---



**Analysis:**
-  **1NF**: All attributes are atomic
-  **2NF**: All attributes depend on booking_id
-  **3NF Issue Identified**: `total_price` can be derived

**Problem**: The `total_price` is calculated from:
```
total_price = (end_date - start_date) × Property.pricepernight
```

This creates a **transitive dependency**: `booking_id → property_id → pricepernight` and `booking_id → start_date, end_date`.

**Discussion:**

**Option 1 (Strict 3NF)**: Remove `total_price` and calculate it on-the-fly
- **Pros**: Adheres strictly to 3NF
- **Cons**: 
  - Performance overhead on every query
  - Doesn't account for price changes over time
  - Can't handle discounts, promotions, or special pricing

**Option 2 (Practical Denormalization)**: Keep `total_price` as a stored value


This is an example of **controlled denormalization** for business requirements.

**Status**:  Keep as-is (justified denormalization)

---

### 4. Payment Table
```sql
Payment (
    payment_id (PK),
    booking_id (FK),
    amount,
    payment_date,
    payment_method
)
```

**Analysis:**
- **1NF**: All attributes are atomic


**Problem**: The `amount` should equal `Booking.total_price`, creating redundancy.

**Discussion:**

**Option 1**: Remove `amount` and reference `Booking.total_price`
- **Cons**: 
  - Partial payments not supported
  - Refunds not supported
  - Payment flexibility lost

**Option 2**: Keep `amount` as independent field
- **Pros**:
  - Supports partial payments
  - Supports refunds (negative amounts or separate refund records)
  - Handles payment splits
  - Transaction independence

**Recommended Solution**: **Keep `amount`** (Option 2)

**Justification**: Payment systems require flexibility for:
1. Partial payments (deposits)
2. Payment plans
3. Refunds and chargebacks
4. Transaction independence from bookings

**Status**: Keep as-is (justified denormalization)

---

### 5. Review Table
```sql
Review (
    review_id (PK),
    property_id (FK),
    user_id (FK),
    rating,
    comment,
    created_at
)
```

**Analysis:**
- **1NF**: All attributes are atomic
- **2NF**: All attributes depend on review_id
- **3NF**: No transitive dependencies
- **Conclusion**: Already in 3NF

---

### 6. Message Table
```sql
Message (
    message_id (PK),
    sender_id (FK),
    recipient_id (FK),
    message_body,
    sent_at
)
```

**Analysis:**
- **1NF**: All attributes are atomic
- **2NF**: All attributes depend on message_id
- **3NF**: No transitive dependencies
- **Conclusion**: Already in 3NF

---

## Normalization Summary

### Required Changes

#### 1. Location Normalization (Critical)

**Before:**
```sql
Property (
    property_id (PK),
    host_id (FK),
    name,
    description,
    location,  -- String containing full address
    pricepernight,
    created_at,
    updated_at
)
```

**After:**
```sql
Location (
    location_id (PK),
    street_address VARCHAR,
    city VARCHAR NOT NULL,
    state VARCHAR NOT NULL,
    country VARCHAR NOT NULL,
    postal_code VARCHAR,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
)

Property (
    property_id (PK),
    host_id (FK),
    location_id (FK),  -- References Location table
    name,
    description,
    pricepernight,
    created_at,
    updated_at
)
```

**Impact:**
- Achieves 3NF
- Enables location-based searches
- Supports geographic queries
- Improves data consistency

---

### Justified Denormalizations (No Changes Required)

#### 1. Booking.total_price
**Status**: Kept for financial integrity and business requirements
**Reason**: Preserves actual transaction prices, supports promotions, required for audit trails

#### 2. Payment.amount
**Status**: Kept for payment flexibility
**Reason**: Enables partial payments, refunds, and payment independence

---

## Final Normalized Schema (3NF Compliant)

### Entity Relationship Summary

1. **User** (1) → (Many) **Property** (via host_id)
2. **Location** (1) → (Many) **Property** (via location_id) NEW
3. **User** (1) → (Many) **Booking**
4. **Property** (1) → (Many) **Booking**
5. **Booking** (1) → (One) **Payment**
6. **Property** (1) → (Many) **Review**
7. **User** (1) → (Many) **Review**
8. **User** (1) → (Many) **Message** (as sender)
9. **User** (1) → (Many) **Message** (as recipient)

---

## Implementation Recommendations

### Migration Strategy

1. **Create Location table**
   ```sql
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
       INDEX idx_city (city),
       INDEX idx_country (country),
       INDEX idx_lat_long (latitude, longitude)
   );
   ```

2. **Parse existing location data**
   - Extract and migrate existing `Property.location` strings into the Location table
   - Use geocoding APIs to populate latitude/longitude

3. **Update Property table**
   ```sql
   ALTER TABLE Property 
   ADD COLUMN location_id UUID,
   ADD FOREIGN KEY (location_id) REFERENCES Location(location_id);
   
   -- After data migration
   ALTER TABLE Property DROP COLUMN location;
   ```

### Indexing for Performance

Add indexes to maintain query performance:
```sql
-- Location table
CREATE INDEX idx_location_city ON Location(city);
CREATE INDEX idx_location_country ON Location(country);
CREATE INDEX idx_location_coords ON Location(latitude, longitude);

-- Property table
CREATE INDEX idx_property_location ON Property(location_id);
```

---

## Conclusion

The Airbnb database schema is now in **Third Normal Form (3NF)** with the following outcomes:

### Changes Made:
1. **Location normalization**: Separated location data into its own table, eliminating multi-valued attributes and improving query capabilities

### Justified Exceptions:
1. **Booking.total_price**: Retained for financial integrity and audit requirements
2. **Payment.amount**: Retained for payment flexibility and transaction independence



The schema now follows database design best practices while accommodating legitimate business and performance requirements.
