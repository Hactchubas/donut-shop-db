# README.md
# 🍩 Ephemeral Donut Shop Database

A complete PostgreSQL database system for a donut shop. Perfect for development, testing, and demonstrations.

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.5-blue?logo=postgresql)](https://www.postgresql.org/)

## ✨ Features

- **🔄 Ephemeral Design**: All data is lost when containers stop - perfect for testing
- **🐳 Docker-Based**: Runs entirely in containers, no local PostgreSQL needed
- **🌍 Cross-Platform**: Works on Windows, Mac, and Linux
- **⚡ In-Memory Storage**: Database runs in tmpfs for maximum performance

## 🚀 Quick Start

### Prerequisites
- Docker
- Docker Compose

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/donut-shop-database.git
cd donut-shop-database

# Start the containers
docker-compose up -d

# Wait for initialization
# Test everything
docker exec donut_shop_db bash /scripts/test.sh
```

### Access Points
- **Database**: `localhost:5433`
- **PgAdmin**: http://localhost:8080

## 🛠️ Available Commands

```bash
# Test all functionality
docker exec donut_shop_db bash /scripts/test.sh

# Database status
docker exec donut_shop_db bash /scripts/status.sh

# Connect as admin
docker exec -it donut_shop_db psql -U admin_donut_db -d donut_shop

# Connect as readonly
docker exec -it donut_shop_db psql -U readonly_donut_db -d donut_shop
```

## 📊 Sample Data

Every restart includes:
- Customers with CPF and addresses
- 10 customizable donut configurations
- 40 ingredients (massa, cobertura, recheio, topping)
- Sample orders and payments
- Pre-configured inventory levels

## 🏗️ Architecture

```
donut-shop-database/
├── docker-compose.yml           # Container orchestration
├── init-scripts/               # Database initialization
│   ├── 01-create-database.sql
│   ├── 02-create-tables.sql
│   ├── 03-insert-data.sql
│   ├── 04-create-functions-triggers.sql
│   ├── 05-create-views.sql
│   └── 06-create-users.sql
├── container-scripts/          # Management tools
│   ├── test.sh
│   ├── demo.sh
│   ├── status.sh
│   └── ...
└── docs/                      # Documentation
    ├── CONNECTIONS.md
    ├── SCHEMA.md
    └── TESTING.md
```

## 📚 Documentation

- [**Connection Guide**](docs/CONNECTIONS.md) - How to connect to the database
- [**Database Schema**](docs/SCHEMA.md) - Complete schema documentation
- [**Testing Guide**](docs/TESTING.md) - How to test all requirements
- [**Troubleshooting**](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🧪 Testing

Run comprehensive tests:
```bash
# All functionality
docker exec donut_shop_db bash /scripts/test.sh

# Performance benchmark
docker exec donut_shop_db bash /scripts/benchmark.sh

# Load testing
docker exec donut_shop_db bash /scripts/load-test.sh

# Health check
docker exec donut_shop_db bash /scripts/health-check.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`postgresql` `docker` `database` `ephemeral` `sgbd` `stored-procedures` `triggers` `brazilian` `donut-shop` `development` `testing`

---
# .gitignore
# Docker
.docker/

# IDE
.vscode/
.idea/
*.swp
.DS_Store

# Logs
*.log
logs/

# Temporary files
*.tmp
*.temp
.cache/

# OS
Thumbs.db
desktop.ini

# Backup files
*.bak
*.backup

# Environment files (if any secrets added later)
.env.local
.env.*.local

---
# LICENSE
MIT License

Copyright (c) 2025 Donut Shop Database Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
# docs/CONNECTIONS.md
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

### 4. External Tools (DBeaver, DataGrip, etc.)
- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `donut_shop`
- **Username:** Any of the users above
- **Password:** Corresponding password

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

---
# docs/SCHEMA.md
# Database Schema Documentation

## 📊 Tables Overview

### Core Business Tables

#### `cliente` - Customer Information
- **Primary Key:** `cpf` (VARCHAR(11))
- **Purpose:** Store Brazilian customer data with CPF validation
- **Fields:** email, telefone, senha, nome, rua, numero, bairro, cidade

#### `pedido` - Orders
- **Primary Key:** `pedido_num` (SERIAL)
- **Purpose:** Track customer orders
- **Fields:** data_h, valor, status, cpf_cliente
- **Status Values:** 'Pendente', 'Em Preparo', 'Entregue', 'Cancelado'

#### `pagamento` - Payments
- **Primary Key:** `id_pagamento` (SERIAL)
- **Purpose:** Track order payments
- **Fields:** metodo, id_pedido
- **Payment Methods:** 'Cartão', 'Pix', 'Dinheiro'

### Product Configuration Tables

#### `massa` - Donut Dough Types
- **Primary Key:** `id_massa` (SERIAL)
- **Types:** Tradicional, Chocolate, Integral, Baunilha, etc.
- **Pricing:** Individual prices for each type

#### `cobertura` - Donut Glazes/Toppings
- **Primary Key:** `id_cobertura` (SERIAL)
- **Types:** Chocolate, Açúcar, Morango, Nutella, etc.
- **Pricing:** Individual prices for each type

#### `recheio` - Donut Fillings
- **Primary Key:** `id_recheio` (SERIAL)
- **Types:** Chocolate, Doce de Leite, Nutella, etc.
- **Pricing:** Individual prices for each type

#### `topping` - Additional Toppings
- **Primary Key:** `id_topping` (SERIAL)
- **Types:** Granulado, Castanha, Mini M&Ms, etc.
- **Pricing:** Individual prices for each type

#### `donut` - Donut Configurations
- **Primary Key:** `id_donut` (SERIAL)
- **Purpose:** Define donut combinations
- **Fields:** preco, id_massa

### Relationship Tables

#### `donut_cobertura` - Donut to Glaze Mapping
#### `donut_recheio` - Donut to Filling Mapping
#### `donut_topping` - Donut to Topping Mapping
#### `pedido_donut` - Order to Donut Mapping
#### `favorito` - Customer Favorites

### System Tables

#### `auditoria_pedido` - Order Audit Trail
- **Purpose:** Track all order status changes
- **Fields:** pedido_num, status_anterior, status_novo, data_alteracao, motivo

#### `estoque_ingredientes` - Inventory Management
- **Purpose:** Track ingredient stock levels
- **Fields:** tipo_ingrediente, id_ingrediente, quantidade_disponivel, quantidade_minima

## 🔧 Functions and Triggers

### Stored Procedure
**`sp_relatorio_vendas(data_inicio, data_fim)`**
- Comprehensive sales reporting
- Returns aggregated statistics

### Triggers
1. **`trigger_estoque_pedido`** - Stock control
2. **`trigger_pagamento_status`** - Payment processing
3. **`trigger_auditoria_status_pedido`** - Audit logging

## 👁️ Views

### `vw_donut_detalhado`
- Complete donut information with calculated prices
- Joins all ingredient types

### `vw_estoque_baixo`
- Shows ingredients below minimum stock levels
- Used for inventory alerts

### `vw_pedidos_tempo`
- Shows pending orders with waiting times
- Helps track order processing

## 🔗 Relationships

```
cliente (1) ←→ (N) pedido
pedido (1) ←→ (N) pagamento
pedido (N) ←→ (N) donut
donut (1) → (1) massa
donut (N) ←→ (N) cobertura
donut (N) ←→ (N) recheio
donut (N) ←→ (N) topping
cliente (N) ←→ (N) donut (favorites)
```

---
# docs/TESTING.md
# Testing Guide

## 🧪 Automated Testing

### Complete Test Suite
```bash
# Run all tests
docker exec donut_shop_db bash /scripts/test.sh
```

### Individual Test Categories

#### Database Connectivity
```bash
docker exec donut_shop_db psql -U postgres -d donut_shop -c "SELECT 'Connected' as status;"
```

#### Stored Procedure Testing
```bash
docker exec donut_shop_db psql -U postgres -d donut_shop -c "
SELECT * FROM sp_relatorio_vendas('2025-06-01', '2025-07-31');
"
```

#### Trigger Testing
```bash
# Test stock control trigger
docker exec donut_shop_db psql -U postgres -d donut_shop -c "
-- Check stock before
SELECT quantidade_disponivel FROM estoque_ingredientes 
WHERE tipo_ingrediente = 'massa' AND id_ingrediente = 1;

-- Create order (triggers stock reduction)
INSERT INTO pedido (data_h, valor, status, cpf_cliente) 
VALUES (NOW(), 15.50, 'Pendente', '11111111111');

INSERT INTO pedido_donut (id_pedido, id_donut) 
VALUES (currval('pedido_pedido_num_seq'), 1);

-- Check stock after
SELECT quantidade_disponivel FROM estoque_ingredientes 
WHERE tipo_ingrediente = 'massa' AND id_ingrediente = 1;
"
```

#### User Permission Testing
```bash
# Test admin user
docker exec donut_shop_db psql -U admin_donut_db -d donut_shop -c "
SELECT COUNT(*) FROM cliente;
"

# Test readonly user
docker exec donut_shop_db psql -U readonly_donut_db -d donut_shop -c "
SELECT COUNT(*) FROM pedido;
"

# Test readonly restriction (should fail)
docker exec donut_shop_db psql -U readonly_donut_db -d donut_shop -c "
INSERT INTO cliente (cpf, email, nome, senha) 
VALUES ('99999999998', 'test@test.com', 'Test', 'pass');
"
```

## 🚀 Performance Testing

### Benchmark Tests
```bash
docker exec donut_shop_db bash /scripts/benchmark.sh
```

### Load Testing
```bash
docker exec donut_shop_db bash /scripts/load-test.sh
```

## 🏥 Health Checks

### System Health
```bash
docker exec donut_shop_db bash /scripts/health-check.sh
```

### Container Status
```bash
docker-compose ps
docker-compose logs postgres
```

## 📊 Interactive Testing

### Demo Interface
```bash
docker exec donut_shop_db bash /scripts/demo.sh
```

### Query Interface
```bash
docker exec donut_shop_db bash /scripts/queries.sh
```

## ✅ Expected Results

### Stored Procedure
Should return sales statistics including:
- Total orders
- Revenue totals and averages
- Top-selling products
- Most active customers
- Preferred payment methods

### Triggers
- Stock should reduce automatically when orders are created
- Order status should change when payments are added
- All changes should be logged in audit table

### Users
- Admin user should have full access
- Readonly user should only be able to SELECT
- Both users should be restricted to donut_shop database

---
# docs/TROUBLESHOOTING.md
# Troubleshooting Guide

## 🐛 Common Issues

### Container Won't Start
```bash
# Check status
docker-compose ps

# Check logs
docker-compose logs postgres
docker-compose logs pgadmin

# Restart containers
docker-compose down
docker-compose up -d
```

### Database Connection Failed
```bash
# Wait for initialization
sleep 60

# Test connection
docker exec donut_shop_db psql -U postgres -d donut_shop -c "SELECT 1;"

# Check PostgreSQL status
docker exec donut_shop_db pg_isready -U postgres
```

### Script Permission Denied
```bash
# Use bash to run scripts
docker exec donut_shop_db bash /scripts/test.sh

# Check if scripts are mounted
docker exec donut_shop_db ls -la /scripts/
```

### PgAdmin Not Accessible
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs pgadmin

# Try alternative port
# Edit docker-compose.yml: change "8080:80" to "8081:80"
# Then access http://localhost:8081
```

### Port Conflicts
Edit `docker-compose.yml`:
```yaml
# For PostgreSQL
ports:
  - "5433:5432"  # Change from 5432

# For PgAdmin  
ports:
  - "8081:80"    # Change from 8080
```

### Memory Issues
```bash
# Check memory usage
docker stats donut_shop_db

# Increase tmpfs size in docker-compose.yml:
tmpfs:
  - /var/lib/postgresql/data:rw,noexec,nosuid,size=2g  # Increase from 1g
```

## 🔧 Recovery Commands

### Complete Reset
```bash
docker-compose down
docker system prune -f
docker-compose up -d
sleep 30
docker exec donut_shop_db bash /scripts/test.sh
```

### Logs Collection
```bash
# Collect all logs
docker-compose logs > debug.log 2>&1

# Container-specific logs
docker-compose logs postgres > postgres.log
docker-compose logs pgadmin > pgadmin.log
```

### Network Issues
```bash
# Check network
docker network ls
docker network inspect donut-shop-database_donut_network

# Test container communication
docker exec donut_pgadmin ping donut_shop_db
```

## 📞 Getting Help

1. Check the [Issues](https://github.com/yourusername/donut-shop-database/issues) section
2. Create a new issue with:
   - Error message
   - Operating system
   - Docker version: `docker --version`
   - Container logs: `docker-compose logs`
