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
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Error connecting to the database:', err.stack);
  } else {
    console.log('✅ Connected to Google Cloud SQL');
    release();
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

    // Insert new customer (password is already hashed from Flutter)
    const result = await pool.query(
      `INSERT INTO Customer (name, email, phone, address) 
       VALUES ($1, $2, $3, $4) 
       RETURNING customer_id, name, email, phone, address, created_at`,
      [name, email, phone, address]
    );

    // Store password hash in a separate auth table (you'll need to create this)
    // For now, we'll use a simple approach - storing hash in memory or separate table
    // TODO: Create a Customer_Auth table for storing password hashes

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

    // For now, just verify email exists
    // TODO: Implement proper password verification with Customer_Auth table
    const result = await pool.query(
      'SELECT customer_id, name, email, phone, address, created_at FROM Customer WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // TODO: Verify password hash
    // const authResult = await pool.query('SELECT password_hash FROM Customer_Auth WHERE customer_id = $1', [result.rows[0].customer_id]);
    // if (authResult.rows[0].password_hash !== password) {
    //   return res.status(401).json({ error: 'Invalid credentials' });
    // }

    res.json(result.rows[0]);
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
// RESTAURANT ENDPOINTS
// ===========================

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT 1');
    res.json({ status: 'ok', message: 'Database connection successful' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// Get all restaurants
app.get('/api/restaurants', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM Restaurant WHERE is_active = true ORDER BY rating DESC'
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

// Search restaurants by food item
app.get('/api/restaurants/search/:query', async (req, res) => {
  try {
    const { query } = req.params;
    const result = await pool.query(
      `SELECT DISTINCT r.* 
       FROM Restaurant r
       JOIN Menu_Item mi ON r.restaurant_id = mi.restaurant_id
       WHERE r.is_active = true 
       AND (mi.item_name ILIKE $1 OR mi.description ILIKE $1)
       ORDER BY r.rating DESC`,
      [`%${query}%`]
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
      `SELECT mi.*, c.category_name, sc.sub_category_name
       FROM Menu_Item mi
       JOIN Sub_Category sc ON mi.sub_category_id = sc.sub_category_id
       JOIN Category c ON sc.category_id = c.category_id
       WHERE mi.restaurant_id = $1 AND mi.is_available = true 
       ORDER BY c.category_name, sc.sub_category_name, mi.item_name`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching menu items:', error);
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
    const { customer_id, restaurant_id, total_amount, delivery_address, items, special_instructions } = req.body;

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
