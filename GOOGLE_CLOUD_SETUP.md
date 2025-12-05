# Google Cloud Platform Setup Guide for FastFoodie

This guide will help you set up Google Cloud Platform (GCP) for your food delivery project with automatic backups.

## Architecture Overview

You'll set up:
1. **Cloud SQL (PostgreSQL)** - Production database with automatic backups
2. **Connection from Flutter App** - Connect your app to GCP database
3. **Automated Backups** - Daily backups as required by your teacher

## Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create a New Project**
   - Click the project dropdown at the top
   - Click "NEW PROJECT"
   - Enter project name: `fastfoodie-prod` (or your choice)
   - Click "CREATE"

3. **Enable Billing** (Required - has free tier)
   - Go to "Billing" in the menu
   - Link a billing account (Google provides $300 free credits for new users)

## Step 2: Set Up Cloud SQL (PostgreSQL Database)

### Create the Database Instance

1. **Navigate to Cloud SQL**
   - In the GCP Console, search for "Cloud SQL"
   - Or go to: https://console.cloud.google.com/sql

2. **Create Instance**
   - Click "CREATE INSTANCE"
   - Select "PostgreSQL"
   
3. **Configure Instance Settings**
   ```
   Instance ID: fastfoodie-db
   Password: [Create a strong password - SAVE THIS!]
   Database version: PostgreSQL 15 (recommended)
   Region: Choose closest to your location (e.g., us-central1)
   Zonal availability: Single zone (cheaper for development)
   ```

4. **Choose Configuration**
   
   **For Development/Student Projects (Recommended):**
   ```
   Machine type: Lightweight (1 vCPU, 3.75 GB)
   Storage: 10 GB SSD
   Enable automatic storage increase: Yes
   ```
   
   **For Production:**
   ```
   Machine type: Standard (2 vCPU, 7.5 GB)
   Storage: 20 GB SSD
   High availability: Optional (for critical apps)
   ```

5. **Configure Connections**
   - Under "Connections"
   - Check "Public IP"
   - Click "ADD NETWORK"
   - Name: `Allow All` (for testing)
   - Network: `0.0.0.0/0` (Allow from anywhere - change later for security)
   - Click "DONE"

6. **Configure Backups (IMPORTANT for your teacher)**
   - Under "Customize your instance" → "Backups"
   - Enable automated backups: ✓ YES
   - Backup window: Choose preferred time (e.g., 3:00 AM)
   - Number of backups to retain: 7 (one week)
   - Enable point-in-time recovery: ✓ YES (recommended)

7. **Click "CREATE INSTANCE"**
   - Wait 5-10 minutes for creation

### Get Connection Details

Once created, you'll see:
```
Instance connection name: project-id:region:instance-id
Public IP address: xxx.xxx.xxx.xxx
```

**Save these details!**

## Step 3: Create Your Database

1. **Open Cloud Shell** (top right in GCP Console)

2. **Connect to your instance:**
   ```bash
   gcloud sql connect fastfoodie-db --user=postgres
   ```

3. **Enter password** when prompted

4. **Create database:**
   ```sql
   CREATE DATABASE fastfoodie;
   \c fastfoodie
   ```

5. **Create tables for your food delivery system:**
   ```sql
   -- Users table
   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       email VARCHAR(255) UNIQUE NOT NULL,
       name VARCHAR(255) NOT NULL,
       phone VARCHAR(20),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Restaurants table
   CREATE TABLE restaurants (
       id SERIAL PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       address TEXT NOT NULL,
       phone VARCHAR(20),
       rating DECIMAL(3,2) DEFAULT 0.0,
       is_active BOOLEAN DEFAULT true,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Menu Items table
   CREATE TABLE menu_items (
       id SERIAL PRIMARY KEY,
       restaurant_id INTEGER REFERENCES restaurants(id),
       name VARCHAR(255) NOT NULL,
       description TEXT,
       price DECIMAL(10,2) NOT NULL,
       category VARCHAR(100),
       is_available BOOLEAN DEFAULT true,
       image_url TEXT,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Orders table
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

   -- Order Items table
   CREATE TABLE order_items (
       id SERIAL PRIMARY KEY,
       order_id INTEGER REFERENCES orders(id),
       menu_item_id INTEGER REFERENCES menu_items(id),
       quantity INTEGER NOT NULL,
       price DECIMAL(10,2) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Delivery Addresses table
   CREATE TABLE delivery_addresses (
       id SERIAL PRIMARY KEY,
       user_id INTEGER REFERENCES users(id),
       address_line1 TEXT NOT NULL,
       address_line2 TEXT,
       city VARCHAR(100) NOT NULL,
       state VARCHAR(100),
       postal_code VARCHAR(20),
       is_default BOOLEAN DEFAULT false,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Reviews table
   CREATE TABLE reviews (
       id SERIAL PRIMARY KEY,
       user_id INTEGER REFERENCES users(id),
       restaurant_id INTEGER REFERENCES restaurants(id),
       order_id INTEGER REFERENCES orders(id),
       rating INTEGER CHECK (rating >= 1 AND rating <= 5),
       comment TEXT,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

6. **Verify tables:**
   ```sql
   \dt
   ```

## Step 4: Connect Flutter App to Google Cloud SQL

### Option A: Direct Connection (For Development)

1. **Install PostgreSQL package:**
   ```yaml
   # Add to pubspec.yaml
   dependencies:
     postgres: ^3.0.0
   ```

2. **Create GCP config file:**
   ```dart
   // lib/gcp_config.dart
   class GCPConfig {
     static const String host = 'YOUR_PUBLIC_IP';
     static const int port = 5432;
     static const String database = 'fastfoodie';
     static const String username = 'postgres';
     static const String password = 'YOUR_PASSWORD';
   }
   ```

### Option B: Backend API (Recommended for Production)

Create a backend server (Node.js/Python) on:
- **Cloud Run** (serverless, auto-scaling)
- **App Engine** (managed platform)
- **Compute Engine** (full VM control)

Then Flutter app → API → Cloud SQL

## Step 5: Set Up Automated Backups

Your backups are already configured! But here's how to manage them:

### View Backups

1. Go to Cloud SQL → Your Instance
2. Click "BACKUPS" tab
3. See all automatic backups

### Manual Backup

1. In Cloud SQL instance page
2. Click "CREATE BACKUP"
3. Add description (e.g., "Before major update")
4. Click "CREATE"

### Restore from Backup

1. Go to "BACKUPS" tab
2. Find the backup you want
3. Click "⋮" (three dots)
4. Select "RESTORE"
5. Choose target instance
6. Confirm

### Export Backup (For Teacher Submission)

1. Go to Cloud SQL instance
2. Click "EXPORT"
3. Choose:
   - Cloud Storage bucket (create one if needed)
   - Format: SQL (recommended) or CSV
   - Database: fastfoodie
4. Click "EXPORT"
5. Download from Cloud Storage for submission

## Step 6: Cost Optimization

**Free Tier Eligible Setup:**
```
Cloud SQL: ~$10-15/month (smallest instance)
Storage: 10 GB
Backups: 7 days retention
```

**To minimize costs:**
- Use shared-core machine (db-f1-micro) - ~$7/month
- Schedule instance shutdown during non-use hours
- Delete old backups after teacher reviews project
- Use Supabase for development, GCP for production/backup

## Step 7: Security Best Practices

1. **Change Network Access**
   - After testing, replace `0.0.0.0/0` with your specific IP
   - Or use Cloud SQL Proxy for secure connections

2. **Strong Password**
   - Use a complex password for postgres user
   - Store in environment variables, never in code

3. **SSL Connection**
   - Enable SSL for production
   - Download server certificate from Cloud SQL

4. **Create Limited User**
   ```sql
   CREATE USER fastfoodie_app WITH PASSWORD 'strong_password';
   GRANT CONNECT ON DATABASE fastfoodie TO fastfoodie_app;
   GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO fastfoodie_app;
   ```

## Step 8: Monitoring and Maintenance

### Monitor Database

1. Go to Cloud SQL → Your Instance
2. Click "MONITORING" tab
3. View:
   - CPU usage
   - Memory usage
   - Storage usage
   - Connections

### Set Up Alerts

1. Go to "Monitoring" → "Alerting"
2. Create alert policies:
   - High CPU usage (>80%)
   - Low storage (<10%)
   - Failed backups

## Documentation for Your Teacher

### What to Show:

1. **Database Screenshot:**
   - Cloud SQL instance running
   - Backup schedule configured
   - Recent backup list

2. **Backup Evidence:**
   - Export a backup file
   - Show backup retention policy (7 days)
   - Screenshot of automated backup schedule

3. **Database Schema:**
   - Export schema as SQL file
   - Show table structure with relationships

4. **Cost Analysis:**
   - Monthly estimate from GCP billing
   - Free tier usage summary

## Alternative: Use Supabase + GCP for Backups

**Best of both worlds approach:**

1. **Primary Database:** Supabase (already set up)
   - Free tier
   - Built-in auth
   - Real-time features
   - Automatic backups

2. **Backup Database:** Google Cloud SQL
   - Daily sync from Supabase
   - Extra redundancy
   - Teacher requirement satisfied

3. **Sync Script:** Run daily cron job
   ```bash
   # Export from Supabase, import to GCP
   pg_dump supabase_db | psql gcp_db
   ```

## Troubleshooting

### Cannot Connect to Database
- Check Public IP is enabled
- Verify network allows your IP (0.0.0.0/0 for testing)
- Confirm password is correct
- Check instance is running (green icon)

### High Costs
- Use db-f1-micro instance (~$7/month)
- Reduce backup retention to 3 days
- Schedule shutdown during non-use (if allowed)

### Backup Failed
- Check storage quota
- Verify permissions
- Check Cloud SQL logs in Logging

## Resources

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud SQL Pricing](https://cloud.google.com/sql/pricing)
- [Backup Documentation](https://cloud.google.com/sql/docs/postgres/backup-recovery)
- [Security Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)

## Quick Commands Reference

```bash
# Connect to instance
gcloud sql connect fastfoodie-db --user=postgres

# Create backup
gcloud sql backups create --instance=fastfoodie-db

# List backups
gcloud sql backups list --instance=fastfoodie-db

# Export database
gcloud sql export sql fastfoodie-db gs://your-bucket/backup.sql \
  --database=fastfoodie

# Stop instance (save costs)
gcloud sql instances patch fastfoodie-db --activation-policy=NEVER

# Start instance
gcloud sql instances patch fastfoodie-db --activation-policy=ALWAYS
```

---

**Need Help?** Check the troubleshooting section or refer to Google Cloud documentation.
