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
    rejectUnauthorized: false, // Accept self-signed certificates
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
      'SELECT * FROM restaurants WHERE is_active = true ORDER BY rating DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching restaurants:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get menu items for a restaurant
app.get('/api/restaurants/:id/menu', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT * FROM menu_items 
       WHERE restaurant_id = $1 AND is_available = true 
       ORDER BY category, name`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching menu items:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create a new order
app.post('/api/orders', async (req, res) => {
  try {
    const { user_id, restaurant_id, total_amount, delivery_address, items } = req.body;

    // Start transaction
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Insert order
      const orderResult = await client.query(
        `INSERT INTO orders (user_id, restaurant_id, total_amount, delivery_address, status)
         VALUES ($1, $2, $3, $4, 'pending')
         RETURNING id`,
        [user_id, restaurant_id, total_amount, delivery_address]
      );

      const orderId = orderResult.rows[0].id;

      // Insert order items
      for (const item of items) {
        await client.query(
          `INSERT INTO order_items (order_id, menu_item_id, quantity, price)
           VALUES ($1, $2, $3, $4)`,
          [orderId, item.menu_item_id, item.quantity, item.price]
        );
      }

      await client.query('COMMIT');
      res.json({ orderId, message: 'Order created successfully' });
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

// Get user's orders
app.get('/api/users/:userId/orders', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(
      `SELECT 
        o.*,
        r.name as restaurant_name,
        r.address as restaurant_address
       FROM orders o
       JOIN restaurants r ON o.restaurant_id = r.id
       WHERE o.user_id = $1
       ORDER BY o.created_at DESC`,
      [userId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update order status
app.patch('/api/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    await pool.query(
      `UPDATE orders 
       SET status = $1, updated_at = CURRENT_TIMESTAMP
       WHERE id = $2`,
      [status, id]
    );

    res.json({ message: 'Order status updated successfully' });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: error.message });
  }
});

// Search restaurants
app.get('/api/restaurants/search', async (req, res) => {
  try {
    const { q } = req.query;
    const result = await pool.query(
      `SELECT * FROM restaurants 
       WHERE is_active = true 
       AND (name ILIKE $1 OR address ILIKE $1)
       ORDER BY rating DESC`,
      [`%${q}%`]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error searching restaurants:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`🚀 FastFoodie API running on http://localhost:${port}`);
  console.log(`📡 API endpoints available at http://localhost:${port}/api`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  pool.end(() => {
    console.log('Database pool closed');
  });
});
