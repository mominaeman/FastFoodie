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

async function viewCustomers() {
  try {
    console.log('\n' + '='.repeat(120));
    console.log('👥 YOUR SIGNUP DATA - CUSTOMERS TABLE');
    console.log('='.repeat(120));
    console.log('\n📍 Location: Google Cloud SQL > Database: fastfoodie > Table: Customer\n');
    
    const result = await pool.query(`
      SELECT 
        customer_id as "ID",
        name as "Name",
        email as "Email",
        phone as "Phone",
        address as "Address",
        CASE 
          WHEN password_hash IS NOT NULL THEN '✓ Secured' 
          ELSE '✗ No Password' 
        END as "Password Status",
        TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') as "Signed Up At"
      FROM Customer 
      ORDER BY customer_id
    `);
    
    console.table(result.rows);
    
    console.log(`\n📊 Total Customers: ${result.rows.length}\n`);
    
    // Show which are real users (with passwords) vs sample data
    const realUsers = result.rows.filter(r => r['Password Status'] === '✓ Secured');
    const sampleData = result.rows.filter(r => r['Password Status'] === '✗ No Password');
    
    console.log('📈 Breakdown:');
    console.log(`   ✅ Real Users (signed up via app): ${realUsers.length}`);
    console.log(`   📝 Sample Data (test data): ${sampleData.length}`);
    
    if (realUsers.length > 0) {
      console.log('\n🎯 Your Real Users:');
      realUsers.forEach(user => {
        console.log(`   • ${user.Name} (${user.Email}) - Phone: ${user.Phone}`);
        console.log(`     Address: ${user.Address}`);
        console.log(`     Joined: ${user['Signed Up At']}\n`);
      });
    }
    
    console.log('\n' + '='.repeat(120));
    console.log('💡 DATA FLOW SUMMARY:');
    console.log('='.repeat(120));
    console.log('1. User fills signup form in Flutter app');
    console.log('2. Flutter validates data & hashes password (SHA-256)');
    console.log('3. Data sent to: http://localhost:3000/api/auth/signup');
    console.log('4. Backend (Node.js) receives and stores in Google Cloud SQL');
    console.log('5. Data saved in: fastfoodie database → Customer table ← YOU ARE HERE!');
    console.log('='.repeat(120) + '\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

viewCustomers();
