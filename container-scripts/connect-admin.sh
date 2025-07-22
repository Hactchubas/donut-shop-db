# container-scripts/connect-admin.sh - Connect as admin user
#!/bin/bash
echo "🔗 Connecting as admin user (admin_donut_db)..."
echo "⚠️  Remember: All changes will be lost when containers stop!"
psql -U admin_donut_db -d donut_shop
