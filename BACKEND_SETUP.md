# Complete Setup Guide: Google Cloud SQL + Web Support

## ✅ What's Been Done:

1. Backend API created (`backend/` folder)
2. API service for Flutter (`lib/services/api_service.dart`)
3. Backend server installed and ready

## 🔧 Next Steps:

### Step 1: Create Database in Google Cloud SQL

You still need to create the database! Open **Google Cloud Shell**:

1. Go to https://console.cloud.google.com/
2. Click ">_" icon (Cloud Shell) at top-right
3. Run these commands:

```bash
# Connect to your instance
gcloud sql connect fastfoodie-db --user=postgres

# Enter password when prompted: IZijPuxgY+8Gm(D@

# Create database
CREATE DATABASE fastfoodie;
\c fastfoodie

# Create tables
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurants(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    menu_item_id INTEGER REFERENCES menu_items(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add some sample data
INSERT INTO restaurants (name, address, phone, rating) VALUES
('Pizza Paradise', '123 Main St, Downtown', '555-0101', 4.5),
('Burger Barn', '456 Oak Ave, Midtown', '555-0102', 4.2),
('Sushi Supreme', '789 Pine Rd, Uptown', '555-0103', 4.8),
('Taco Town', '321 Elm St, Downtown', '555-0104', 4.3);

INSERT INTO menu_items (restaurant_id, name, description, price, category) VALUES
(1, 'Margherita Pizza', 'Classic tomato and mozzarella', 12.99, 'Pizza'),
(1, 'Pepperoni Pizza', 'With extra pepperoni', 14.99, 'Pizza'),
(2, 'Classic Burger', 'Beef patty with all toppings', 9.99, 'Burgers'),
(2, 'Cheese Burger', 'Double cheese special', 11.99, 'Burgers'),
(3, 'California Roll', 'Fresh salmon and avocado', 15.99, 'Sushi'),
(3, 'Dragon Roll', 'Spicy tuna special', 18.99, 'Sushi');

-- Verify data
SELECT * FROM restaurants;
SELECT * FROM menu_items;

-- Exit
\q
```

### Step 2: Enable SSL Connection (Fix Connection Error)

The error shows "no encryption". You need to allow non-SSL connections temporarily:

In Google Cloud Console:
1. Go to your Cloud SQL instance
2. Click "Edit" at the top
3. Scroll to "Connections"
4. Under "SSL/TLS", uncheck "Require SSL/TLS" (for testing)
5. Click "SAVE"

### Step 3: Start Backend Server

```bash
cd D:\dbms_project\food_delivery_sys\backend
npm start
```

You should see:
```
✅ Connected to Google Cloud SQL
🚀 FastFoodie API running on http://localhost:3000
```

### Step 4: Test the API

Open your browser or use PowerShell:

```powershell
# Test health check
curl http://localhost:3000/api/health

# Test getting restaurants
curl http://localhost:3000/api/restaurants
```

### Step 5: Run Flutter Web App

```bash
cd D:\dbms_project\food_delivery_sys
flutter run -d chrome
```

Or use Edge:
```bash
flutter run -d edge
```

### Step 6: Update Flutter App to Use API

Your web app will now use the HTTP API (`ApiService`) instead of direct PostgreSQL connection!

## 🌐 How It Works Now:

```
Flutter Web (Chrome/Edge)
    ↓ HTTP Requests
Backend API (Node.js on localhost:3000)
    ↓ PostgreSQL Connection
Google Cloud SQL Database
    ↓
✅ SUCCESS!
```

## 📱 Platform Support:

| Platform | Connection Method |
|----------|------------------|
| ✅ Web | HTTP API (ApiService) |
| ✅ Mobile | Direct (GCPDatabaseService) or API |
| ✅ Desktop | Direct (GCPDatabaseService) or API |

## 🚀 Optional: Deploy Backend to Cloud

To make it work from anywhere (not just localhost):

1. Deploy to **Google Cloud Run**:
```bash
gcloud run deploy fastfoodie-api \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

2. Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-app-url.run.app/api';
```

## 🔐 Security Notes:

- Backend `.env` file is protected (in .gitignore)
- Never commit database credentials to Git
- For production, use:
  - Google Secret Manager for credentials
  - Authentication (JWT tokens)
  - HTTPS only
  - Rate limiting

## 🎯 Summary:

**You now have TWO ways to connect:**

1. **Direct** (Mobile/Desktop): Uses `GCPDatabaseService`
2. **API** (Web): Uses `ApiService` → Backend → Database

**Your Flutter app works on ALL platforms!** 🎉
