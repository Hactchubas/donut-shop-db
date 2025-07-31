# 🍩  Donut Shop Database

A complete PostgreSQL database system for a donut shop. Perfect for development, testing, and demonstrations.

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.5-blue?logo=postgresql)](https://www.postgresql.org/)

## ✨ Features

- **🔄 Ephemeral Design**: All data is lost when containers stop - perfect for testing
- **🐳 Docker-Based**: Runs entirely in containers, no local PostgreSQL needed
- **🌍 Cross-Platform**: Works on Windows, Mac, and Linux
- **⚡ In-Memory Storage**: Database runs in tmpfs for maximum performance
- **📊 Admin Dashboard**: Vue.js-based web interface for managing the donut shop
- **🔧 Real-time Analytics**: Live dashboard with sales metrics and inventory tracking

## 🚀 Quick Start

### Prerequisites
- Docker
- Docker Compose

### Installation
```bash
# Clone the repository
git clone https://github.com/Hactchubas/donut-shop-db.git
cd donut-shop-db

# Option 1: Start with local admin interface (recommended)
bash start-local-admin.sh

# Option 2: Start all services in Docker (experimental)
bash container-scripts/start-admin.sh

# Option 3: Start only database and PgAdmin
docker-compose up postgres pgadmin -d
```

### Access Points
- **Admin Dashboard**: http://localhost:5173 (local) or http://localhost:3000 (Docker)
- **Database**: `localhost:5433`
- **PgAdmin**: http://localhost:8080

## 🛠️ Available Commands

```bash
# Start all services (including admin dashboard)
bash container-scripts/start-admin.sh

# Test all functionality
docker exec donut_shop_db bash /scripts/test.sh

# Database status
docker exec donut_shop_db bash /scripts/status.sh

# Connect as admin
docker exec -it donut_shop_db psql -U admin_donut_db -d donut_shop

# Connect as readonly
docker exec -it donut_shop_db psql -U readonly_donut_db -d donut_shop

# View admin application logs
docker-compose logs donut-admin

# Stop all services
docker-compose down
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
│   ├── start-admin.sh          # Start all services with admin
│   ├── test.sh
│   ├── status.sh
│   └── ...
├── donut-admin-vue/           # Vue.js Admin Dashboard
│   ├── Dockerfile
│   ├── src/
│   ├── server.js              # API server
│   └── ...
├── pgadmin/                   # PgAdmin configuration
└── docs/                      # Documentation
    ├── CONNECTIONS.md
    ├── SCHEMA.md
    └── TESTING.md
```

## 📚 Documentation

- [**Connection Guide**](docs/CONNECTIONS.md) - How to connect to the database
- [**Database Schema**](docs/SCHEMA.md) - Complete schema documentation
- [**Testing Guide**](docs/TESTING.md) - How to test all requirements

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
## 🏷️ Tags

`postgresql` `docker` `database`  `sgbd` `stored-procedures` `triggers` `brazilian` `donut-shop` `development` `testing`
