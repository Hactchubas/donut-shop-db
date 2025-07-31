# container-scripts/init-aliases.sh - Simple alias initialization
#!/bin/bash

# This script sets up aliases inside the container
echo "🔧 Setting up Donut Shop aliases..."

# Create the aliases file
cat > /root/.bash_aliases << 'EOF'
# Donut Shop Database Aliases

# Main functionality
alias donut-test='bash /scripts/test.sh'
alias donut-status='bash /scripts/status.sh'
alias donut-schema='bash /scripts/show-schema.sh'

# Performance and health
alias donut-health='bash /scripts/health-check.sh'
alias donut-benchmark='bash /scripts/benchmark.sh'
alias donut-loadtest='bash /scripts/load-test.sh'

# Database connections
alias donut-admin='bash /scripts/connect-admin.sh'
alias donut-readonly='bash /scripts/connect-readonly.sh'
alias donut-psql='psql -U postgres -d donut_shop'

# Management
alias donut-delete-client='bash /scripts/delete-client.sh'
alias donut-backup='bash /scripts/backup-schema.sh'
alias donut-add-order='bash /scripts/add-order.sh'

# Quick queries
alias donut-customers='psql -U postgres -d donut_shop -c "SELECT COUNT(*) as total_customers FROM cliente;"'
alias donut-orders='psql -U postgres -d donut_shop -c "SELECT COUNT(*) as total_orders FROM pedido;"'
alias donut-sales='psql -U postgres -d donut_shop -c "SELECT * FROM sp_relatorio_vendas((CURRENT_DATE - INTERVAL '\''30 days'\'')::DATE, CURRENT_DATE);"'
alias donut-stock='psql -U postgres -d donut_shop -c "SELECT * FROM vw_estoque_baixo;"'

# Help
alias donut-help='echo "
🍩 Donut Shop Database Aliases:

📊 Main Commands:
  donut-test          - Run all functionality tests
  donut-status        - Database status
  donut-schema        - Show database schema

🔗 Connections:
  donut-admin         - Connect as admin user
  donut-readonly      - Connect as readonly user  
  donut-psql          - Connect as postgres user

🏥 Health & Performance:
  donut-health        - System health check
  donut-benchmark     - Performance tests
  donut-loadtest      - Stress testing

🛠️  Management:
  donut-delete-client - Delete client and related data
  donut-backup        - Export database schema

⚡ Quick Queries:
  donut-customers     - Count total customers
  donut-orders        - Count total orders
  donut-sales         - Sales report (last 30 days)
  donut-stock         - Show low stock items

💡 Usage: Just type the alias name (e.g., donut-test)
"'

EOF

