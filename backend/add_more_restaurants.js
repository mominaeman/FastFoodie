require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false
  }
});

async function addRestaurants() {
  try {
    console.log('Connecting to database...');
    await pool.query('SELECT 1');
    console.log('✅ Connected!\n');

    // Add 5 more restaurants
    console.log('Adding more restaurants...');
    await pool.query(`
      INSERT INTO Restaurant (name, location, contact_number, opening_time, closing_time, rating) VALUES 
      ('Chinese Wok', 'Multan, Punjab', '+92 300 1111111', '11:00:00', '23:00:00', 4.4),
      ('Pasta Palace', 'Karachi, Sindh', '+92 321 2222222', '12:00:00', '00:00:00', 4.6),
      ('BBQ Tonight', 'Lahore, Punjab', '+92 333 3333333', '18:00:00', '02:00:00', 4.8),
      ('Cafe Delight', 'Islamabad, Capital', '+92 345 4444444', '08:00:00', '22:00:00', 4.3),
      ('Biryani House', 'Karachi, Sindh', '+92 311 5555555', '11:00:00', '23:00:00', 4.7)
    `);
    console.log('✅ 5 more restaurants added!\n');

    // Get all restaurants
    const result = await pool.query('SELECT restaurant_id, name, rating FROM Restaurant ORDER BY restaurant_id');
    console.log('📊 Total Restaurants:', result.rows.length);
    console.log('\nAll Restaurants:');
    result.rows.forEach(r => {
      console.log(`  ${r.restaurant_id}. ${r.name} (⭐ ${r.rating})`);
    });

    await pool.end();
    console.log('\n✅ Done!');
  } catch (error) {
    console.error('❌ Error:', error.message);
    await pool.end();
  }
}

addRestaurants();
