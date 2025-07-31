# 🍩 Donut Shop Admin Vue App

A simple Vue.js 3 admin interface for managing the donut shop database.

## Features

- **Dashboard**: Overview of key metrics and recent activity
- **Customer Management**: View and add new customers
- **Order Management**: Track and update order statuses
- **Donut Menu**: View available donut configurations
- **Inventory Management**: Monitor ingredient stock levels

## Prerequisites

1. Make sure the donut shop database is running:
   ```bash
   cd ..
   docker-compose up -d
   ```

2. Verify the database is accessible on port 5433

## Installation

```bash
npm install
```

## Running the Application

### Option 1: Run both server and client together
```bash
npm start
```

### Option 2: Run server and client separately
```bash
# Terminal 1 - API Server
npm run server

# Terminal 2 - Vue Dev Server
npm run dev
```

## Access Points

- **Vue App**: http://localhost:5173
- **API Server**: http://localhost:3001

## API Endpoints

The Express.js API server provides the following endpoints:

- `GET /api/test` - Test database connection
- `GET /api/customers` - List all customers
- `POST /api/customers` - Create new customer
- `GET /api/orders` - List all orders
- `PUT /api/orders/:id/status` - Update order status
- `GET /api/donuts` - List all donut configurations
- `GET /api/inventory` - List inventory items
- `GET /api/inventory/low-stock` - List low stock items
- `GET /api/analytics/dashboard` - Dashboard statistics

## Database Connection

The API connects to the PostgreSQL database using:
- Host: localhost
- Port: 5433
- Database: donut_shop
- User: admin_donut_db
- Password: donut_admin_2025

## Technology Stack

- **Frontend**: Vue.js 3, TypeScript, Vue Router
- **Backend**: Express.js, Node.js
- **Database**: PostgreSQL
- **HTTP Client**: Axios
- **Build Tool**: Vite

## Development

```bash
# Type checking
npm run type-check

# Linting
npm run lint

# Build for production
npm run build
```
