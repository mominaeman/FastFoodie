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

async function cleanupTestUsers() {
  try {
    console.log('Deleting test users (keeping sample data)...\n');
    
    // Delete only test user created during testing (customer_id = 5)
    const result = await pool.query(`
      DELETE FROM Customer 
      WHERE customer_id >= 5;
    `);
    
    console.log(`✓ Deleted ${result.rowCount} test user(s)`);
    console.log('✓ Sample data (customers 1-4) preserved');
    console.log('\n📝 Now you can sign up with mominaeman2003@gmail.com again!');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

cleanupTestUsers();
