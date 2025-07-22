# container-scripts/test.sh - Test all database functionality
#!/bin/bash

echo "🧪 Testing Ephemeral Donut Shop Database..."
echo "============================================"

# Test basic connection
echo "1️⃣  Testing database connection..."
if psql -U postgres -d donut_shop -c "SELECT 'Connection successful!' as status;" > /dev/null 2>&1; then
    echo "✅ Database connection OK"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Test stored procedure
echo ""
echo "2️⃣  Testing stored procedure..."
psql -U postgres -d donut_shop -c "SELECT * FROM sp_relatorio_vendas('2025-06-01', '2025-07-31');"

# Test views
echo ""
echo "3️⃣  Testing views..."
echo "📊 Low stock items:"
psql -U postgres -d donut_shop -c "SELECT * FROM vw_estoque_baixo LIMIT 3;"

echo ""
echo "🍩 Detailed donuts:"
psql -U postgres -d donut_shop -c "SELECT id_donut, massa, cobertura, preco_total FROM vw_donut_detalhado LIMIT 3;"

# Test users
echo ""
echo "4️⃣  Testing user permissions..."
echo "👤 Admin user test:"
if psql -U admin_donut_db -d donut_shop -c "SELECT COUNT(*) as total_clientes FROM cliente;" > /dev/null 2>&1; then
    echo "✅ Admin user works"
    psql -U admin_donut_db -d donut_shop -c "SELECT COUNT(*) as total_clientes FROM cliente;"
else
    echo "❌ Admin user failed"
fi

echo ""
echo "👤 Read-only user test:"
if psql -U readonly_donut_db -d donut_shop -c "SELECT COUNT(*) as total_pedidos FROM pedido;" > /dev/null 2>&1; then
    echo "✅ Read-only user works"
    psql -U readonly_donut_db -d donut_shop -c "SELECT COUNT(*) as total_pedidos FROM pedido;"
else
    echo "❌ Read-only user failed"
fi

# Test trigger
echo ""
echo "5️⃣  Testing trigger (stock control)..."
echo "📦 Stock before order:"
psql -U postgres -d donut_shop -c "SELECT tipo_ingrediente, quantidade_disponivel FROM estoque_ingredientes WHERE tipo_ingrediente = 'massa' AND id_ingrediente = 1;"

echo ""
echo "🛒 Creating test order..."
psql -U postgres -d donut_shop -c "
INSERT INTO pedido (data_h, valor, status, cpf_cliente) 
VALUES (NOW(), 25.50, 'Pendente', '11111111111');

INSERT INTO pedido_donut (id_pedido, id_donut) 
VALUES (currval('pedido_pedido_num_seq'), 1);
"

echo ""
echo "📦 Stock after order (should be reduced):"
psql -U postgres -d donut_shop -c "SELECT tipo_ingrediente, quantidade_disponivel FROM estoque_ingredientes WHERE tipo_ingrediente = 'massa' AND id_ingrediente = 1;"

echo ""
echo "✅ All tests completed!"
echo "💡 Remember: All data is ephemeral and will be lost when containers stop!"
