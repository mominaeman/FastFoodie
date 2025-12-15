const { Pool } = require('pg');
const fs = require('fs');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || '104.197.103.44',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'fastfoodie',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false },
});

async function backupDatabase() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const filename = `fastfoodie_backup_${timestamp}.sql`;
  
  console.log('🔄 Starting database backup...\n');

  let sqlContent = `-- FastFoodie Database Backup
-- Date: ${new Date().toLocaleString()}
-- Database: fastfoodie
-- Host: 104.197.103.44

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

`;

  try {
    // Get all tables
    const tablesResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `);

    const tables = tablesResult.rows.map(r => r.table_name);
    console.log(`📊 Found ${tables.length} tables to backup:`);
    tables.forEach(t => console.log(`   - ${t}`));
    console.log();

    // Backup each table
    for (const tableName of tables) {
      console.log(`📦 Backing up table: ${tableName}...`);

      // Get table structure
      const structureResult = await pool.query(`
        SELECT 
          'CREATE TABLE ' || table_name || ' (' ||
          string_agg(
            column_name || ' ' || 
            CASE 
              WHEN data_type = 'character varying' THEN 'VARCHAR(' || character_maximum_length || ')'
              WHEN data_type = 'ARRAY' THEN udt_name
              ELSE UPPER(data_type)
            END ||
            CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END,
            ', '
          ) || ');' as create_statement
        FROM information_schema.columns
        WHERE table_name = $1
        GROUP BY table_name
      `, [tableName]);

      if (structureResult.rows.length > 0) {
        sqlContent += `\n-- Table: ${tableName}\n`;
        sqlContent += `DROP TABLE IF EXISTS ${tableName} CASCADE;\n`;
        sqlContent += structureResult.rows[0].create_statement + '\n\n';
      }

      // Get data
      const dataResult = await pool.query(`SELECT * FROM ${tableName}`);
      
      if (dataResult.rows.length > 0) {
        console.log(`   → ${dataResult.rows.length} rows`);
        
        // Get column names
        const columns = Object.keys(dataResult.rows[0]);
        
        dataResult.rows.forEach(row => {
          const values = columns.map(col => {
            const val = row[col];
            if (val === null) return 'NULL';
            if (typeof val === 'string') return `'${val.replace(/'/g, "''")}'`;
            if (val instanceof Date) return `'${val.toISOString()}'`;
            if (typeof val === 'boolean') return val ? 'TRUE' : 'FALSE';
            return val;
          });
          
          sqlContent += `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES (${values.join(', ')});\n`;
        });
        
        sqlContent += '\n';
      } else {
        console.log(`   → 0 rows (empty table)`);
      }
    }

    // Add foreign keys and constraints
    console.log('\n🔗 Adding constraints and foreign keys...');
    const constraintsResult = await pool.query(`
      SELECT 
        'ALTER TABLE ' || tc.table_name || 
        ' ADD CONSTRAINT ' || tc.constraint_name || 
        ' FOREIGN KEY (' || kcu.column_name || ')' ||
        ' REFERENCES ' || ccu.table_name || 
        ' (' || ccu.column_name || ')' ||
        CASE 
          WHEN rc.delete_rule = 'CASCADE' THEN ' ON DELETE CASCADE'
          WHEN rc.delete_rule = 'SET NULL' THEN ' ON DELETE SET NULL'
          ELSE ''
        END || ';' as constraint_sql
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu 
        ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage ccu 
        ON ccu.constraint_name = tc.constraint_name
      JOIN information_schema.referential_constraints rc
        ON rc.constraint_name = tc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_schema = 'public'
    `);

    if (constraintsResult.rows.length > 0) {
      sqlContent += '\n-- Foreign Key Constraints\n';
      constraintsResult.rows.forEach(row => {
        sqlContent += row.constraint_sql + '\n';
      });
    }

    // Write to file
    const filepath = `D:\\dbms_project\\${filename}`;
    fs.writeFileSync(filepath, sqlContent, 'utf8');

    const fileSize = (fs.statSync(filepath).size / 1024).toFixed(2);
    
    console.log('\n✅ Backup completed successfully!');
    console.log(`📁 File: ${filepath}`);
    console.log(`📊 Size: ${fileSize} KB`);
    console.log(`📅 Date: ${new Date().toLocaleString()}`);
    console.log('\n💡 To restore: psql -h 104.197.103.44 -U postgres -d fastfoodie -f "' + filename + '"');

    await pool.end();
  } catch (error) {
    console.error('❌ Backup failed:', error.message);
    process.exit(1);
  }
}

backupDatabase();
