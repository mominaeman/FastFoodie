-- Add special_instructions column to Orders table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' AND column_name = 'special_instructions'
    ) THEN
        ALTER TABLE Orders ADD COLUMN special_instructions TEXT;
        PRINT 'Added special_instructions column to Orders table';
    ELSE
        PRINT 'special_instructions column already exists';
    END IF;
END $$;

-- Add updated_at column to Orders table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE Orders ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
        PRINT 'Added updated_at column to Orders table';
    ELSE
        PRINT 'updated_at column already exists';
    END IF;
END $$;
