
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
