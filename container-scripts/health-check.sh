# container-scripts/health-check.sh - System health check
#!/bin/bash

echo "🏥 System Health Check"
echo "====================="

# Check database connectivity
echo "1️⃣  Database Connectivity:"
if psql -U postgres -d donut_shop -c "SELECT 'OK' as status;" > /dev/null 2>&1; then
    echo "✅ Database connection: OK"
else
    echo "❌ Database connection: FAILED"
    exit 1
fi

# Check all users can connect
echo ""
echo "2️⃣  User Access:"
if psql -U admin_donut_db -d donut_shop -c "SELECT 'OK';" > /dev/null 2>&1; then
    echo "✅ Admin user: OK"
else
    echo "❌ Admin user: FAILED"
fi

if psql -U readonly_donut_db -d donut_shop -c "SELECT 'OK';" > /dev/null 2>&1; then
    echo "✅ Readonly user: OK"
else
    echo "❌ Readonly user: FAILED"
fi

# Check stored procedure
echo ""
echo "3️⃣  Stored Procedure:"
if psql -U postgres -d donut_shop -c "SELECT * FROM sp_relatorio_vendas('2025-01-01', '2025-01-02');" > /dev/null 2>&1; then
    echo "✅ Stored procedure: OK"
else
    echo "❌ Stored procedure: FAILED"
fi

# Check triggers
echo ""
echo "4️⃣  Triggers:"
trigger_count=$(psql -U postgres -d donut_shop -t -c "
SELECT COUNT(*) FROM information_schema.triggers 
WHERE trigger_schema = 'public';
")

if [ "$trigger_count" -gt 0 ]; then
    echo "✅ Triggers: OK ($trigger_count found)"
else
    echo "❌ Triggers: FAILED (none found)"
fi

# Check views
echo ""
echo "5️⃣  Views:"
view_count=$(psql -U postgres -d donut_shop -t -c "
SELECT COUNT(*) FROM information_schema.views 
WHERE table_schema = 'public';
")

if [ "$view_count" -gt 0 ]; then
    echo "✅ Views: OK ($view_count found)"
else
    echo "❌ Views: FAILED (none found)"
fi

# Check sample data
echo ""
echo "6️⃣  Sample Data:"
customer_count=$(psql -U postgres -d donut_shop -t -c "SELECT COUNT(*) FROM cliente;" | xargs)
order_count=$(psql -U postgres -d donut_shop -t -c "SELECT COUNT(*) FROM pedido;" | xargs)

if [ "$customer_count" -gt 0 ] && [ "$order_count" -gt 0 ]; then
    echo "✅ Sample data: OK ($customer_count customers, $order_count orders)"
else
    echo "❌ Sample data: INCOMPLETE ($customer_count customers, $order_count orders)"
fi

echo ""
echo "🎯 Health check completed!"
