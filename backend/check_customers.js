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

async function checkCustomers() {
  try {
    console.log('Checking Customer table...\n');
    
    const result = await pool.query(`
      SELECT customer_id, name, email, phone, 
             CASE WHEN password_hash IS NULL THEN 'NO PASSWORD' 
                  ELSE 'HAS PASSWORD' END as password_status
      FROM Customer
      ORDER BY customer_id;
    `);
    
    console.log('Current customers:');
    console.table(result.rows);
    
    console.log('\n⚠️  Users with NO PASSWORD were created before the password_hash column was added.');
    console.log('💡 Solution: Delete old test users or manually set their password_hash.\n');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

checkCustomers();
