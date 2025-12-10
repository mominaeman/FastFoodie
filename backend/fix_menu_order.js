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

async function fixMenuOrder() {
  try {
    console.log('Connecting to database...');
    await pool.query('SELECT 1');
    console.log('✅ Connected!\n');

    // Check current menu for Burger Barn (restaurant_id = 2)
    console.log('Checking Burger Barn menu items...');
    const burgerBarnMenu = await pool.query(
      `SELECT item_id, item_name, price, sub_category_id 
       FROM Menu_Item 
       WHERE restaurant_id = 2 
       ORDER BY item_id`
    );
    
    console.log('\nCurrent Burger Barn menu:');
    burgerBarnMenu.rows.forEach(item => {
      console.log(`  ${item.item_id}. ${item.item_name} (sub_category: ${item.sub_category_id})`);
    });

    // Check subcategories to understand the structure
    console.log('\n\nChecking subcategories...');
    const subcats = await pool.query('SELECT * FROM Sub_Category ORDER BY sub_category_id');
    console.log('\nAvailable subcategories:');
    subcats.rows.forEach(sc => {
      console.log(`  ${sc.sub_category_id}. ${sc.sub_category_name} (category: ${sc.category_id})`);
    });

    // Ice cream subcategory should be 8, Burgers should be 2
    console.log('\n\n📊 Menu items by subcategory for all restaurants:');
    const allItems = await pool.query(
      `SELECT r.name as restaurant_name, mi.item_name, sc.sub_category_name, c.category_name
       FROM Menu_Item mi
       JOIN Restaurant r ON mi.restaurant_id = r.restaurant_id
       JOIN Sub_Category sc ON mi.sub_category_id = sc.sub_category_id
       JOIN Category c ON sc.category_id = c.category_id
       ORDER BY r.name, c.category_id, mi.item_name`
    );

    let currentRestaurant = '';
    allItems.rows.forEach(item => {
      if (item.restaurant_name !== currentRestaurant) {
        currentRestaurant = item.restaurant_name;
        console.log(`\n${currentRestaurant}:`);
      }
      console.log(`  - ${item.item_name} [${item.category_name} > ${item.sub_category_name}]`);
    });

    await pool.end();
    console.log('\n✅ Done!');
  } catch (error) {
    console.error('❌ Error:', error.message);
    await pool.end();
  }
}

fixMenuOrder();
