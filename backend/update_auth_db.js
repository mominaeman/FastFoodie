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

async function addPasswordColumn() {
  try {
    console.log('Adding password_hash column to Customer table...');
    
    await pool.query(`
      ALTER TABLE Customer 
      ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
    `);
    
    console.log('✓ password_hash column added successfully!');
    console.log('Database is now ready for secure authentication.');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

addPasswordColumn();
