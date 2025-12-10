// Script to create Address table and migrate existing customer addresses
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || '104.197.103.44',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'fastfoodie',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false,
  },
});

async function setupAddressTable() {
  const client = await pool.connect();
  
  try {
    console.log('🚀 Creating Address table...');
    
    // Create Address table
    await client.query(`
      CREATE TABLE IF NOT EXISTS Address (
        address_id SERIAL PRIMARY KEY,
        customer_id INTEGER REFERENCES Customer(customer_id) ON DELETE CASCADE,
        label VARCHAR(50) NOT NULL,
        address_line TEXT NOT NULL,
        is_default BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Create index
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_address_customer ON Address(customer_id)
    `);
    
    console.log('✅ Address table created');
    
    // Migrate existing customer addresses
    console.log('📦 Migrating existing customer addresses...');
    
    const result = await client.query(`
      INSERT INTO Address (customer_id, label, address_line, is_default)
      SELECT customer_id, 'Home', address, TRUE
      FROM Customer
      WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM Address WHERE customer_id IS NOT NULL)
    `);
    
    console.log(`✅ Migrated ${result.rowCount} customer addresses`);
    console.log('🎉 Address table setup complete!');
    
  } catch (error) {
    console.error('❌ Error setting up Address table:', error.message);
  } finally {
    client.release();
    pool.end();
  }
}

setupAddressTable();
