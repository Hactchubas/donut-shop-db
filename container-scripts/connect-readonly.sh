# container-scripts/connect-readonly.sh - Connect as readonly user  
#!/bin/bash
echo "🔗 Connecting as readonly user (readonly_donut_db)..."
echo "⚠️  Remember: This user has read-only access!"
psql -U readonly_donut_db -d donut_shop
