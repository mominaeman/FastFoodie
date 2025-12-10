# Local Development Setup

## Option A: Enable Google Cloud Billing
Your Cloud SQL instance needs billing enabled to run.

## Option B: Use Local PostgreSQL

### Install PostgreSQL:
1. Download: https://www.postgresql.org/download/windows/
2. Install with default settings
3. Remember the password you set for 'postgres' user

### Update .env file:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fastfoodie
DB_USER=postgres
DB_PASSWORD=your_local_password
```

### Create database and tables:
```bash
# Open psql
psql -U postgres

# Create database
CREATE DATABASE fastfoodie;

# Connect to it
\c fastfoodie

# Run the table creation SQL from your schema
```

### Import your existing data:
Use the scripts in backend/ folder to add restaurants and menu items.

## Option C: Use Mock Data (Testing Only)
The backend can work with mock data if database is unavailable.
