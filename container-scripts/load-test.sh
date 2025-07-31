# container-scripts/load-test.sh - Load testing
#!/bin/bash

echo "🚀 Load Test - Creating Multiple Orders"
echo "======================================="

echo "📊 Creating 50 test orders to stress-test the system..."

for i in $(seq 1 50); do
    # Rotate through customers
    customer_cpf=$(echo "11111111111 22222222222 33333333333 44444444444 55555555555" | cut -d' ' -f$((($i % 5) + 1)))
    
    # Random donut ID (1-10)
    donut_id=$(($i % 5 + 1))
    
    # Random value
    value=$(echo "scale=2; 10 + ($i % 20)" | bc 2>/dev/null || echo "15.50")
    
    psql -U postgres -d donut_shop -c "
    INSERT INTO pedido (data_h, valor, status, cpf_cliente) 
    SELECT NOW(), dd.preco_total, 'Pendente', '$customer_cpf'
      FROM vw_donut_detalhado dd
      WHERE dd.id_donut = $donut_id
      ORDER BY dd.id_donut
    LIMIT 1;
    
    INSERT INTO pedido_donut (id_pedido, id_donut) 
    VALUES (currval('pedido_pedido_num_seq'), $donut_id);
    "
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "Created $i orders..."
    fi
done

echo ""
echo "✅ Load test completed! Created 50 orders."
echo "📊 Checking results..."

psql -U postgres -d donut_shop -c "
SELECT 
    COUNT(*) as total_orders,
    AVG(valor) as average_value,
    MIN(data_h) as first_order,
    MAX(data_h) as last_order
FROM pedido;
"

echo ""
echo "📦 Stock levels after load test:"
psql -U postgres -d donut_shop -c "
SELECT 
    tipo_ingrediente,
    AVG(quantidade_disponivel) as avg_stock,
    MIN(quantidade_disponivel) as min_stock
FROM estoque_ingredientes
GROUP BY tipo_ingrediente
ORDER BY tipo_ingrediente;
"
