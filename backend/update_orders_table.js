// Script to add special_instructions and updated_at columns to Orders table
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

async function updateOrdersTable() {
  const client = await pool.connect();
  
  try {
    console.log('🚀 Updating Orders table...');
    
    // Add special_instructions column
    try {
      await client.query(`
        ALTER TABLE Orders ADD COLUMN IF NOT EXISTS special_instructions TEXT
      `);
      console.log('✅ Added special_instructions column');
    } catch (error) {
      console.log('ℹ️  special_instructions column may already exist');
    }
    
    // Add updated_at column
    try {
      await client.query(`
        ALTER TABLE Orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      `);
      console.log('✅ Added updated_at column');
    } catch (error) {
      console.log('ℹ️  updated_at column may already exist');
    }
    
    console.log('🎉 Orders table updated successfully!');
    
  } catch (error) {
    console.error('❌ Error updating Orders table:', error.message);
  } finally {
    client.release();
    pool.end();
  }
}

updateOrdersTable();
