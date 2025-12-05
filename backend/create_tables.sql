-- Run these SQL commands in Google Cloud Shell or Query Console

-- Connect to fastfoodie database first
\c fastfoodie

-- Create tables
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurants(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    menu_item_id INTEGER REFERENCES menu_items(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add sample data
INSERT INTO restaurants (name, address, phone, rating) VALUES
('Pizza Paradise', '123 Main St, Downtown', '555-0101', 4.5),
('Burger Barn', '456 Oak Ave, Midtown', '555-0102', 4.2),
('Sushi Supreme', '789 Pine Rd, Uptown', '555-0103', 4.8),
('Taco Town', '321 Elm St, Downtown', '555-0104', 4.3);

INSERT INTO menu_items (restaurant_id, name, description, price, category) VALUES
(1, 'Margherita Pizza', 'Classic tomato and mozzarella', 12.99, 'Pizza'),
(1, 'Pepperoni Pizza', 'With extra pepperoni', 14.99, 'Pizza'),
(2, 'Classic Burger', 'Beef patty with all toppings', 9.99, 'Burgers'),
(2, 'Cheese Burger', 'Double cheese special', 11.99, 'Burgers'),
(3, 'California Roll', 'Fresh salmon and avocado', 15.99, 'Sushi'),
(3, 'Dragon Roll', 'Spicy tuna special', 18.99, 'Sushi');

-- Verify
SELECT * FROM restaurants;
SELECT * FROM menu_items;
