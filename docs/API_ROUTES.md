# Donut Shop API Routes Documentation

This document provides comprehensive documentation for all API routes available in the Donut Shop application.

## Base URL
```
http://localhost:3001
```

## Routes Overview

### Test & Health Routes

#### GET `/api/test`
**Description**: Test database connection and get current server time  
**Parameters**: None  
**Response**:
```json
{
  "success": true,
  "time": "2025-01-30T12:00:00.000Z"
}
```
**Status Codes**: 200 (Success), 500 (Database Error)

---

### Customer Management

#### GET `/api/customers`
**Description**: Retrieve all customers ordered by name  
**Parameters**: None  
**Response**:
```json
[
  {
    "cpf": "12345678901",
    "email": "customer@example.com",
    "telefone": "11999999999",
    "nome": "Customer Name",
    "rua": "Street Name",
    "numero": "123",
    "bairro": "Neighborhood",
    "cidade": "City",
    "senha": ""
  }
]
```
**Status Codes**: 200 (Success), 500 (Database Error)

#### POST `/api/customers`
**Description**: Create a new customer  
**Request Body**:
```json
{
  "cpf": "12345678901",
  "email": "customer@example.com",
  "telefone": "11999999999",
  "nome": "Customer Name",
  "rua": "Street Name",
  "numero": "123",
  "bairro": "Neighborhood",
  "cidade": "City"
}
```
**Response**: Returns the created customer object  
**Status Codes**: 200 (Success), 500 (Database Error)

---

### Order Management

#### GET `/api/orders`
**Description**: Retrieve all orders with customer and payment information  
**Parameters**: None  
**Response**:
```json
[
  {
    "pedido_num": 1,
    "cpf_cliente": "12345678901",
    "data_h": "2025-01-30T12:00:00.000Z",
    "valor": 15.50,
    "status": "Concluído",
    "cliente_nome": "Customer Name",
    "metodo_pagamento": "Cartão de Crédito"
  }
]
```
**Status Codes**: 200 (Success), 500 (Database Error)

#### PUT `/api/orders/:id/status`
**Description**: Update order status  
**Parameters**: 
- `id` (path): Order ID
**Request Body**:
```json
{
  "status": "Em Preparo"
}
```
**Response**: Returns the updated order object  
**Status Codes**: 200 (Success), 500 (Database Error)

---

### Donut Catalog

#### GET `/api/donuts`
**Description**: Retrieve all donuts with detailed information  
**Parameters**: None  
**Response**:
```json
[
  {
    "id_donut": 1,
    "massa_tipo": "Tradicional",
    "cobertura_tipo": "Chocolate",
    "recheio_tipo": "Brigadeiro",
    "topping_tipo": "Granulado",
    "preco_total": 8.50
  }
]
```
**Notes**: Uses the `vw_donut_detalhado` view  
**Status Codes**: 200 (Success), 500 (Database Error)

---

### Inventory Management

#### GET `/api/inventory`
**Description**: Retrieve complete inventory with ingredient details  
**Parameters**: None  
**Response**:
```json
[
  {
    "tipo_ingrediente": "massa",
    "id_ingrediente": 1,
    "quantidade_estoque": 50,
    "nome_ingrediente": "Tradicional"
  }
]
```
**Status Codes**: 200 (Success), 500 (Database Error)

#### GET `/api/inventory/low-stock`
**Description**: Retrieve items with low stock levels  
**Parameters**: None  
**Response**: Array of low stock items  
**Notes**: Uses the `vw_estoque_baixo` view  
**Status Codes**: 200 (Success), 500 (Database Error)

---

### Analytics & Reports

#### GET `/api/analytics/dashboard-supplementary`
**Description**: Get dashboard statistics and supplementary data  
**Query Parameters**:
- `startDate` (optional): Start date filter (YYYY-MM-DD)
- `endDate` (optional): End date filter (YYYY-MM-DD)

**Response**:
```json
{
  "totalCustomers": 150,
  "pendingOrders": 5,
  "lowStockItems": 3,
  "recentOrders": [
    {
      "pedido_num": 1,
      "data_h": "2025-01-30T12:00:00.000Z",
      "valor": 15.50,
      "status": "Concluído",
      "cliente_nome": "Customer Name"
    }
  ],
  "statusDistribution": [
    {
      "status": "Concluído",
      "count": "25"
    }
  ]
}
```
**Status Codes**: 200 (Success), 500 (Database Error)

#### GET `/api/analytics/sales-report`
**Description**: Generate sales report for a specific date range  
**Query Parameters** (Required):
- `startDate`: Start date (YYYY-MM-DD)
- `endDate`: End date (YYYY-MM-DD)

**Response**:
```json
{
  "total_pedidos": 50,
  "valor_total": 750.00,
  "valor_medio": 15.00,
  "periodo_inicio": "2025-01-01",
  "periodo_fim": "2025-01-30"
}
```
**Notes**: Uses the `sp_relatorio_vendas` stored procedure  
**Status Codes**: 200 (Success), 400 (Missing Parameters), 500 (Database Error)

#### GET `/api/analytics/date-range`
**Description**: Get the available date range for analytics  
**Parameters**: None  
**Response**:
```json
{
  "startDate": "2025-01-01",
  "endDate": "2025-01-30"
}
```
**Status Codes**: 200 (Success), 500 (Database Error)

---

## Error Handling

All endpoints return errors in the following format:
```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:
- `200`: Success
- `400`: Bad Request (missing required parameters)
- `500`: Internal Server Error (database or server issues)

---

## Database Connection

The API uses PostgreSQL with the following configuration:
- **Host**: postgres
- **Database**: donut_shop
- **User**: admin_donut_db
- **Port**: 5432

The server includes retry logic for database connections and will attempt to connect up to 10 times with 2-second intervals between attempts.