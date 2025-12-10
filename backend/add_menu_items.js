const { Pool } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false
  }
});

async function addSampleMenuItems() {
  try {
    console.log('Connecting to database...');
    
    // Get the first restaurant
    const restaurantResult = await pool.query(
      'SELECT restaurant_id FROM Restaurant LIMIT 1'
    );
    
    if (restaurantResult.rows.length === 0) {
      console.log('No restaurants found. Adding sample restaurants...');
      
      // Add sample restaurants
      await pool.query(`
        INSERT INTO Restaurant (name, location, contact_number, opening_time, closing_time, rating)
        VALUES 
          ('Pizza Palace', 'Karachi, Sindh', '+92 300 1234567', '10:00:00', '23:00:00', 4.5),
          ('Burger Hub', 'Lahore, Punjab', '+92 321 9876543', '11:00:00', '01:00:00', 4.2),
          ('Desi Dhaba', 'Islamabad, Capital', '+92 333 5555555', '08:00:00', '22:00:00', 4.7)
      `);
      
      console.log('Sample restaurants added!');
    }
    
    // Get all restaurants
    const restaurants = await pool.query('SELECT restaurant_id, name FROM Restaurant');
    console.log(`Found ${restaurants.rows.length} restaurants`);
    
    // Get or create categories
    const categoryCheck = await pool.query('SELECT category_id FROM Category LIMIT 1');
    
    if (categoryCheck.rows.length === 0) {
      console.log('No categories found. Adding sample categories...');
      
      await pool.query(`
        INSERT INTO Category (category_name)
        VALUES ('Fast Food'), ('Beverages'), ('Desserts'), ('Main Course')
      `);
      
      console.log('Sample categories added!');
    }
    
    // Get categories
    const categories = await pool.query('SELECT category_id, category_name FROM Category');
    console.log(`Found ${categories.rows.length} categories`);
    
    // Get or create subcategories
    const subCategoryCheck = await pool.query('SELECT sub_category_id FROM Sub_Category LIMIT 1');
    
    if (subCategoryCheck.rows.length === 0) {
      console.log('No subcategories found. Adding sample subcategories...');
      
      const fastFoodCat = categories.rows.find(c => c.category_name === 'Fast Food');
      const beveragesCat = categories.rows.find(c => c.category_name === 'Beverages');
      const dessertsCat = categories.rows.find(c => c.category_name === 'Desserts');
      const mainCourseCat = categories.rows.find(c => c.category_name === 'Main Course');
      
      await pool.query(`
        INSERT INTO Sub_Category (sub_category_name, category_id)
        VALUES 
          ('Pizza', $1),
          ('Burgers', $1),
          ('Sandwiches', $1),
          ('Soft Drinks', $2),
          ('Juices', $2),
          ('Ice Cream', $3),
          ('Cakes', $3),
          ('Biryani', $4),
          ('Karahi', $4)
      `, [fastFoodCat.category_id, beveragesCat.category_id, dessertsCat.category_id, mainCourseCat.category_id]);
      
      console.log('Sample subcategories added!');
    }
    
    // Get subcategories
    const subCategories = await pool.query(`
      SELECT sc.*, c.category_name 
      FROM Sub_Category sc 
      JOIN Category c ON sc.category_id = c.category_id
    `);
    console.log(`Found ${subCategories.rows.length} subcategories`);
    
    // Check if menu items already exist
    const menuCheck = await pool.query('SELECT COUNT(*) as count FROM Menu_Item');
    
    if (parseInt(menuCheck.rows[0].count) > 0) {
      console.log(`Database already has ${menuCheck.rows[0].count} menu items.`);
      console.log('Skipping menu item insertion.');
    } else {
      console.log('Adding sample menu items...');
      
      // Add menu items for each restaurant
      for (const restaurant of restaurants.rows) {
        console.log(`\nAdding menu items for ${restaurant.name}...`);
        
        // Pizza items
        const pizzaSub = subCategories.rows.find(s => s.sub_category_name === 'Pizza');
        if (pizzaSub) {
          await pool.query(`
            INSERT INTO Menu_Item (item_name, description, price, restaurant_id, sub_category_id, is_available)
            VALUES 
              ('Margherita Pizza', 'Classic tomato and mozzarella', 899, $1, $2, true),
              ('Pepperoni Pizza', 'Loaded with pepperoni', 1099, $1, $2, true),
              ('BBQ Chicken Pizza', 'Grilled chicken with BBQ sauce', 1299, $1, $2, true)
          `, [restaurant.restaurant_id, pizzaSub.sub_category_id]);
        }
        
        // Burger items
        const burgerSub = subCategories.rows.find(s => s.sub_category_name === 'Burgers');
        if (burgerSub) {
          await pool.query(`
            INSERT INTO Menu_Item (item_name, description, price, restaurant_id, sub_category_id, is_available)
            VALUES 
              ('Classic Burger', 'Beef patty with lettuce and tomato', 499, $1, $2, true),
              ('Cheese Burger', 'With extra cheese', 599, $1, $2, true),
              ('Chicken Burger', 'Crispy chicken fillet', 549, $1, $2, true)
          `, [restaurant.restaurant_id, burgerSub.sub_category_id]);
        }
        
        // Beverage items
        const drinksSub = subCategories.rows.find(s => s.sub_category_name === 'Soft Drinks');
        if (drinksSub) {
          await pool.query(`
            INSERT INTO Menu_Item (item_name, description, price, restaurant_id, sub_category_id, is_available)
            VALUES 
              ('Coca Cola', 'Chilled soft drink', 150, $1, $2, true),
              ('Pepsi', 'Refreshing cola', 150, $1, $2, true),
              ('Sprite', 'Lemon lime soda', 150, $1, $2, true)
          `, [restaurant.restaurant_id, drinksSub.sub_category_id]);
        }
        
        // Biryani items
        const biryaniSub = subCategories.rows.find(s => s.sub_category_name === 'Biryani');
        if (biryaniSub) {
          await pool.query(`
            INSERT INTO Menu_Item (item_name, description, price, restaurant_id, sub_category_id, is_available)
            VALUES 
              ('Chicken Biryani', 'Spicy chicken with aromatic rice', 450, $1, $2, true),
              ('Beef Biryani', 'Tender beef chunks with rice', 550, $1, $2, true),
              ('Mutton Biryani', 'Premium mutton biryani', 650, $1, $2, true)
          `, [restaurant.restaurant_id, biryaniSub.sub_category_id]);
        }
        
        // Dessert items
        const iceCreamSub = subCategories.rows.find(s => s.sub_category_name === 'Ice Cream');
        if (iceCreamSub) {
          await pool.query(`
            INSERT INTO Menu_Item (item_name, description, price, restaurant_id, sub_category_id, is_available)
            VALUES 
              ('Chocolate Ice Cream', 'Rich chocolate flavor', 299, $1, $2, true),
              ('Vanilla Ice Cream', 'Classic vanilla', 249, $1, $2, true),
              ('Strawberry Ice Cream', 'Fresh strawberry', 279, $1, $2, true)
          `, [restaurant.restaurant_id, iceCreamSub.sub_category_id]);
        }
      }
      
      console.log('\n✅ Sample menu items added successfully!');
    }
    
    // Verify the data
    const finalCount = await pool.query('SELECT COUNT(*) as count FROM Menu_Item');
    console.log(`\nTotal menu items in database: ${finalCount.rows[0].count}`);
    
    // Show sample from each restaurant
    for (const restaurant of restaurants.rows) {
      const items = await pool.query(
        'SELECT item_name, price FROM Menu_Item WHERE restaurant_id = $1 LIMIT 5',
        [restaurant.restaurant_id]
      );
      console.log(`\n${restaurant.name} menu sample:`);
      items.rows.forEach(item => {
        console.log(`  - ${item.item_name}: Rs. ${item.price}`);
      });
    }
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

addSampleMenuItems();
