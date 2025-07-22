#container-scripts/benchmark.sh - Performance benchmarking
#!/bin/bash

echo "⚡ Performance Benchmark - Ephemeral Database"
echo "============================================"

echo "🔄 Running performance tests..."

# Test stored procedure performance
echo "1️⃣  Stored Procedure Performance:"
time psql -U postgres -d donut_shop -c "
SELECT * FROM sp_relatorio_vendas('2025-01-01', '2025-12-31');
" > /dev/null

# Test view performance
echo ""
echo "2️⃣  View Query Performance:"
time psql -U postgres -d donut_shop -c "
SELECT * FROM vw_donut_detalhado;
" > /dev/null

# Test insert performance (triggers)
echo ""
echo "3️⃣  Insert Performance (with triggers):"
time psql -U postgres -d donut_shop -c "
INSERT INTO pedido (data_h, valor, status, cpf_cliente) 
VALUES (NOW(), 15.50, 'Pendente', '11111111111');

INSERT INTO pedido_donut (id_pedido, id_donut) 
VALUES (currval('pedido_pedido_num_seq'), 1);
" > /dev/null

# Database size
echo ""
echo "4️⃣  Database Size:"
psql -U postgres -d donut_shop -c "
SELECT 
    pg_database.datname as database_name,
    pg_size_pretty(pg_database_size(pg_database.datname)) as size
FROM pg_database 
WHERE datname = 'donut_shop';
"

echo ""
echo "✅ Benchmark completed!"
