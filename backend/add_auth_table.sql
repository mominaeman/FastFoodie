-- Add password_hash column to Customer table
ALTER TABLE Customer ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- This will allow us to store hashed passwords for existing and new customers
