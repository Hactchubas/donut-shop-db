# container-scripts/backup-schema.sh - Export schema only
#!/bin/bash

echo "💾 Exporting Database Schema (Structure Only)"
echo "============================================="

echo "📄 Generating schema dump..."

# Export schema without data
pg_dump -U postgres -d donut_shop --schema-only --no-owner --no-privileges > /tmp/donut_schema.sql

if [ $? -eq 0 ]; then
    echo "✅ Schema exported successfully!"
    echo "📊 Schema file stats:"
    wc -l /tmp/donut_schema.sql
    echo ""
    echo "📋 Schema preview (first 20 lines):"
    head -20 /tmp/donut_schema.sql
    echo ""
    echo "💡 Full schema saved to /tmp/donut_schema.sql"
    echo "💡 To view: docker exec donut_shop_db cat /tmp/donut_schema.sql"
else
    echo "❌ Schema export failed!"
fi
