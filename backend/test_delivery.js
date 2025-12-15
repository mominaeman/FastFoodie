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

async function testDeliverySystem() {
  try {
    console.log('🧪 Testing Delivery System...\n');

    // 1. Check delivery table structure
    console.log('1️⃣ Checking delivery table structure:');
    const tableInfo = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'delivery'
      ORDER BY ordinal_position
    `);
    console.table(tableInfo.rows);

    // 2. Check riders
    console.log('\n2️⃣ Available Riders:');
    const riders = await pool.query('SELECT * FROM rider WHERE is_available = true');
    console.table(riders.rows);

    // 3. Check recent orders
    console.log('\n3️⃣ Recent Orders:');
    const orders = await pool.query('SELECT order_id, customer_id, status, total_amount FROM orders ORDER BY order_id DESC LIMIT 5');
    console.table(orders.rows);

    // 4. Check deliveries
    console.log('\n4️⃣ Existing Deliveries:');
    const deliveries = await pool.query(`
      SELECT d.*, r.name as rider_name, o.status as order_status
      FROM delivery d
      JOIN rider r ON d.rider_id = r.rider_id
      JOIN orders o ON d.order_id = o.order_id
      ORDER BY d.delivery_id DESC
    `);
    if (deliveries.rows.length > 0) {
      console.table(deliveries.rows);
    } else {
      console.log('   No deliveries found yet.');
    }

    // 5. Test creating a delivery for the latest order
    if (orders.rows.length > 0 && riders.rows.length > 0) {
      const latestOrder = orders.rows[0];
      const firstRider = riders.rows[0];

      console.log(`\n5️⃣ Testing auto-assignment for Order #${latestOrder.order_id}...`);
      
      // Check if already has delivery
      const existingDelivery = await pool.query(
        'SELECT * FROM delivery WHERE order_id = $1',
        [latestOrder.order_id]
      );

      if (existingDelivery.rows.length > 0) {
        console.log('   ✅ Order already has delivery assigned:');
        console.table(existingDelivery.rows);
      } else {
        console.log(`   Creating delivery with Rider #${firstRider.rider_id} (${firstRider.name})...`);
        
        const newDelivery = await pool.query(`
          INSERT INTO delivery (order_id, rider_id, status, pickup_time)
          VALUES ($1, $2, 'picked_up', CURRENT_TIMESTAMP)
          RETURNING *
        `, [latestOrder.order_id, firstRider.rider_id]);

        console.log('   ✅ Delivery created:');
        console.table(newDelivery.rows);

        // Test the API query
        console.log('\n6️⃣ Testing API query (with JOIN):');
        const apiResult = await pool.query(`
          SELECT d.*, r.name as rider_name, r.phone as rider_phone, r.vehicle_type
          FROM delivery d
          JOIN rider r ON d.rider_id = r.rider_id
          WHERE d.order_id = $1
        `, [latestOrder.order_id]);

        console.table(apiResult.rows);
      }
    }

    console.log('\n✅ Test complete!');
    await pool.end();
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
}

testDeliverySystem();
