
# Database Connections Guide

## 🔗 Connection Information

### PostgreSQL Database
- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `donut_shop`
- **Encoding:** `UTF8`
- **Timezone:** `America/Sao_Paulo`

### PgAdmin Web Interface
- **URL:** http://localhost:8080
- **Email:** `admin@donutshop.com`
- **Password:** `pgadmin_donut_2025`

## 👥 Database Users

### Main Administrator
- **Username:** `postgres`
- **Password:** `donut_admin_2025`
- **Permissions:** Full superuser access

### Application Admin User
- **Username:** `admin_donut_db`
- **Password:** `admin_donut_2025!`
- **Permissions:** Full access to donut_shop database only

### Read-Only User
- **Username:** `readonly_donut_db`
- **Password:** `readonly_donut_2025!`
- **Permissions:** SELECT access to donut_shop database only

## 🔧 Connection Methods

### 1. Direct psql Connection
```bash
# As main admin
docker exec -it donut_shop_db psql -U postgres -d donut_shop

# As application admin
docker exec -it donut_shop_db psql -U admin_donut_db -d donut_shop

# As readonly user
docker exec -it donut_shop_db psql -U readonly_donut_db -d donut_shop
```

### 2. Using Connection Scripts
```bash
# Admin connection
docker exec -it donut_shop_db bash /scripts/connect-admin.sh

# Readonly connection
docker exec -it donut_shop_db bash /scripts/connect-readonly.sh
```

### 3. PgAdmin Setup
1. Access http://localhost:8080
2. Login with PgAdmin credentials
3. Add New Server:
   - **General Tab:**
     - Name: `Donut Shop Database`
   - **Connection Tab:**
     - Host: `donut_shop_db`
     - Port: `5432`
     - Database: `donut_shop`
     - Username: `postgres`
     - Password: `donut_admin_2025`
     
## 🧪 Testing Connections

```bash
# Test all users
docker exec donut_shop_db bash /scripts/test.sh

# Test specific user permissions
docker exec donut_shop_db psql -U readonly_donut_db -d donut_shop -c "SELECT COUNT(*) FROM cliente;"
```

## ⚠️ Important Notes

- **Ephemeral Data:** All data is lost when containers stop
- **Network:** Containers communicate via `donut_network`
- **Security:** Users are scoped to donut_shop database only
- **Storage:** Database runs in tmpfs (memory) for performance
 
