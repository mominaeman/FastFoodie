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

async function viewAllTables() {
  try {
    console.log('📊 FASTFOODIE DATABASE TABLES\n');
    console.log('=' .repeat(80));
    
    // Get all table names
    const tablesResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    
    console.log(`\n✅ Found ${tablesResult.rows.length} tables:\n`);
    
    for (const row of tablesResult.rows) {
      const tableName = row.table_name;
      
      // Get row count
      const countResult = await pool.query(`SELECT COUNT(*) as count FROM "${tableName}"`);
      const rowCount = countResult.rows[0].count;
      
      // Get column info
      const columnsResult = await pool.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = $1 
        ORDER BY ordinal_position;
      `, [tableName]);
      
      console.log(`\n📋 Table: ${tableName}`);
      console.log(`   Rows: ${rowCount}`);
      console.log(`   Columns: ${columnsResult.rows.map(c => c.column_name).join(', ')}`);
      console.log('-'.repeat(80));
    }
    
    console.log('\n\n💡 To view data from a specific table, run:');
    console.log('   node view_table_data.js <table_name>');
    console.log('   Example: node view_table_data.js Customer\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

viewAllTables();
