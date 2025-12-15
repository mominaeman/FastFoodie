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

const riders = [
  {
    name: 'Ahmed Ali',
    phone: '0300-1234567',
    vehicle_type: 'bike',
    is_available: true
  },
  {
    name: 'Hassan Khan',
    phone: '0301-9876543',
    vehicle_type: 'bike',
    is_available: true
  },
  {
    name: 'Bilal Sheikh',
    phone: '0333-5551234',
    vehicle_type: 'car',
    is_available: true
  },
  {
    name: 'Usman Malik',
    phone: '0345-7778888',
    vehicle_type: 'bike',
    is_available: false
  },
  {
    name: 'Faisal Raza',
    phone: '0321-4445555',
    vehicle_type: 'bicycle',
    is_available: true
  }
];

async function insertRiders() {
  try {
    console.log('🚀 Starting rider insertion...\n');

    for (const rider of riders) {
      const result = await pool.query(
        `INSERT INTO rider (name, phone, vehicle_type, is_available)
         VALUES ($1, $2, $3, $4)
         RETURNING rider_id, name, vehicle_type`,
        [rider.name, rider.phone, rider.vehicle_type, rider.is_available]
      );

      console.log(`✅ Added rider: ${result.rows[0].name} (${result.rows[0].vehicle_type}) - ID: ${result.rows[0].rider_id}`);
    }

    // Show summary
    const countResult = await pool.query('SELECT COUNT(*) as total FROM rider');
    console.log(`\n🎉 Total riders in database: ${countResult.rows[0].total}`);

    // Show available riders
    const availableResult = await pool.query(
      'SELECT COUNT(*) as available FROM rider WHERE is_available = true'
    );
    console.log(`✅ Available riders: ${availableResult.rows[0].available}`);

    await pool.end();
  } catch (error) {
    console.error('❌ Error inserting riders:', error.message);
    process.exit(1);
  }
}

insertRiders();
