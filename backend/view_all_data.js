const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false
  }
});

async function viewAllData() {
  try {
    console.log('\n' + '='.repeat(100));
    console.log('🎯 FASTFOODIE DATABASE - ALL DATA');
    console.log('='.repeat(100));
    
    // 1. CUSTOMERS (Your signup data goes here!)
    console.log('\n\n👥 CUSTOMERS TABLE (Where your signup data is stored):');
    console.log('-'.repeat(100));
    const customers = await pool.query(`
      SELECT customer_id, name, email, phone, address, 
             CASE WHEN password_hash IS NOT NULL THEN 'HAS PASSWORD ✓' ELSE 'NO PASSWORD ✗' END as password_status,
             created_at 
      FROM Customer 
      ORDER BY customer_id
    `);
    console.table(customers.rows);
    console.log(`📊 Total Customers: ${customers.rows.length}`);
    
    // 2. RESTAURANTS
    console.log('\n\n🍽️  RESTAURANTS TABLE:');
    console.log('-'.repeat(100));
    const restaurants = await pool.query('SELECT * FROM Restaurant ORDER BY restaurant_id');
    console.table(restaurants.rows);
    console.log(`📊 Total Restaurants: ${restaurants.rows.length}`);
    
    // 3. CATEGORIES
    console.log('\n\n📁 CATEGORIES TABLE:');
    console.log('-'.repeat(100));
    const categories = await pool.query('SELECT * FROM Category ORDER BY category_id');
    console.table(categories.rows);
    console.log(`📊 Total Categories: ${categories.rows.length}`);
    
    // 4. MENU ITEMS (Sample)
    console.log('\n\n🍔 MENU ITEMS TABLE (Sample - First 10):');
    console.log('-'.repeat(100));
    const menuItems = await pool.query(`
      SELECT item_id, item_name, price, description
      FROM Menu_Item
      ORDER BY item_id
      LIMIT 10
    `);
    console.table(menuItems.rows);
    const totalItems = await pool.query('SELECT COUNT(*) FROM Menu_Item');
    console.log(`📊 Total Menu Items: ${totalItems.rows[0].count}`);
    
    // 5. ORDERS
    console.log('\n\n📦 ORDERS TABLE:');
    console.log('-'.repeat(100));
    const orders = await pool.query(`
      SELECT o.order_id, c.name as customer, r.name as restaurant,
             o.total_amount, o.order_status, o.order_date
      FROM Orders o
      JOIN Customer c ON o.customer_id = c.customer_id
      JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
      ORDER BY o.order_id
    `);
    console.table(orders.rows);
    console.log(`📊 Total Orders: ${orders.rows.length}`);
    
    // 6. RIDERS
    console.log('\n\n🏍️  RIDERS TABLE:');
    console.log('-'.repeat(100));
    const riders = await pool.query('SELECT * FROM Rider ORDER BY rider_id');
    console.table(riders.rows);
    console.log(`📊 Total Riders: ${riders.rows.length}`);
    
    console.log('\n' + '='.repeat(100));
    console.log('✅ DATABASE OVERVIEW COMPLETE');
    console.log('='.repeat(100));
    console.log('\n💡 TIP: When you sign up, your data appears in the CUSTOMERS table!');
    console.log('💡 Your password is stored as a hash for security (not plain text)\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

viewAllData();
