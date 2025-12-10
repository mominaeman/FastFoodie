const { Pool } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: 'postgres', // Connect to default postgres database first
  ssl: {
    rejectUnauthorized: false
  }
});

async function setupDatabase() {
  let client;
  
  try {
    console.log('Connecting to Cloud SQL...');
    client = await pool.connect();
    console.log('✅ Connected!\n');

    // Create database if it doesn't exist
    console.log('Creating database "fastfoodie"...');
    try {
      await client.query('CREATE DATABASE fastfoodie');
      console.log('✅ Database created!');
    } catch (err) {
      if (err.code === '42P04') {
        console.log('ℹ️  Database already exists');
      } else {
        throw err;
      }
    }
    
    client.release();

    // Connect to fastfoodie database
    const fastfoodiePool = new Pool({
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: 'fastfoodie',
      ssl: {
        rejectUnauthorized: false
      }
    });

    const dbClient = await fastfoodiePool.connect();
    console.log('\n📋 Creating tables...');

    // Create tables
    await dbClient.query(`
      -- Customer Table
      CREATE TABLE IF NOT EXISTS Customer (
        customer_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        address TEXT NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      -- Restaurant Table
      CREATE TABLE IF NOT EXISTS Restaurant (
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
      CREATE TABLE IF NOT EXISTS Category (
        category_id SERIAL PRIMARY KEY,
        category_name VARCHAR(50) UNIQUE NOT NULL
      );

      -- Sub_Category Table
      CREATE TABLE IF NOT EXISTS Sub_Category (
        sub_category_id SERIAL PRIMARY KEY,
        sub_category_name VARCHAR(50) NOT NULL,
        category_id INTEGER REFERENCES Category(category_id) ON DELETE CASCADE
      );

      -- Menu_Item Table
      CREATE TABLE IF NOT EXISTS Menu_Item (
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
      CREATE TABLE IF NOT EXISTS Rider (
        rider_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        vehicle_type VARCHAR(50),
        is_available BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      -- Orders Table
      CREATE TABLE IF NOT EXISTS Orders (
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
      CREATE TABLE IF NOT EXISTS Order_Item (
        order_item_id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
        item_id INTEGER REFERENCES Menu_Item(item_id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        price DECIMAL(10, 2) NOT NULL
      );

      -- Delivery Table
      CREATE TABLE IF NOT EXISTS Delivery (
        delivery_id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
        rider_id INTEGER REFERENCES Rider(rider_id) ON DELETE SET NULL,
        pickup_time TIMESTAMP,
        delivery_time TIMESTAMP,
        status VARCHAR(50) DEFAULT 'Pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      -- Payment Table
      CREATE TABLE IF NOT EXISTS Payment (
        payment_id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES Orders(order_id) ON DELETE CASCADE,
        payment_method VARCHAR(50) NOT NULL,
        payment_status VARCHAR(50) DEFAULT 'Pending',
        amount DECIMAL(10, 2) NOT NULL,
        payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('✅ All tables created!\n');

    // Add sample data
    console.log('📦 Adding sample data...');

    // Categories
    await dbClient.query(`
      INSERT INTO Category (category_name) VALUES 
      ('Fast Food'), ('Beverages'), ('Desserts'), ('Main Course'), ('Appetizers')
      ON CONFLICT (category_name) DO NOTHING
    `);
    console.log('✅ Categories added');

    // Sub-categories
    await dbClient.query(`
      INSERT INTO Sub_Category (sub_category_name, category_id) 
      SELECT * FROM (VALUES 
        ('Pizza', 1), ('Burgers', 1), ('Sandwiches', 1), ('French Fries', 1),
        ('Cold Drinks', 2), ('Juices', 2), ('Hot Drinks', 2),
        ('Ice Cream', 3), ('Cakes', 3), ('Pastries', 3),
        ('Biryani', 4), ('Karahi', 4), ('BBQ', 4),
        ('Wings', 5), ('Fries', 5)
      ) AS v(name, cat_id)
      WHERE NOT EXISTS (
        SELECT 1 FROM Sub_Category WHERE sub_category_name = v.name
      )
    `);
    console.log('✅ Sub-categories added');

    // Restaurants
    const restaurantCheck = await dbClient.query('SELECT COUNT(*) as count FROM Restaurant');
    if (parseInt(restaurantCheck.rows[0].count) === 0) {
      await dbClient.query(`
        INSERT INTO Restaurant (name, location, contact_number, opening_time, closing_time, rating) VALUES 
        ('Pizza Paradise', 'Karachi, Sindh', '+92 300 1234567', '10:00:00', '23:00:00', 4.5),
        ('Burger Barn', 'Lahore, Punjab', '+92 321 9876543', '11:00:00', '01:00:00', 4.2),
        ('Sushi Supreme', 'Islamabad, Capital', '+92 333 5555555', '12:00:00', '22:00:00', 4.7),
        ('Taco Town', 'Rawalpindi, Punjab', '+92 345 7777777', '11:00:00', '23:00:00', 4.3),
        ('Desi Delights', 'Faisalabad, Punjab', '+92 311 8888888', '08:00:00', '22:00:00', 4.6)
      `);
      console.log('✅ Restaurants added');
    } else {
      console.log('ℹ️  Restaurants already exist');
    }

    dbClient.release();
    await fastfoodiePool.end();
    await pool.end();

    console.log('\n🎉 Database setup complete!');
    console.log('\nNext step: Run "node add_menu_items.js" to add menu items');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (client) client.release();
  }
}

setupDatabase();
