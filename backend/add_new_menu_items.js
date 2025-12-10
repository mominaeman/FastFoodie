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

async function addMenuItems() {
  try {
    console.log('Connecting to database...');
    await pool.query('SELECT 1');
    console.log('✅ Connected!\n');

    // Get the new restaurants (IDs 6-10)
    const restaurants = await pool.query(
      'SELECT restaurant_id, name FROM Restaurant WHERE restaurant_id BETWEEN 6 AND 10 ORDER BY restaurant_id'
    );
    
    console.log('Found restaurants:', restaurants.rows.length);
    
    // Get categories and subcategories
    const categories = await pool.query('SELECT * FROM Category');
    const subcategories = await pool.query('SELECT * FROM Sub_Category');
    
    console.log('Found categories:', categories.rows.length);
    console.log('Found subcategories:', subcategories.rows.length);
    console.log('\nAdding menu items for new restaurants...\n');

    // Menu items for Chinese Wok (restaurant_id = 6)
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Chow Mein', 'Stir-fried noodles with chicken and vegetables', 450, 11, 6, true),
      ('Sweet and Sour Chicken', 'Crispy chicken in tangy sweet and sour sauce', 550, 11, 6, true),
      ('Spring Rolls', 'Crispy vegetable rolls (4 pcs)', 250, 14, 6, true),
      ('Kung Pao Chicken', 'Spicy chicken with peanuts and vegetables', 500, 11, 6, true),
      ('Fried Rice', 'Chinese style fried rice with egg and vegetables', 300, 11, 6, true),
      ('Wonton Soup', 'Clear soup with chicken wontons', 350, 15, 6, true),
      ('Chicken Manchurian', 'Indo-Chinese style chicken in spicy gravy', 480, 11, 6, true),
      ('Hot and Sour Soup', 'Tangy and spicy soup with vegetables', 280, 15, 6, true),
      ('Szechuan Noodles', 'Spicy noodles with vegetables', 420, 11, 6, true),
      ('Egg Fried Rice', 'Fried rice with scrambled eggs', 320, 11, 6, true),
      ('Chicken Corn Soup', 'Creamy soup with chicken and sweet corn', 300, 15, 6, true),
      ('Honey Chilli Potato', 'Crispy potato tossed in honey chilli sauce', 350, 15, 6, true)
    `);
    console.log('✅ Chinese Wok menu items added');

    // Menu items for Pasta Palace (restaurant_id = 7)
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Alfredo Pasta', 'Creamy white sauce pasta with chicken', 550, 11, 7, true),
      ('Spaghetti Bolognese', 'Classic meat sauce pasta', 500, 11, 7, true),
      ('Penne Arrabiata', 'Spicy tomato sauce pasta', 450, 11, 7, true),
      ('Carbonara', 'Pasta with bacon, egg, and cheese', 580, 11, 7, true),
      ('Lasagna', 'Layered pasta with meat and cheese', 650, 11, 7, true),
      ('Garlic Bread', 'Toasted bread with garlic butter (4 pcs)', 200, 15, 7, true),
      ('Caesar Salad', 'Fresh salad with Caesar dressing', 350, 15, 7, true),
      ('Mushroom Risotto', 'Creamy Italian rice with mushrooms', 600, 11, 7, true),
      ('Chicken Pesto Pasta', 'Pasta with basil pesto sauce', 580, 11, 7, true),
      ('Marinara Pasta', 'Classic tomato and basil pasta', 420, 11, 7, true),
      ('Bruschetta', 'Toasted bread with tomato and basil (4 pcs)', 280, 15, 7, true),
      ('Tiramisu', 'Italian coffee-flavored dessert', 450, 8, 7, true)
    `);
    console.log('✅ Pasta Palace menu items added');

    // Menu items for BBQ Tonight (restaurant_id = 8)
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Tikka', 'Grilled marinated chicken pieces (6 pcs)', 450, 13, 8, true),
      ('Beef Seekh Kebab', 'Minced beef kebabs (4 pcs)', 500, 13, 8, true),
      ('Chicken Malai Boti', 'Creamy marinated chicken (6 pcs)', 480, 13, 8, true),
      ('Beef Ribs', 'Grilled beef ribs with BBQ sauce', 850, 13, 8, true),
      ('Chicken Wings BBQ', 'Spicy grilled wings (8 pcs)', 550, 14, 8, true),
      ('Mixed Grill Platter', 'Assorted BBQ items for 2 people', 1200, 13, 8, true),
      ('Reshmi Kebab', 'Soft minced chicken kebabs (4 pcs)', 420, 13, 8, true),
      ('Beef Steak', 'Grilled beef steak with sauce', 900, 13, 8, true),
      ('Garlic Naan', 'Fresh naan with garlic', 100, 11, 8, true),
      ('Raita', 'Yogurt with cucumber and spices', 120, 15, 8, true),
      ('Green Salad', 'Fresh vegetable salad', 150, 15, 8, true),
      ('Kheer', 'Traditional rice pudding', 200, 8, 8, true)
    `);
    console.log('✅ BBQ Tonight menu items added');

    // Menu items for Cafe Delight (restaurant_id = 9)
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Cappuccino', 'Classic Italian coffee with foam', 250, 7, 9, true),
      ('Latte', 'Espresso with steamed milk', 280, 7, 9, true),
      ('Espresso', 'Strong Italian coffee', 200, 7, 9, true),
      ('Iced Coffee', 'Cold coffee with ice', 300, 5, 9, true),
      ('Chocolate Brownie', 'Warm brownie with ice cream', 400, 9, 9, true),
      ('Club Sandwich', 'Triple decker sandwich with fries', 450, 3, 9, true),
      ('Chicken Caesar Wrap', 'Grilled chicken wrap with Caesar dressing', 420, 3, 9, true),
      ('Red Velvet Cake', 'Classic red velvet cake slice', 380, 9, 9, true),
      ('Cheesecake', 'New York style cheesecake', 450, 9, 9, true),
      ('Mocha', 'Coffee with chocolate', 320, 7, 9, true),
      ('Fresh Juice', 'Seasonal fresh fruit juice', 250, 6, 9, true),
      ('Croissant', 'Buttery French pastry', 200, 10, 9, true)
    `);
    console.log('✅ Cafe Delight menu items added');

    // Menu items for Biryani House (restaurant_id = 10)
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Biryani', 'Fragrant basmati rice with chicken', 350, 11, 10, true),
      ('Beef Biryani', 'Spicy beef biryani with aromatic spices', 400, 11, 10, true),
      ('Mutton Biryani', 'Traditional mutton biryani', 500, 11, 10, true),
      ('Veg Biryani', 'Mixed vegetable biryani', 280, 11, 10, true),
      ('Chicken Pulao', 'Mild rice dish with chicken', 300, 11, 10, true),
      ('Chicken Karahi', 'Spicy chicken curry in wok (1 kg)', 1200, 12, 10, true),
      ('Mutton Karahi', 'Tender mutton curry (1 kg)', 1500, 12, 10, true),
      ('Chicken Handi', 'Creamy chicken curry (1 kg)', 1000, 12, 10, true),
      ('Plain Rice', 'Steamed basmati rice', 120, 11, 10, true),
      ('Raita', 'Yogurt with cucumber', 100, 15, 10, true),
      ('Chicken Tikka (Starter)', 'Grilled chicken pieces (6 pcs)', 400, 14, 10, true),
      ('Gulab Jamun', 'Sweet dumplings in syrup (2 pcs)', 150, 8, 10, true)
    `);
    console.log('✅ Biryani House menu items added');

    // Get total count
    const totalItems = await pool.query('SELECT COUNT(*) as count FROM Menu_Item');
    console.log(`\n✅ Total menu items in database: ${totalItems.rows[0].count}`);

    await pool.end();
    console.log('\n✅ All done!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    await pool.end();
  }
}

addMenuItems();
