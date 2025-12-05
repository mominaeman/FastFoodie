-- Food Ordering and Delivery Management System
-- Database Schema - Matches Project Proposal
-- Total: 10 Tables as required
-- Run in Google Cloud SQL Console

-- Connect to database
\c fastfoodie

-- Drop existing tables if needed (in correct order due to dependencies)
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Delivery CASCADE;
DROP TABLE IF EXISTS Order_Item CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Menu_Item CASCADE;
DROP TABLE IF EXISTS Sub_Category CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Rider CASCADE;
DROP TABLE IF EXISTS Restaurant CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;

-- ===========================
-- TABLE 1: Customer
-- ===========================
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- TABLE 2: Restaurant
-- ===========================
CREATE TABLE Restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location TEXT NOT NULL,
    contact VARCHAR(20) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    opening_time TIME,
    closing_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- TABLE 3: Category
-- ===========================
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- TABLE 4: Sub_Category
-- ===========================
CREATE TABLE Sub_Category (
    sub_category_id SERIAL PRIMARY KEY,
    sub_category_name VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE
);

-- ===========================
-- TABLE 5: Menu_Item
-- ===========================
CREATE TABLE Menu_Item (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    sub_category_id INTEGER NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (sub_category_id) REFERENCES Sub_Category(sub_category_id) ON DELETE CASCADE
);

-- ===========================
-- TABLE 6: Orders
-- ===========================
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_address TEXT NOT NULL,
    special_instructions TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE
);

-- ===========================
-- TABLE 7: Order_Item
-- ===========================
CREATE TABLE Order_Item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Menu_Item(item_id) ON DELETE CASCADE
);

-- ===========================
-- TABLE 8: Rider
-- ===========================
CREATE TABLE Rider (
    rider_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_no VARCHAR(50) NOT NULL,
    is_available BOOLEAN DEFAULT true,
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- TABLE 9: Delivery
-- ===========================
CREATE TABLE Delivery (
    delivery_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    rider_id INTEGER NOT NULL,
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    delivery_status VARCHAR(50) DEFAULT 'assigned',
    distance_km DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (rider_id) REFERENCES Rider(rider_id) ON DELETE CASCADE
);

-- ===========================
-- TABLE 10: Payment
-- ===========================
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    net_price DECIMAL(10,2) NOT NULL,
    cash_paid DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'pending',
    transaction_id VARCHAR(255) UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- ===========================
-- SAMPLE DATA
-- ===========================

-- Insert Customers
INSERT INTO Customer (name, email, phone, address) VALUES
('John Doe', 'john.doe@example.com', '0300-1234567', 'House 12, Street 5, F-6, Islamabad'),
('Jane Smith', 'jane.smith@example.com', '0301-2345678', 'Flat 301, Tower B, Bahria Town, Rawalpindi'),
('Ali Ahmed', 'ali.ahmed@example.com', '0302-3456789', 'Block C, House 45, DHA Phase 2, Islamabad'),
('Sara Khan', 'sara.khan@example.com', '0303-4567890', 'Apartment 8, PWD Housing Society, Islamabad');

-- Insert Restaurants
INSERT INTO Restaurant (name, location, contact, rating, opening_time, closing_time) VALUES
('Pizza Paradise', 'Blue Area, Islamabad', '051-1234567', 4.5, '10:00', '23:00'),
('Burger Barn', 'F-7 Markaz, Islamabad', '051-2345678', 4.2, '09:00', '22:00'),
('Sushi Supreme', 'Centaurus Mall, Islamabad', '051-3456789', 4.8, '11:00', '23:30'),
('Taco Town', 'Jinnah Super, Islamabad', '051-4567890', 4.3, '10:00', '22:00'),
('Desi Delights', 'G-9 Markaz, Islamabad', '051-5678901', 4.6, '11:00', '23:00');

-- Insert Categories
INSERT INTO Category (category_name, description) VALUES
('Fast Food', 'Quick service meals including burgers, pizzas, and fries'),
('Asian Cuisine', 'Traditional and modern Asian dishes'),
('Desi Food', 'Pakistani and Indian traditional meals'),
('Beverages', 'Drinks, juices, and shakes'),
('Desserts', 'Sweet dishes and ice cream');

-- Insert Sub_Categories
INSERT INTO Sub_Category (sub_category_name, category_id) VALUES
-- Fast Food subcategories
('Pizza', 1),
('Burgers', 1),
('Sandwiches', 1),
('French Fries', 1),
-- Asian Cuisine subcategories
('Sushi', 2),
('Chinese', 2),
('Thai', 2),
-- Desi Food subcategories
('Biryani', 3),
('Karahi', 3),
('BBQ', 3),
-- Beverages subcategories
('Cold Drinks', 4),
('Juices', 4),
('Shakes', 4),
-- Desserts subcategories
('Ice Cream', 5),
('Cakes', 5);

-- Insert Menu Items
INSERT INTO Menu_Item (restaurant_id, sub_category_id, item_name, description, price, is_available) VALUES
-- Pizza Paradise (Restaurant 1)
(1, 1, 'Margherita Pizza', 'Classic tomato and mozzarella cheese', 899.00, true),
(1, 1, 'Pepperoni Pizza', 'Loaded with pepperoni slices', 1099.00, true),
(1, 1, 'Fajita Pizza', 'Chicken fajita with bell peppers', 1299.00, true),
(1, 4, 'French Fries', 'Crispy golden fries', 299.00, true),
(1, 11, 'Coca Cola', '500ml bottle', 150.00, true),

-- Burger Barn (Restaurant 2)
(2, 2, 'Classic Burger', 'Beef patty with lettuce and tomato', 599.00, true),
(2, 2, 'Cheese Burger', 'Double cheese beef burger', 799.00, true),
(2, 2, 'Chicken Burger', 'Grilled chicken fillet burger', 699.00, true),
(2, 4, 'Curly Fries', 'Seasoned curly fries', 349.00, true),
(2, 13, 'Chocolate Shake', 'Rich chocolate milkshake', 450.00, true),

-- Sushi Supreme (Restaurant 3)
(3, 5, 'California Roll', 'Crab, avocado, and cucumber', 1299.00, true),
(3, 5, 'Dragon Roll', 'Eel and cucumber with avocado', 1499.00, true),
(3, 5, 'Spicy Tuna Roll', 'Tuna with spicy mayo', 1399.00, true),
(3, 12, 'Fresh Orange Juice', 'Freshly squeezed orange juice', 350.00, true),

-- Taco Town (Restaurant 4)
(4, 3, 'Beef Tacos', 'Three soft shell beef tacos', 799.00, true),
(4, 3, 'Chicken Burrito', 'Wrapped with rice and beans', 899.00, true),
(4, 11, 'Pepsi', '500ml bottle', 150.00, true),

-- Desi Delights (Restaurant 5)
(5, 8, 'Chicken Biryani', 'Fragrant rice with chicken', 599.00, true),
(5, 8, 'Mutton Biryani', 'Spicy mutton with basmati rice', 799.00, true),
(5, 9, 'Chicken Karahi', 'Traditional chicken karahi', 1299.00, true),
(5, 10, 'Seekh Kabab', '6 pieces grilled seekh kabab', 699.00, true),
(5, 12, 'Mango Lassi', 'Sweet yogurt mango drink', 250.00, true);

-- Insert Riders
INSERT INTO Rider (name, phone, vehicle_no, is_available, rating, total_deliveries) VALUES
('Ahmed Ali', '0321-1111111', 'ISB-1234', true, 4.7, 250),
('Bilal Hassan', '0322-2222222', 'RWP-5678', true, 4.9, 320),
('Usman Khan', '0323-3333333', 'ISB-9012', false, 4.5, 180),
('Zain Malik', '0324-4444444', 'ISB-3456', true, 4.8, 290);

-- Insert Orders
INSERT INTO Orders (customer_id, restaurant_id, order_date, status, total_amount, delivery_address) VALUES
(1, 1, '2024-12-01 12:30:00', 'delivered', 1648.00, 'House 12, Street 5, F-6, Islamabad'),
(2, 2, '2024-12-02 18:15:00', 'delivered', 1748.00, 'Flat 301, Tower B, Bahria Town, Rawalpindi'),
(3, 3, '2024-12-03 19:00:00', 'in_transit', 2698.00, 'Block C, House 45, DHA Phase 2, Islamabad'),
(4, 5, '2024-12-04 13:45:00', 'preparing', 1548.00, 'Apartment 8, PWD Housing Society, Islamabad');

-- Insert Order Items
INSERT INTO Order_Item (order_id, item_id, quantity, price) VALUES
-- Order 1: Pizza Paradise
(1, 1, 1, 899.00),  -- Margherita Pizza
(1, 2, 1, 1099.00), -- Pepperoni Pizza
(1, 4, 1, 299.00),  -- French Fries
(1, 5, 1, 150.00),  -- Coca Cola

-- Order 2: Burger Barn
(2, 6, 1, 599.00),  -- Classic Burger
(2, 7, 1, 799.00),  -- Cheese Burger
(2, 9, 1, 349.00),  -- Curly Fries

-- Order 3: Sushi Supreme
(3, 11, 1, 1299.00), -- California Roll
(3, 12, 1, 1499.00), -- Dragon Roll

-- Order 4: Desi Delights
(4, 18, 1, 599.00),  -- Chicken Biryani
(4, 20, 1, 1299.00), -- Chicken Karahi
(4, 22, 1, 250.00);  -- Mango Lassi

-- Insert Deliveries
INSERT INTO Delivery (order_id, rider_id, departure_time, arrival_time, delivery_status, distance_km) VALUES
(1, 1, '2024-12-01 12:45:00', '2024-12-01 13:15:00', 'completed', 5.2),
(2, 2, '2024-12-02 18:30:00', '2024-12-02 19:00:00', 'completed', 8.5),
(3, 1, '2024-12-03 19:15:00', NULL, 'in_progress', 6.3),
(4, 4, '2024-12-04 14:00:00', NULL, 'assigned', 4.8);

-- Insert Payments
INSERT INTO Payment (order_id, payment_method, net_price, cash_paid, payment_status, transaction_id) VALUES
(1, 'Cash', 1648.00, 2000.00, 'completed', 'TXN-20241201-001'),
(2, 'Credit Card', 1748.00, 1748.00, 'completed', 'TXN-20241202-002'),
(3, 'Debit Card', 2698.00, 2698.00, 'pending', 'TXN-20241203-003'),
(4, 'Cash', 1548.00, 0.00, 'pending', 'TXN-20241204-004');

-- ===========================
-- VERIFICATION QUERIES
-- ===========================

-- Count records in each table
SELECT 
    'Customer' as table_name, COUNT(*) as records FROM Customer
UNION ALL
SELECT 'Restaurant', COUNT(*) FROM Restaurant
UNION ALL
SELECT 'Category', COUNT(*) FROM Category
UNION ALL
SELECT 'Sub_Category', COUNT(*) FROM Sub_Category
UNION ALL
SELECT 'Menu_Item', COUNT(*) FROM Menu_Item
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Item', COUNT(*) FROM Order_Item
UNION ALL
SELECT 'Rider', COUNT(*) FROM Rider
UNION ALL
SELECT 'Delivery', COUNT(*) FROM Delivery
UNION ALL
SELECT 'Payment', COUNT(*) FROM Payment;

-- Sample query: View order details with customer and restaurant info
SELECT 
    o.order_id,
    c.name as customer_name,
    r.name as restaurant_name,
    o.order_date,
    o.status,
    o.total_amount,
    d.rider_id,
    rd.name as rider_name,
    d.delivery_status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
LEFT JOIN Delivery d ON o.order_id = d.order_id
LEFT JOIN Rider rd ON d.rider_id = rd.rider_id
ORDER BY o.order_date DESC;

-- Sample query: View menu items with categories
SELECT 
    m.item_name,
    m.price,
    r.name as restaurant_name,
    c.category_name,
    sc.sub_category_name
FROM Menu_Item m
JOIN Restaurant r ON m.restaurant_id = r.restaurant_id
JOIN Sub_Category sc ON m.sub_category_id = sc.sub_category_id
JOIN Category c ON sc.category_id = c.category_id
ORDER BY r.name, c.category_name;
