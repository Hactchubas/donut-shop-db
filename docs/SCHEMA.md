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

