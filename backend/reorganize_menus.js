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

async function reorganizeMenus() {
  try {
    console.log('Connecting to database...');
    await pool.query('SELECT 1');
    console.log('✅ Connected!\n');

    // Get all restaurants
    const restaurants = await pool.query('SELECT * FROM Restaurant ORDER BY restaurant_id');
    
    console.log('Current menu items:');
    for (const restaurant of restaurants.rows) {
      const menu = await pool.query(
        `SELECT item_id, item_name, price, sub_category_id 
         FROM Menu_Item 
         WHERE restaurant_id = $1 
         ORDER BY item_id`,
        [restaurant.restaurant_id]
      );
      
      console.log(`\n${restaurant.restaurant_id}. ${restaurant.name}:`);
      menu.rows.forEach(item => {
        console.log(`   ${item.item_id}. ${item.item_name}`);
      });
    }

    console.log('\n\n=== REORGANIZING MENUS ===\n');

    // Delete all existing menu items
    await pool.query('DELETE FROM Menu_Item');
    console.log('✅ Cleared all menu items\n');

    // Pizza Paradise - Pizza focused
    console.log('Adding Pizza Paradise menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Margherita Pizza', 'Classic tomato and mozzarella', 650, 8, 1, true),
      ('Pepperoni Pizza', 'Loaded with pepperoni', 750, 8, 1, true),
      ('BBQ Chicken Pizza', 'BBQ sauce with chicken', 850, 8, 1, true),
      ('Veggie Supreme Pizza', 'Loaded with vegetables', 700, 8, 1, true),
      ('Meat Lovers Pizza', 'Beef, chicken, and pepperoni', 950, 8, 1, true),
      ('Hawaiian Pizza', 'Ham and pineapple', 800, 8, 1, true),
      ('Garlic Bread', 'Fresh bread with garlic butter', 200, 4, 1, true),
      ('Chicken Wings', 'Spicy buffalo wings (8 pcs)', 450, 13, 1, true),
      ('Caesar Salad', 'Fresh romaine with Caesar dressing', 300, 4, 1, true),
      ('Chocolate Lava Cake', 'Warm chocolate cake with molten center', 400, 3, 1, true),
      ('Vanilla Ice Cream', 'Classic vanilla (2 scoops)', 250, 9, 1, true),
      ('Coke', 'Chilled soft drink', 100, 11, 1, true)
    `);

    // Burger Barn - Burger focused
    console.log('Adding Burger Barn menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Classic Burger', 'Beef patty with lettuce and tomato', 350, 12, 2, true),
      ('Cheese Burger', 'Beef burger with melted cheese', 400, 12, 2, true),
      ('Double Burger', 'Two beef patties with cheese', 550, 12, 2, true),
      ('Chicken Burger', 'Grilled chicken fillet burger', 380, 12, 2, true),
      ('Zinger Burger', 'Spicy crispy chicken burger', 420, 12, 2, true),
      ('Beef Bacon Burger', 'Burger with beef bacon strips', 500, 12, 2, true),
      ('French Fries', 'Crispy golden fries', 180, 5, 2, true),
      ('Loaded Fries', 'Fries with cheese and jalapeños', 280, 5, 2, true),
      ('Onion Rings', 'Crispy fried onion rings', 220, 5, 2, true),
      ('Chicken Nuggets', 'Crispy nuggets (6 pcs)', 300, 13, 2, true),
      ('Chocolate Milkshake', 'Thick chocolate shake', 350, 11, 2, true),
      ('Strawberry Ice Cream', 'Fresh strawberry (2 scoops)', 250, 9, 2, true)
    `);

    // Sushi Supreme - Sushi focused
    console.log('Adding Sushi Supreme menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('California Roll', 'Crab, avocado, and cucumber (8 pcs)', 650, 4, 3, true),
      ('Salmon Roll', 'Fresh salmon sushi roll (8 pcs)', 850, 4, 3, true),
      ('Tuna Roll', 'Premium tuna roll (8 pcs)', 900, 4, 3, true),
      ('Dragon Roll', 'Eel and avocado roll (8 pcs)', 1200, 4, 3, true),
      ('Rainbow Roll', 'Mixed fish roll (8 pcs)', 1100, 4, 3, true),
      ('Vegetable Roll', 'Mixed vegetables (8 pcs)', 500, 4, 3, true),
      ('Nigiri Set', 'Assorted nigiri (10 pcs)', 1500, 4, 3, true),
      ('Sashimi Platter', 'Fresh fish slices (15 pcs)', 1800, 4, 3, true),
      ('Tempura Shrimp', 'Fried shrimp (6 pcs)', 700, 13, 3, true),
      ('Miso Soup', 'Traditional Japanese soup', 250, 4, 3, true),
      ('Green Tea Ice Cream', 'Japanese green tea flavor', 350, 9, 3, true),
      ('Sake', 'Japanese rice wine (glass)', 500, 11, 3, true)
    `);

    // Taco Town - Mexican focused
    console.log('Adding Taco Town menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Beef Tacos', 'Seasoned beef tacos (3 pcs)', 450, 4, 4, true),
      ('Chicken Tacos', 'Grilled chicken tacos (3 pcs)', 420, 4, 4, true),
      ('Fish Tacos', 'Crispy fish tacos (3 pcs)', 500, 4, 4, true),
      ('Vegetarian Tacos', 'Bean and veggie tacos (3 pcs)', 380, 4, 4, true),
      ('Beef Burrito', 'Large flour tortilla with beef', 550, 4, 4, true),
      ('Chicken Burrito', 'Large tortilla with chicken', 520, 4, 4, true),
      ('Nachos Supreme', 'Loaded nachos with cheese and jalapeños', 480, 5, 4, true),
      ('Quesadilla', 'Cheese and chicken quesadilla', 450, 4, 4, true),
      ('Guacamole & Chips', 'Fresh guacamole with tortilla chips', 350, 5, 4, true),
      ('Mexican Rice', 'Seasoned rice with vegetables', 200, 4, 4, true),
      ('Churros', 'Fried dough with cinnamon sugar (5 pcs)', 300, 3, 4, true),
      ('Horchata', 'Traditional rice drink', 200, 11, 4, true)
    `);

    // Desi Delights - Pakistani/Indian focused
    console.log('Adding Desi Delights menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Biryani', 'Fragrant basmati rice with chicken', 400, 1, 5, true),
      ('Beef Biryani', 'Spicy beef biryani', 450, 1, 5, true),
      ('Mutton Biryani', 'Traditional mutton biryani', 550, 1, 5, true),
      ('Chicken Karahi', 'Spicy chicken curry (1 kg)', 1200, 7, 5, true),
      ('Mutton Karahi', 'Tender mutton curry (1 kg)', 1500, 7, 5, true),
      ('Chicken Tikka', 'Grilled chicken pieces (6 pcs)', 450, 2, 5, true),
      ('Seekh Kebab', 'Minced meat kebabs (4 pcs)', 400, 2, 5, true),
      ('Chapli Kebab', 'Flat spiced kebabs (2 pcs)', 350, 2, 5, true),
      ('Plain Naan', 'Fresh tandoori bread', 50, 4, 5, true),
      ('Garlic Naan', 'Naan with garlic', 80, 4, 5, true),
      ('Raita', 'Yogurt with cucumber', 100, 5, 5, true),
      ('Gulab Jamun', 'Sweet dumplings (2 pcs)', 150, 9, 5, true)
    `);

    // Chinese Wok - Chinese focused
    console.log('Adding Chinese Wok menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Chow Mein', 'Stir-fried noodles with chicken', 450, 4, 6, true),
      ('Beef Chow Mein', 'Stir-fried noodles with beef', 500, 4, 6, true),
      ('Vegetable Chow Mein', 'Stir-fried noodles with vegetables', 380, 4, 6, true),
      ('Chicken Fried Rice', 'Chinese style fried rice', 400, 4, 6, true),
      ('Sweet and Sour Chicken', 'Crispy chicken in tangy sauce', 550, 4, 6, true),
      ('Kung Pao Chicken', 'Spicy chicken with peanuts', 500, 4, 6, true),
      ('Chicken Manchurian', 'Indo-Chinese chicken in gravy', 480, 4, 6, true),
      ('Spring Rolls', 'Vegetable rolls (4 pcs)', 250, 5, 6, true),
      ('Hot and Sour Soup', 'Tangy spicy soup', 280, 4, 6, true),
      ('Chicken Corn Soup', 'Creamy soup with chicken', 300, 4, 6, true),
      ('Honey Chilli Potato', 'Crispy potato in honey chilli sauce', 350, 5, 6, true),
      ('Fortune Cookies', 'Traditional fortune cookies (3 pcs)', 100, 3, 6, true)
    `);

    // Pasta Palace - Italian focused
    console.log('Adding Pasta Palace menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Spaghetti Bolognese', 'Classic meat sauce pasta', 500, 4, 7, true),
      ('Alfredo Pasta', 'Creamy white sauce with chicken', 550, 4, 7, true),
      ('Carbonara', 'Pasta with bacon, egg, and cheese', 580, 4, 7, true),
      ('Penne Arrabiata', 'Spicy tomato sauce pasta', 450, 4, 7, true),
      ('Chicken Pesto Pasta', 'Pasta with basil pesto', 580, 4, 7, true),
      ('Lasagna', 'Layered pasta with meat and cheese', 650, 4, 7, true),
      ('Marinara Pasta', 'Classic tomato basil pasta', 420, 4, 7, true),
      ('Garlic Bread', 'Toasted garlic butter bread (4 pcs)', 200, 5, 7, true),
      ('Caesar Salad', 'Romaine with Caesar dressing', 350, 5, 7, true),
      ('Bruschetta', 'Toasted bread with tomato (4 pcs)', 280, 5, 7, true),
      ('Tiramisu', 'Coffee-flavored Italian dessert', 450, 3, 7, true),
      ('Italian Soda', 'Flavored sparkling beverage', 200, 11, 7, true)
    `);

    // BBQ Tonight - BBQ/Grill focused
    console.log('Adding BBQ Tonight menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Tikka', 'Grilled marinated chicken (6 pcs)', 450, 2, 8, true),
      ('Chicken Malai Boti', 'Creamy marinated chicken (6 pcs)', 480, 2, 8, true),
      ('Beef Seekh Kebab', 'Minced beef kebabs (4 pcs)', 500, 2, 8, true),
      ('Reshmi Kebab', 'Soft minced chicken kebabs (4 pcs)', 420, 2, 8, true),
      ('Beef Ribs', 'Grilled beef ribs with BBQ sauce', 850, 2, 8, true),
      ('Beef Steak', 'Grilled beef steak with sauce', 900, 2, 8, true),
      ('Chicken Wings BBQ', 'Spicy grilled wings (8 pcs)', 550, 13, 8, true),
      ('Mixed Grill Platter', 'Assorted BBQ items for 2', 1200, 2, 8, true),
      ('Garlic Naan', 'Fresh tandoori naan', 100, 4, 8, true),
      ('Mint Raita', 'Yogurt with mint', 120, 5, 8, true),
      ('Green Salad', 'Fresh vegetable salad', 150, 5, 8, true),
      ('Kheer', 'Traditional rice pudding', 200, 9, 8, true)
    `);

    // Cafe Delight - Cafe/Coffee focused
    console.log('Adding Cafe Delight menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Cappuccino', 'Classic Italian coffee with foam', 250, 10, 9, true),
      ('Latte', 'Espresso with steamed milk', 280, 10, 9, true),
      ('Espresso', 'Strong Italian coffee', 200, 10, 9, true),
      ('Mocha', 'Coffee with chocolate', 320, 10, 9, true),
      ('Iced Coffee', 'Cold coffee with ice', 300, 11, 9, true),
      ('Hot Chocolate', 'Rich chocolate drink', 280, 10, 9, true),
      ('Club Sandwich', 'Triple decker with fries', 450, 4, 9, true),
      ('Chicken Caesar Wrap', 'Grilled chicken wrap', 420, 4, 9, true),
      ('Croissant', 'Buttery French pastry', 200, 6, 9, true),
      ('Chocolate Brownie', 'Warm brownie with ice cream', 400, 3, 9, true),
      ('Red Velvet Cake', 'Classic cake slice', 380, 3, 9, true),
      ('Cheesecake', 'New York style cheesecake', 450, 3, 9, true)
    `);

    // Biryani House - Biryani/Pakistani focused
    console.log('Adding Biryani House menu...');
    await pool.query(`
      INSERT INTO Menu_Item (item_name, description, price, sub_category_id, restaurant_id, is_available) VALUES
      ('Chicken Biryani', 'Fragrant rice with chicken', 350, 1, 10, true),
      ('Beef Biryani', 'Spicy beef biryani', 400, 1, 10, true),
      ('Mutton Biryani', 'Traditional mutton biryani', 500, 1, 10, true),
      ('Vegetable Biryani', 'Mixed vegetable biryani', 280, 1, 10, true),
      ('Chicken Pulao', 'Mild rice dish with chicken', 300, 1, 10, true),
      ('Chicken Karahi', 'Spicy chicken curry (1 kg)', 1200, 7, 10, true),
      ('Mutton Karahi', 'Tender mutton curry (1 kg)', 1500, 7, 10, true),
      ('Chicken Handi', 'Creamy chicken curry (1 kg)', 1000, 7, 10, true),
      ('Plain Rice', 'Steamed basmati rice', 120, 4, 10, true),
      ('Raita', 'Yogurt with cucumber', 100, 5, 10, true),
      ('Chicken Tikka', 'Grilled chicken (6 pcs)', 400, 2, 10, true),
      ('Gulab Jamun', 'Sweet dumplings (2 pcs)', 150, 9, 10, true)
    `);

    console.log('\n✅ All menus reorganized!\n');

    // Show new menu structure
    console.log('=== NEW MENU STRUCTURE ===\n');
    for (const restaurant of restaurants.rows) {
      const menu = await pool.query(
        `SELECT mi.item_name, sc.sub_category_name, c.category_name
         FROM Menu_Item mi
         LEFT JOIN Sub_Category sc ON mi.sub_category_id = sc.sub_category_id
         LEFT JOIN Category c ON sc.category_id = c.category_id
         WHERE mi.restaurant_id = $1 
         ORDER BY mi.item_id`,
        [restaurant.restaurant_id]
      );
      
      console.log(`\n${restaurant.name}:`);
      menu.rows.forEach((item, index) => {
        console.log(`   ${index + 1}. ${item.item_name} [${item.category_name || 'N/A'}]`);
      });
    }

    await pool.end();
    console.log('\n✅ Done!');
  } catch (error) {
    console.error('❌ Error:', error.message);
    await pool.end();
  }
}

reorganizeMenus();
