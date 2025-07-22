\c donut_shop;

-- Create database users
DO $$
BEGIN
    -- Admin user with full privileges
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_donut_db') THEN
        CREATE USER admin_donut_db WITH PASSWORD 'admin_donut_2025!';
    END IF;
    
    -- Readonly user with limited privileges
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'readonly_donut_db') THEN
        CREATE USER readonly_donut_db WITH PASSWORD 'readonly_donut_2025!';
    END IF;
END
$$;

-- Grant privileges to admin user (full access)
GRANT CONNECT ON DATABASE donut_shop TO admin_donut_db;
GRANT USAGE ON SCHEMA public TO admin_donut_db;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_donut_db;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_donut_db;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin_donut_db;
GRANT CREATE ON SCHEMA public TO admin_donut_db;

-- Grant privileges to readonly user (read-only access)
GRANT CONNECT ON DATABASE donut_shop TO readonly_donut_db;
GRANT USAGE ON SCHEMA public TO readonly_donut_db;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_donut_db;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly_donut_db;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin_donut_db;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO admin_donut_db;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO admin_donut_db;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly_donut_db;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO readonly_donut_db;
