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

async function viewTableData(tableName) {
  try {
    if (!tableName) {
      console.log('❌ Please provide a table name!');
      console.log('Usage: node view_table_data.js <table_name>');
      console.log('\nAvailable tables:');
      console.log('  - Customer');
      console.log('  - Restaurant');
      console.log('  - Category');
      console.log('  - Sub_Category');
      console.log('  - Menu_Item');
      console.log('  - Orders');
      console.log('  - Order_Item');
      console.log('  - Rider');
      console.log('  - Delivery');
      console.log('  - Payment');
      return;
    }
    
    console.log(`\n📊 Data from table: ${tableName}\n`);
    console.log('='.repeat(100));
    
    // Get all data from the table
    const result = await pool.query(`SELECT * FROM "${tableName}" LIMIT 50`);
    
    if (result.rows.length === 0) {
      console.log(`\n⚠️  Table "${tableName}" is empty (0 rows)\n`);
    } else {
      console.log(`\n✅ Showing ${result.rows.length} rows:\n`);
      console.table(result.rows);
      
      if (result.rowCount === 50) {
        console.log('\n💡 Showing first 50 rows only. Total rows may be more.\n');
      }
    }
    
  } catch (error) {
    if (error.message.includes('does not exist')) {
      console.log(`\n❌ Table "${tableName}" does not exist!`);
      console.log('\nRun: node view_tables.js  to see all available tables\n');
    } else {
      console.error('❌ Error:', error.message);
    }
  } finally {
    await pool.end();
  }
}

// Get table name from command line argument
const tableName = process.argv[2];
viewTableData(tableName);
