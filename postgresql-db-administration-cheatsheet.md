# PostgreSQL DBA Cheat Sheet

A collection of essential PostgreSQL queries, command-line utilities, and administrative scripts for Database Administration, continuous maintenance, and permission management.

## 1. Database & Connection Management

### Database Owner Check
```sql
-- Check owner for all databases
SELECT 
    d.datname AS database_name, 
    r.rolname AS owner_name 
FROM 
    pg_database d 
JOIN 
    pg_roles r ON d.datdba = r.oid 
ORDER BY 
    database_name;

-- Check owner for a specific database
SELECT 
    datname AS database_name, 
    pg_get_userbyid(datdba) AS owner 
FROM 
    pg_database 
WHERE 
    datname = '<database_name>';
```

### Database Size Check
```sql
-- Specific database size
SELECT pg_size_pretty(pg_database_size('<database_name>')) AS "Database Size";

-- Sizes of all databases
SELECT 
    datname AS "Database Name", 
    pg_size_pretty(pg_database_size(datname)) AS "Size", 
    pg_database_size(datname) AS "Size in Bytes" 
FROM 
    pg_database 
ORDER BY 
    pg_database_size(datname) DESC;
```

### Active Sessions & Connections
```sql
-- View all active sessions for a specific database
SELECT 
    datname AS "Database", 
    usename AS "User", 
    client_addr AS "Client IP (Source)", 
    client_port AS "Client Port", 
    backend_start AS "Connection Start Time", 
    state AS "State", 
    query AS "Current Query" 
FROM 
    pg_stat_activity 
WHERE 
    datname = '<database_name>' 
ORDER BY 
    backend_start DESC;
```

### Drop Database Connections
```sql
-- Safe termination (cancel current query)
SELECT pg_cancel_backend(<pid>);

-- Force termination (kill connection)
SELECT pg_terminate_backend(<pid>);

-- Kill all connections on a specific database
SELECT 
    pg_terminate_backend(pid) 
FROM 
    pg_stat_activity 
WHERE 
    datname = '<database_name>';
```

### Delete a Database
```sql
DROP DATABASE <database_name>;
```

## 2. Table & Permission Management

### Check User Access Permissions
Monitors user access policies. (Read Access: `SELECT`, Write Access: `INSERT`, `UPDATE`, `DELETE`)

```sql
SELECT 
    current_database() AS database_name,
    grantee AS database_user, 
    table_schema, 
    COUNT(DISTINCT table_name) AS total_tables_accessible,
    STRING_AGG(DISTINCT privilege_type, ', ') AS privileges_held
FROM information_schema.role_table_grants
WHERE privilege_type IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
  AND table_schema NOT IN ('pg_catalog', 'information_schema')
  -- Exclude public and GCP system accounts to keep results clean
  AND grantee NOT IN ('PUBLIC', 'postgres', 'cloudsqladmin', 'cloudsqlsuperuser', 'cloudsqliamuser', 'cloudsqlreplica') 
GROUP BY grantee, table_schema
ORDER BY table_schema, database_user;
```

### Check Table Owner
```sql
SELECT 
    schemaname, 
    tablename, 
    tableowner 
FROM 
    pg_tables 
WHERE 
    schemaname = 'public' 
    AND tablename = '<table_name>'; 
```

### Bulk Grant Select Permissions
A procedural block to easily share read access across multiple tables for dump creation when a target user lacks baseline permissions.

```sql
DO $$ 
DECLARE     
    tbl_record RECORD; 
BEGIN     
    -- Loop through all tables in 'public' owned by a specific source user  
    FOR tbl_record IN         
        SELECT tablename         
        FROM pg_tables         
        WHERE schemaname = 'public'           
          AND tableowner = '<source_username>'     
    LOOP         
        -- Execute the grant for each specific table found         
        EXECUTE format('GRANT SELECT ON TABLE public.%I TO <target_username>', tbl_record.tablename);                  
        
        -- Optional: Print execution logs to the console messages         
        RAISE NOTICE 'Granted SELECT on public.% to <target_username>', tbl_record.tablename;     
    END LOOP; 
END $$;
```

## 3. Backup and Restore (`pg_dump` / `pg_restore`)

### Database Backups
```bash
# Backup a full database
pg_dump -h <host_ip> -p 5432 -U <username> -d <database_name> --no-owner --no-privileges -Fc -f <backup_name>.dump

# Backup a specific table only
pg_dump -h <host_ip> -p 5432 -U <username> -d <database_name> --no-owner --no-privileges -Fc -t <schema.table_name> -f <backup_name>.dump
```

### Database Restoration
```bash
# Restore a specific database
pg_restore -h <host_ip> -p 5432 -U <username> -d <database_name> <backup_name>.dump

# Restore without ownership preservation
pg_restore -h <host_ip> -U <username> -d <database_name> --no-owner --no-privileges <backup_name>.dump

# Restore safely (clean target database structures first if objects already exist)
pg_restore -h <host_ip> -U <username> -d <database_name> --no-owner --no-privileges --clean --if-exists <backup_name>.dump
```

## 4. Google Cloud SQL Operations (Storage Shrink)

*Note: You may need to have the `alpha` components installed for `gcloud` to perform these operations.*

```bash
# Get minimum shrink size and time evaluation for the shrink
gcloud alpha sql instances get-storage-shrink-config <instance_name>

# Shrink the disk asynchronously to a specified target size
gcloud alpha sql instances perform-storage-shrink <instance_name> --storage-size=<target_storage_size> --async

# Shrink the read replica to match
gcloud alpha sql instances reset-replica-size <instance_name>
```