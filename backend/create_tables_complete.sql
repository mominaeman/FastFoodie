-- Complete Database Schema for Food Delivery System
-- Total: 10 Tables
-- Run these SQL commands in Google Cloud Shell or Query Console

-- Connect to fastfoodie database first
\c fastfoodie

-- ===========================
-- CORE TABLES (5)
-- ===========================

-- 1. Restaurants Table
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    opening_time TIME,
    closing_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Menu Items Table
CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    user_type VARCHAR(50) DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Orders Table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurants(id),
    delivery_person_id INTEGER REFERENCES delivery_persons(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Order Items Table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id INTEGER REFERENCES menu_items(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- ADDITIONAL TABLES (5)
-- ===========================

-- 6. Restaurant Owners Table
CREATE TABLE restaurant_owners (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurants(id),
    ownership_percentage DECIMAL(5,2) DEFAULT 100.0,
    joined_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Delivery Persons Table
CREATE TABLE delivery_persons (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    vehicle_type VARCHAR(50),
    vehicle_number VARCHAR(50),
    license_number VARCHAR(50),
    is_available BOOLEAN DEFAULT true,
    current_location TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Deliveries Table (Tracking)
CREATE TABLE deliveries (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    delivery_person_id INTEGER REFERENCES delivery_persons(id),
    pickup_time TIMESTAMP,
    delivery_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'assigned',
    distance_km DECIMAL(5,2),
    delivery_fee DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Reviews Table
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurants(id),
    delivery_person_id INTEGER REFERENCES delivery_persons(id),
    restaurant_rating INTEGER CHECK (restaurant_rating BETWEEN 1 AND 5),
    delivery_rating INTEGER CHECK (delivery_rating BETWEEN 1 AND 5),
    food_quality_rating INTEGER CHECK (food_quality_rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Payments Table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    user_id INTEGER REFERENCES users(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- SAMPLE DATA
-- ===========================

-- Insert Sample Restaurants
INSERT INTO restaurants (name, address, phone, rating, opening_time, closing_time) VALUES
('Pizza Paradise', '123 Main St, Downtown', '555-0101', 4.5, '10:00', '23:00'),
('Burger Barn', '456 Oak Ave, Midtown', '555-0102', 4.2, '09:00', '22:00'),
('Sushi Supreme', '789 Pine Rd, Uptown', '555-0103', 4.8, '11:00', '23:30'),
('Taco Town', '321 Elm St, Downtown', '555-0104', 4.3, '10:00', '22:00'),
('Italian Delights', '654 Maple Dr, Eastside', '555-0105', 4.6, '11:30', '23:00');

-- Insert Sample Users (Customers)
INSERT INTO users (email, name, phone, address, user_type) VALUES
('john@example.com', 'John Doe', '555-1001', '100 Customer Lane', 'customer'),
('jane@example.com', 'Jane Smith', '555-1002', '200 Buyer Street', 'customer'),
('bob@example.com', 'Bob Johnson', '555-1003', '300 Patron Ave', 'customer');

-- Insert Sample Users (Restaurant Owners)
INSERT INTO users (email, name, phone, user_type) VALUES
('owner1@pizza.com', 'Mario Rossi', '555-2001', 'owner'),
('owner2@burger.com', 'Sarah Chen', '555-2002', 'owner'),
('owner3@sushi.com', 'Kenji Tanaka', '555-2003', 'owner');

-- Insert Sample Users (Delivery Persons)
INSERT INTO users (email, name, phone, user_type) VALUES
('driver1@delivery.com', 'Mike Wilson', '555-3001', 'delivery'),
('driver2@delivery.com', 'Emily Brown', '555-3002', 'delivery'),
('driver3@delivery.com', 'Alex Garcia', '555-3003', 'delivery');

-- Link Restaurant Owners
INSERT INTO restaurant_owners (user_id, restaurant_id, ownership_percentage) VALUES
(4, 1, 100.0),  -- Mario owns Pizza Paradise
(5, 2, 100.0),  -- Sarah owns Burger Barn
(6, 3, 100.0);  -- Kenji owns Sushi Supreme

-- Insert Delivery Persons
INSERT INTO delivery_persons (user_id, vehicle_type, vehicle_number, license_number, is_available, rating, total_deliveries) VALUES
(7, 'Motorcycle', 'ABC-123', 'DL-12345', true, 4.7, 150),
(8, 'Bicycle', 'XYZ-789', 'DL-67890', true, 4.9, 200),
(9, 'Scooter', 'DEF-456', 'DL-11111', false, 4.5, 100);

-- Insert Sample Menu Items
INSERT INTO menu_items (restaurant_id, name, description, price, category, is_available) VALUES
(1, 'Margherita Pizza', 'Classic tomato and mozzarella', 12.99, 'Pizza', true),
(1, 'Pepperoni Pizza', 'With extra pepperoni', 14.99, 'Pizza', true),
(1, 'Garlic Bread', 'Toasted with butter and garlic', 5.99, 'Sides', true),
(2, 'Classic Burger', 'Beef patty with all toppings', 9.99, 'Burgers', true),
(2, 'Cheese Burger', 'Double cheese special', 11.99, 'Burgers', true),
(2, 'French Fries', 'Crispy golden fries', 3.99, 'Sides', true),
(3, 'California Roll', 'Fresh salmon and avocado', 15.99, 'Sushi', true),
(3, 'Dragon Roll', 'Spicy tuna special', 18.99, 'Sushi', true),
(3, 'Miso Soup', 'Traditional Japanese soup', 4.99, 'Soups', true),
(4, 'Beef Tacos', '3 soft shell tacos', 10.99, 'Tacos', true),
(4, 'Chicken Burrito', 'Wrapped with rice and beans', 12.99, 'Burritos', true),
(5, 'Spaghetti Carbonara', 'Creamy pasta with bacon', 16.99, 'Pasta', true);

-- Insert Sample Orders
INSERT INTO orders (user_id, restaurant_id, delivery_person_id, total_amount, status, delivery_address, special_instructions) VALUES
(1, 1, 1, 27.98, 'delivered', '100 Customer Lane', 'Ring doorbell twice'),
(2, 2, 2, 21.98, 'delivered', '200 Buyer Street', 'Leave at door'),
(3, 3, 1, 34.98, 'in_transit', '300 Patron Ave', 'Call upon arrival');

-- Insert Sample Order Items
INSERT INTO order_items (order_id, menu_item_id, quantity, price) VALUES
(1, 1, 1, 12.99),  -- 1 Margherita Pizza
(1, 2, 1, 14.99),  -- 1 Pepperoni Pizza
(2, 4, 1, 9.99),   -- 1 Classic Burger
(2, 5, 1, 11.99),  -- 1 Cheese Burger
(3, 7, 1, 15.99),  -- 1 California Roll
(3, 8, 1, 18.99);  -- 1 Dragon Roll

-- Insert Sample Deliveries
INSERT INTO deliveries (order_id, delivery_person_id, pickup_time, delivery_time, status, distance_km, delivery_fee) VALUES
(1, 1, '2024-12-01 12:30:00', '2024-12-01 13:00:00', 'completed', 5.2, 3.50),
(2, 2, '2024-12-02 18:15:00', '2024-12-02 18:45:00', 'completed', 3.8, 2.50),
(3, 1, '2024-12-03 19:00:00', NULL, 'in_progress', 4.5, 3.00);

-- Insert Sample Reviews
INSERT INTO reviews (order_id, user_id, restaurant_id, delivery_person_id, restaurant_rating, delivery_rating, food_quality_rating, comment) VALUES
(1, 1, 1, 1, 5, 5, 5, 'Amazing pizza! Fast delivery too!'),
(2, 2, 2, 2, 4, 5, 4, 'Good burgers, delivery was excellent');

-- Insert Sample Payments
INSERT INTO payments (order_id, user_id, amount, payment_method, transaction_id, status) VALUES
(1, 1, 27.98, 'credit_card', 'TXN-20241201-001', 'completed'),
(2, 2, 21.98, 'debit_card', 'TXN-20241202-002', 'completed'),
(3, 3, 34.98, 'cash', 'TXN-20241203-003', 'pending');

-- ===========================
-- VERIFICATION QUERIES
-- ===========================

-- Check all tables
SELECT 'Restaurants' as table_name, COUNT(*) as record_count FROM restaurants
UNION ALL
SELECT 'Menu Items', COUNT(*) FROM menu_items
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Restaurant Owners', COUNT(*) FROM restaurant_owners
UNION ALL
SELECT 'Delivery Persons', COUNT(*) FROM delivery_persons
UNION ALL
SELECT 'Deliveries', COUNT(*) FROM deliveries
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments;
