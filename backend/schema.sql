-- FastFoodie Database Schema
-- Run this file: psql -U postgres -d fastfoodie -f schema.sql

-- Drop existing tables if any
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

-- Customer Table
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurant Table
CREATE TABLE Restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location TEXT NOT NULL,
    contact_number VARCHAR(20),
    opening_time TIME,
    closing_time TIME,
    rating DECIMAL(2, 1) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Category Table
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

-- Sub_Category Table
CREATE TABLE Sub_Category (
    sub_category_id SERIAL PRIMARY KEY,
    sub_category_name VARCHAR(50) NOT NULL,
    category_id INTEGER REFERENCES Category(category_id) ON DELETE CASCADE
);

-- Menu_Item Table
CREATE TABLE Menu_Item (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    sub_category_id INTEGER REFERENCES Sub_Category(sub_category_id) ON DELETE SET NULL,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rider Table
CREATE TABLE Rider (
    rider_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_type VARCHAR(50),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES Customer(customer_id) ON DELETE CASCADE,
    restaurant_id INTEGER REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    delivery_address TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order_Item Table
CREATE TABLE Order_Item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES Menu_Item(item_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Delivery Table
CREATE TABLE Delivery (
    delivery_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
    rider_id INTEGER REFERENCES Rider(rider_id) ON DELETE SET NULL,
    pickup_time TIMESTAMP,
    delivery_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Table
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'Pending',
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Sample Data

-- Categories
INSERT INTO Category (category_name) VALUES 
('Fast Food'),
('Beverages'),
('Desserts'),
('Main Course'),
('Appetizers');

-- Sub-Categories
INSERT INTO Sub_Category (sub_category_name, category_id) VALUES 
('Pizza', 1),
('Burgers', 1),
('Sandwiches', 1),
('French Fries', 1),
('Cold Drinks', 2),
('Juices', 2),
('Hot Drinks', 2),
('Ice Cream', 3),
('Cakes', 3),
('Pastries', 3),
('Biryani', 4),
('Karahi', 4),
('BBQ', 4),
('Wings', 5),
('Fries', 5);

-- Restaurants
INSERT INTO Restaurant (name, location, contact_number, opening_time, closing_time, rating) VALUES 
('Pizza Paradise', 'Karachi, Sindh', '+92 300 1234567', '10:00:00', '23:00:00', 4.5),
('Burger Barn', 'Lahore, Punjab', '+92 321 9876543', '11:00:00', '01:00:00', 4.2),
('Sushi Supreme', 'Islamabad, Capital', '+92 333 5555555', '12:00:00', '22:00:00', 4.7),
('Taco Town', 'Rawalpindi, Punjab', '+92 345 7777777', '11:00:00', '23:00:00', 4.3),
('Desi Delights', 'Faisalabad, Punjab', '+92 311 8888888', '08:00:00', '22:00:00', 4.6);

PRINT 'Database schema created successfully!';
PRINT 'Run add_menu_items.js to add menu items';
