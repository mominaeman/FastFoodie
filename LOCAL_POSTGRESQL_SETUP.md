# FastFoodie - Local PostgreSQL Setup Guide

## Step 1: Install PostgreSQL

1. Download PostgreSQL for Windows:
   https://www.postgresql.org/download/windows/
   
2. Run the installer (postgresql-16.x-windows-x64.exe)

3. During installation:
   - Port: 5432 (default)
   - Password: Choose a password (remember it!)
   - Leave other settings as default

## Step 2: Create Database

Open Command Prompt or PowerShell and run:

```bash
# Login to PostgreSQL
psql -U postgres

# Enter the password you set during installation

# Create database
CREATE DATABASE fastfoodie;

# Connect to it
\c fastfoodie

# Exit
\q
```

## Step 3: Update Backend Configuration

Edit `backend/.env` file:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fastfoodie
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD_HERE
```

## Step 4: Run Database Schema

```bash
cd backend
psql -U postgres -d fastfoodie -f schema.sql
```

Or manually run the CREATE TABLE commands from your original schema.

## Step 5: Add Sample Data

```bash
node add_menu_items.js
```

## Step 6: Start Backend

```bash
node index.js
```

You should see:
```
✅ Connected to PostgreSQL
🚀 FastFoodie API running on http://localhost:3000
```

## Step 7: Run Flutter App

```bash
flutter run -d chrome
```

## Troubleshooting

### PostgreSQL not starting?
```bash
# Windows - Start service
net start postgresql-x64-16

# Or use Services app (Win + R, type services.msc)
```

### Can't connect?
- Check password in .env matches PostgreSQL password
- Check PostgreSQL is running on port 5432
- Restart backend after changing .env

### Need to reset?
```sql
psql -U postgres
DROP DATABASE fastfoodie;
CREATE DATABASE fastfoodie;
\c fastfoodie
-- Run CREATE TABLE commands again
```
