-- Create Address Table for multiple customer addresses
-- This allows customers to save multiple delivery addresses

CREATE TABLE IF NOT EXISTS Address (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES Customer(customer_id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL, -- 'Home', 'Work', 'Other', etc.
    address_line TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster customer address lookups
CREATE INDEX IF NOT EXISTS idx_address_customer ON Address(customer_id);

-- Migrate existing customer addresses to Address table
-- This will create one default address for each existing customer
INSERT INTO Address (customer_id, label, address_line, is_default)
SELECT customer_id, 'Home', address, TRUE
FROM Customer
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM Address);

PRINT 'Address table created successfully!';
PRINT 'Existing customer addresses migrated to Address table';
