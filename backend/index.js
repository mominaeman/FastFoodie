const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS for Flutter web app
app.use(cors());
app.use(express.json());

// PostgreSQL connection pool
const pool = new Pool({
  host: process.env.DB_HOST || '34.29.54.186',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'fastfoodie',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false,
  },
  connectionTimeoutMillis: 5000, // 5 second timeout
  idleTimeoutMillis: 30000,
  max: 10,
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Error connecting to the database:', err.message);
    console.error('📋 Please check:');
    console.error('   1. Is your Cloud SQL instance running?');
    console.error('   2. Is billing enabled on your Google Cloud project?');
    console.error('   3. Is your IP address whitelisted?');
    console.error('   4. Check your .env file has correct credentials');
    console.error('\n💡 To fix: Enable billing at https://console.cloud.google.com/billing');
  } else {
    console.log('✅ Connected to Google Cloud SQL');
    release();
  }
});

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', message: 'Database connection successful' });
  } catch (error) {
    res.status(500).json({ 
      status: 'error', 
      message: error.message,
      hint: 'Check if your Cloud SQL instance is running and billing is enabled'
    });
  }
});

// ===========================
// AUTHENTICATION ENDPOINTS
// ===========================

// Sign Up - Create new customer
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, phone, address, password } = req.body;

    // Check if email already exists
    const existingUser = await pool.query(
      'SELECT customer_id FROM Customer WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // Insert new customer with password hash (password is already hashed from Flutter)
    const result = await pool.query(
      `INSERT INTO Customer (name, email, phone, address, password_hash) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING customer_id, name, email, phone, address, created_at`,
      [name, email, phone, address, password]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Sign up error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Login - Authenticate customer
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Get customer with password hash
    const result = await pool.query(
      'SELECT customer_id, name, email, phone, address, created_at, password_hash FROM Customer WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password hash (password from Flutter is already hashed)
    if (!user.password_hash || user.password_hash !== password) {
      console.log('Password mismatch for user:', email);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Remove password_hash from response
    const { password_hash, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get customer by ID
app.get('/api/customers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT customer_id, name, email, phone, address, created_at FROM Customer WHERE customer_id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching customer:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update customer profile
app.put('/api/customers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone, address } = req.body;

    const result = await pool.query(
      `UPDATE Customer 
       SET name = $1, phone = $2, address = $3 
       WHERE customer_id = $4 
       RETURNING customer_id, name, email, phone, address`,
      [name, phone, address, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating customer:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================
// ADDRESS ENDPOINTS
// ===========================

// Get all addresses for a customer
app.get('/api/customers/:id/addresses', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT address_id, customer_id, label, address_line, is_default, created_at 
       FROM Address 
       WHERE customer_id = $1 
       ORDER BY is_default DESC, created_at ASC`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching addresses:', error);
    res.status(500).json({ error: error.message });
  }
});

// Add new address for a customer
app.post('/api/customers/:id/addresses', async (req, res) => {
  try {
    const { id } = req.params;
    const { label, address_line, is_default } = req.body;

    // If this is set as default, unset all other defaults for this customer
    if (is_default) {
      await pool.query(
        'UPDATE Address SET is_default = FALSE WHERE customer_id = $1',
        [id]
      );
    }

    const result = await pool.query(
      `INSERT INTO Address (customer_id, label, address_line, is_default) 
       VALUES ($1, $2, $3, $4) 
       RETURNING address_id, customer_id, label, address_line, is_default, created_at`,
      [id, label, address_line, is_default || false]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error adding address:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update an address
app.put('/api/addresses/:addressId', async (req, res) => {
  try {
    const { addressId } = req.params;
    const { label, address_line, is_default, customer_id } = req.body;

    // If this is set as default, unset all other defaults for this customer
    if (is_default && customer_id) {
      await pool.query(
        'UPDATE Address SET is_default = FALSE WHERE customer_id = $1 AND address_id != $2',
        [customer_id, addressId]
      );
    }

    const result = await pool.query(
      `UPDATE Address 
       SET label = $1, address_line = $2, is_default = $3 
       WHERE address_id = $4 
       RETURNING address_id, customer_id, label, address_line, is_default`,
      [label, address_line, is_default, addressId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Address not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating address:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete an address
app.delete('/api/addresses/:addressId', async (req, res) => {
  try {
    const { addressId } = req.params;
    
    // Check if this is a default address
    const checkDefault = await pool.query(
      'SELECT is_default, customer_id FROM Address WHERE address_id = $1',
      [addressId]
    );

    if (checkDefault.rows.length === 0) {
      return res.status(404).json({ error: 'Address not found' });
    }

    const wasDefault = checkDefault.rows[0].is_default;
    const customerId = checkDefault.rows[0].customer_id;

    // Delete the address
    await pool.query('DELETE FROM Address WHERE address_id = $1', [addressId]);

    // If deleted address was default, set first remaining address as default
    if (wasDefault) {
      await pool.query(
        `UPDATE Address 
         SET is_default = TRUE 
         WHERE address_id = (
           SELECT address_id FROM Address 
           WHERE customer_id = $1 
           ORDER BY created_at ASC 
           LIMIT 1
         )`,
        [customerId]
      );
    }

    res.json({ message: 'Address deleted successfully' });
  } catch (error) {
    console.error('Error deleting address:', error);
    res.status(500).json({ error: error.message });
  }
});

// Set default address
app.put('/api/addresses/:addressId/set-default', async (req, res) => {
  try {
    const { addressId } = req.params;
    
    // Get customer_id for this address
    const addressResult = await pool.query(
      'SELECT customer_id FROM Address WHERE address_id = $1',
      [addressId]
    );

    if (addressResult.rows.length === 0) {
      return res.status(404).json({ error: 'Address not found' });
    }

    const customerId = addressResult.rows[0].customer_id;

    // Unset all defaults for this customer
    await pool.query(
      'UPDATE Address SET is_default = FALSE WHERE customer_id = $1',
      [customerId]
    );

    // Set this address as default
    const result = await pool.query(
      `UPDATE Address 
       SET is_default = TRUE 
       WHERE address_id = $1 
       RETURNING address_id, customer_id, label, address_line, is_default`,
      [addressId]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error setting default address:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================
// RESTAURANT ENDPOINTS
// ===========================

// Get all restaurants
app.get('/api/restaurants', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM Restaurant ORDER BY rating DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching restaurants:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get restaurant by ID
app.get('/api/restaurants/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT * FROM Restaurant WHERE restaurant_id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching restaurant:', error);
    res.status(500).json({ error: error.message });
  }
});

// Search restaurants by food item, restaurant name, or location
app.get('/api/restaurants/search/:query', async (req, res) => {
  try {
    const { query } = req.params;
    
    // Require at least 2 characters to search
    if (!query || query.trim().length < 2) {
      return res.json([]);
    }
    
    const searchPattern = `%${query}%`;
    const result = await pool.query(
      `SELECT DISTINCT r.* 
       FROM Restaurant r
       LEFT JOIN Menu_Item mi ON r.restaurant_id = mi.restaurant_id
       WHERE r.name ILIKE $1 
          OR r.location ILIKE $1
          OR mi.item_name ILIKE $1 
          OR mi.description ILIKE $1
       ORDER BY r.rating DESC`,
      [searchPattern]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error searching restaurants:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================
// MENU ENDPOINTS
// ===========================

// Get menu items for a restaurant with category info
app.get('/api/restaurants/:id/menu', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT mi.*, sc.sub_category_name, c.category_name, c.category_id
       FROM Menu_Item mi
       LEFT JOIN Sub_Category sc ON mi.sub_category_id = sc.sub_category_id
       LEFT JOIN Category c ON sc.category_id = c.category_id
       WHERE mi.restaurant_id = $1 AND mi.is_available = true
       ORDER BY 
         CASE c.category_id 
           WHEN 5 THEN 1  -- Appetizers/Starters first
           WHEN 4 THEN 2  -- Main Course second
           WHEN 1 THEN 3  -- Fast Food third
           WHEN 3 THEN 4  -- Desserts fourth
           WHEN 2 THEN 5  -- Beverages last
           ELSE 6
         END,
         mi.item_name`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching menu:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all categories
app.get('/api/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Category ORDER BY category_name');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get subcategories by category
app.get('/api/categories/:id/subcategories', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT * FROM Sub_Category WHERE category_id = $1 ORDER BY sub_category_name',
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching subcategories:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================
// ORDER ENDPOINTS
// ===========================

// Create a new order
app.post('/api/orders', async (req, res) => {
  try {
    const { customer_id, restaurant_id, total_amount, delivery_address, items, special_instructions, payment_method } = req.body;

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Insert order
      const orderResult = await client.query(
        `INSERT INTO Orders (customer_id, restaurant_id, total_amount, delivery_address, special_instructions, status)
         VALUES ($1, $2, $3, $4, $5, 'pending')
         RETURNING order_id, customer_id, restaurant_id, order_date, status, total_amount, delivery_address`,
        [customer_id, restaurant_id, total_amount, delivery_address, special_instructions || null]
      );

      const orderId = orderResult.rows[0].order_id;

      // Insert order items
      for (const item of items) {
        await client.query(
          `INSERT INTO Order_Item (order_id, item_id, quantity, price)
           VALUES ($1, $2, $3, $4)`,
          [orderId, item.item_id, item.quantity, item.price]
        );
      }

      // Insert payment record
      await client.query(
        `INSERT INTO Payment (order_id, payment_method, payment_status, amount)
         VALUES ($1, $2, $3, $4)`,
        [orderId, payment_method || 'COD', 'Pending', total_amount]
      );

      await client.query('COMMIT');
      res.status(201).json(orderResult.rows[0]);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get customer orders
app.get('/api/customers/:customerId/orders', async (req, res) => {
  try {
    const { customerId } = req.params;
    const result = await pool.query(
      `SELECT o.*, r.name as restaurant_name, r.location as restaurant_location
       FROM Orders o
       JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
       WHERE o.customer_id = $1
       ORDER BY o.order_date DESC`,
      [customerId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get order details with items
app.get('/api/orders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get order info
    const orderResult = await pool.query(
      `SELECT o.*, r.name as restaurant_name, c.name as customer_name
       FROM Orders o
       JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
       JOIN Customer c ON o.customer_id = c.customer_id
       WHERE o.order_id = $1`,
      [id]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Get order items
    const itemsResult = await pool.query(
      `SELECT oi.*, mi.item_name, mi.description
       FROM Order_Item oi
       JOIN Menu_Item mi ON oi.item_id = mi.item_id
       WHERE oi.order_id = $1`,
      [id]
    );

    res.json({
      ...orderResult.rows[0],
      items: itemsResult.rows,
    });
  } catch (error) {
    console.error('Error fetching order details:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update order status
app.patch('/api/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const result = await pool.query(
      `UPDATE Orders 
       SET status = $1, updated_at = CURRENT_TIMESTAMP 
       WHERE order_id = $2 
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===========================
// PAYMENT ENDPOINTS
// ===========================

// Create payment
app.post('/api/payments', async (req, res) => {
  try {
    const { order_id, payment_method, net_price, cash_paid, transaction_id } = req.body;

    const result = await pool.query(
      `INSERT INTO Payment (order_id, payment_method, net_price, cash_paid, transaction_id, payment_status)
       VALUES ($1, $2, $3, $4, $5, 'completed')
       RETURNING *`,
      [order_id, payment_method, net_price, cash_paid, transaction_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating payment:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get payment by order ID
app.get('/api/orders/:orderId/payment', async (req, res) => {
  try {
    const { orderId } = req.params;
    const result = await pool.query(
      'SELECT * FROM Payment WHERE order_id = $1',
      [orderId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching payment:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`🚀 FastFoodie API running on http://localhost:${port}`);
});
