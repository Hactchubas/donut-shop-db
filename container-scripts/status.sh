# container-scripts/status.sh - Show database status
#!/bin/bash

echo "📊 Ephemeral Donut Shop Database Status"
echo "======================================"

echo "💾 Memory Usage (tmpfs - ephemeral storage):"
df -h /var/lib/postgresql/data 2>/dev/null || echo "Database not accessible"

echo ""
echo "📈 Database Quick Stats:"
if psql -U postgres -d donut_shop -c "SELECT 1;" > /dev/null 2>&1; then
    psql -U postgres -d donut_shop -c "
    SELECT 
        'Tables' as type, COUNT(*) as count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    UNION ALL
    SELECT 
        'Views' as type, COUNT(*) as count 
    FROM information_schema.views 
    WHERE table_schema = 'public'
    UNION ALL
    SELECT 
        'Functions' as type, COUNT(*) as count 
    FROM information_schema.routines 
    WHERE routine_schema = 'public';
    "
    
    echo ""
    echo "🛍️  Sample Data Counts:"
    psql -U postgres -d donut_shop -c "
    SELECT 'Customers' as table_name, COUNT(*) as records FROM cliente
    UNION ALL
    SELECT 'Donuts' as table_name, COUNT(*) as records FROM donut
    UNION ALL
    SELECT 'Orders' as table_name, COUNT(*) as records FROM pedido
    UNION ALL
    SELECT 'Payments' as table_name, COUNT(*) as records FROM pagamento;
    "
else
    echo "❌ Database not accessible"
fi

echo ""
echo "⚠️  REMINDER: All data is ephemeral and will be lost when containers stop!"
