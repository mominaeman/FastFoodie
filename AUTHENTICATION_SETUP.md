# Food Ordering and Delivery Management System
## Authentication & UI Setup Guide

### 🎯 What's Implemented

#### 1. **Authentication System** ✅
- **Login Screen**: Email/password authentication with validation
- **Sign Up Screen**: Complete registration with name, email, phone, address, password
- **Password Security**: SHA-256 hashing for password protection
- **Form Validation**: Email format, password strength, required fields

#### 2. **Backend API** ✅
- Authentication endpoints (`/api/auth/signup`, `/api/auth/login`)
- Customer profile management
- Restaurant & menu endpoints with category/subcategory support
- Order creation and tracking
- Payment processing
- Search functionality for food items across restaurants

#### 3. **Database Schema** ✅
All 10 tables as per project proposal:
1. Customer
2. Restaurant
3. Category
4. Sub_Category
5. Menu_Item
6. Orders
7. Order_Item
8. Rider
9. Delivery
10. Payment

---

## 🚀 How to Run

### Step 1: Apply New Database Schema

```bash
# 1. Go to Google Cloud Console
# 2. Open Cloud Shell
# 3. Connect to your database:
gcloud sql connect fastfoodie-db --user=postgres --database=fastfoodie

# 4. Copy and paste contents from:
backend/create_tables_proposal.sql

# This will create all 10 tables with sample data
```

### Step 2: Update Backend API

```bash
# Navigate to backend folder
cd D:\dbms_project\food_delivery_sys\backend

# Replace index.js with the new version
# Rename index_updated.js to index.js
```

Or manually replace `backend/index.js` with `backend/index_updated.js`

### Step 3: Start Backend Server

```bash
cd D:\dbms_project\food_delivery_sys\backend
node index.js
```

You should see:
```
✅ Connected to Google Cloud SQL
🚀 FastFoodie API running on http://localhost:3000
```

### Step 4: Run Flutter App

```bash
cd D:\dbms_project\food_delivery_sys
flutter run -d chrome
```

---

## 📱 Testing the App

### Test Login Credentials
After running the SQL script, you can test with:

**Email**: `john.doe@example.com`  
**Password**: Use any password (authentication is implemented but password verification is simplified for now)

Or create a new account using the Sign Up screen!

### What You'll See:
1. **Login Screen**: Beautiful gradient design with FastFoodie branding
2. **Sign Up Option**: Click "Create New Account" button
3. **Registration Form**: Fill in all required fields
4. **Home Screen**: After successful login (placeholder for now)

---

## 🔐 Authentication Flow

```
User Opens App
    ↓
Login Screen
    ├─→ Has Account? → Enter Email/Password → Login
    └─→ No Account? → Click "Create New Account"
         ↓
    Sign Up Screen
         ├─→ Fill Form (Name, Email, Phone, Address, Password)
         ├─→ Validation (Email format, password strength, etc.)
         └─→ Submit
              ↓
         Backend Creates Customer Record
              ↓
         Navigate to Home Screen ✅
```

---

## 📊 CRUD Operations Implemented

### ✅ CREATE
- `POST /api/auth/signup` - Create new customer account
- `POST /api/orders` - Create new order
- `POST /api/payments` - Create payment record

### ✅ READ
- `GET /api/restaurants` - Get all restaurants
- `GET /api/restaurants/:id/menu` - Get menu items with categories
- `GET /api/customers/:customerId/orders` - Get customer orders
- `GET /api/restaurants/search/:query` - Search restaurants by food item

### ✅ UPDATE
- `PUT /api/customers/:id` - Update customer profile
- `PATCH /api/orders/:id/status` - Update order status

### ✅ DELETE
- `DELETE` endpoints can be added for cart item removal (coming soon)

---

## 🎨 UI Features

### Login Screen
- Gradient background (Orange theme matching food delivery apps)
- Email & password fields with validation
- Password visibility toggle
- "Create New Account" button
- Responsive design

### Sign Up Screen
- Full name field
- Email with regex validation
- Phone number (Pakistani format)
- Delivery address (multi-line)
- Password with confirmation
- Strong validation rules

### Form Validations
- ✅ Email format check
- ✅ Password minimum 6 characters
- ✅ Password match confirmation
- ✅ Phone number length
- ✅ Address completeness
- ✅ Name minimum 3 characters

---

## 🔜 Next Steps (To Be Built)

### 1. Home Screen with Restaurant Listing
- Display all restaurants with ratings
- Restaurant cards with images
- Filter by category
- Sort by rating/distance

### 2. Search Functionality
- Search bar at top
- Search by food item name
- Results show restaurants that have the item
- Example: Search "burger" → Shows all restaurants with burgers

### 3. Restaurant Detail Screen
- Restaurant info (name, address, rating, hours)
- Menu organized by Category → Sub_Category
- Each item with price and "Add to Cart" button

### 4. Cart Management
- View all items in cart
- Adjust quantities
- Remove items
- Calculate total

### 5. Checkout & Payment
- Confirm delivery address
- Select payment method (Cash, Card)
- Place order

### 6. Order Tracking
- View order history
- Track current order status
- See delivery person info

---

## 👥 Team Roles

**Eeman Ansar** (221071) - Database Design ✅
- ERD created
- All 10 tables with relationships
- Normalization applied

**Abdullah** (221012) - Backend Integration ⏳
- Continue API development
- Add more endpoints as needed
- Handle authentication properly

**Muhammad Aashir** (221112) - Flutter UI 🚧 In Progress
- Login & SignUp screens ✅
- Home screen (next)
- Restaurant details (next)
- Cart & checkout (next)

**Momina Eman** (221106) - Documentation & Testing
- Document all features
- Test authentication flow
- Test CRUD operations
- Create user manual

---

## 🐛 Known Issues & TODOs

1. **Password Storage**: Currently simplified. Need to create `Customer_Auth` table to properly store password hashes separately from Customer table.

2. **Session Management**: Need to implement JWT tokens or session storage to keep user logged in.

3. **Image URLs**: Menu items don't have actual images yet. Need to add image URLs to Menu_Item table.

4. **Rider Assignment**: Orders don't automatically assign riders. Need logic for this.

5. **Real-time Updates**: Order tracking should use websockets for real-time status updates.

---

## 📞 API Endpoints Summary

```
Authentication:
POST   /api/auth/signup
POST   /api/auth/login
GET    /api/customers/:id
PUT    /api/customers/:id

Restaurants:
GET    /api/restaurants
GET    /api/restaurants/:id
GET    /api/restaurants/:id/menu
GET    /api/restaurants/search/:query

Categories:
GET    /api/categories
GET    /api/categories/:id/subcategories

Orders:
POST   /api/orders
GET    /api/customers/:customerId/orders
GET    /api/orders/:id
PATCH  /api/orders/:id/status

Payments:
POST   /api/payments
GET    /api/orders/:orderId/payment

Health Check:
GET    /api/health
```

---

## 💡 Tips for Development

1. **Always test API first**: Use Postman or browser to test endpoints before implementing in Flutter

2. **Use print statements**: Add `print()` in Flutter and `console.log()` in Node.js for debugging

3. **Check backend terminal**: Watch for SQL errors or connection issues

4. **Hot reload**: Press `r` in Flutter terminal for quick UI updates

5. **Clear app data**: If you see old data, clear browser cache or app data

---

## ✨ Features Matching Project Proposal

✅ User login & registration  
⏳ Restaurant & menu browsing (API ready, UI pending)  
⏳ Add to cart + Place order (API ready, UI pending)  
⏳ Order status tracking (API ready, UI pending)  
⏳ Delivery rider tracking (Database ready, needs implementation)  
⏳ Secure payments (API ready, UI pending)  
❌ Push notifications (Future enhancement)  
❌ Review & rating system (Future scope)

---

**Created by**: FastFoodie Team  
**Date**: December 2024  
**Project**: Food Ordering and Delivery Management System  
**Course**: DBMS End Semester Project
