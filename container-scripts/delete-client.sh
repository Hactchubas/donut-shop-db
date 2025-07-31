#!/bin/bash
# container-scripts/delete-client.sh - Delete a client and all related data

echo "🗑️  Delete Client - Donut Shop Database"
echo "======================================"
echo "⚠️  WARNING: This will permanently delete the client and ALL related data!"
echo "   - Orders, payments, favorites, audit records"
echo ""

# Function to delete client
delete_client() {
    local client_cpf=$1
    
    echo "🔍 Checking if client exists..."
    
    # Check if client exists
    client_exists=$(psql -U postgres -d donut_shop -t -c "
    SELECT COUNT(*) FROM cliente WHERE cpf = '$client_cpf';
    " | xargs)
    
    if [ "$client_exists" -eq 0 ]; then
        echo "❌ Client with CPF $client_cpf does not exist!"
        return 1
    fi
    
    # Get client info before deletion
    echo "📋 Client information:"
    psql -U postgres -d donut_shop -c "
    SELECT cpf, nome, email FROM cliente WHERE cpf = '$client_cpf';
    "
    
    echo ""
    echo "📊 Related data to be deleted:"
    
    # Count related records
    orders_count=$(psql -U postgres -d donut_shop -t -c "
    SELECT COUNT(*) FROM pedido WHERE cpf_cliente = '$client_cpf';
    " | xargs)
    
    favorites_count=$(psql -U postgres -d donut_shop -t -c "
    SELECT COUNT(*) FROM favorito WHERE cpf_cliente = '$client_cpf';
    " | xargs)
    
    echo "   - Orders: $orders_count"
    echo "   - Favorites: $favorites_count"
    
    echo ""
    read -p "❓ Are you sure you want to delete this client? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deletion cancelled."
        return 1
    fi
    
    echo ""
    echo "🔄 Deleting client and related data..."
    
    # Execute deletion in correct order
    psql -U postgres -d donut_shop << EOF
      DO \$\$
      DECLARE
          client_cpf VARCHAR(11) := '$client_cpf';
      BEGIN
          -- 1. Delete audit records for client's orders
          DELETE FROM auditoria_pedido 
          WHERE pedido_num IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = client_cpf);
          
          -- 2. Delete payments for client's orders
          DELETE FROM pagamento 
          WHERE id_pedido IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = client_cpf);
          
          -- 3. Delete pedido_donut relationships for client's orders
          DELETE FROM pedido_donut 
          WHERE id_pedido IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = client_cpf);
          
          -- 4. Delete client's orders
          DELETE FROM pedido WHERE cpf_cliente = client_cpf;
          
          -- 5. Delete client's favorites
          DELETE FROM favorito WHERE cpf_cliente = client_cpf;
          
          -- 6. Finally, delete the client
          DELETE FROM cliente WHERE cpf = client_cpf;
          
          RAISE NOTICE 'Client % and all related data deleted successfully', client_cpf;
      END \$\$;
EOF
    
    if [ $? -eq 0 ]; then
        echo "✅ Client deleted successfully!"
        
        echo ""
        echo "📊 Updated database statistics:"
        psql -U postgres -d donut_shop -c "
        SELECT 
            'Remaining clients' as type, 
            COUNT(*)::text as count 
        FROM cliente
        UNION ALL
        SELECT 
            'Total orders' as type, 
            COUNT(*)::text as count 
        FROM pedido;
        "
    else
        echo "❌ Error occurred during deletion!"
        return 1
    fi
}

# Command line mode
if [ $# -eq 1 ]; then
    client_cpf=$1
    
    # Validate CPF format
    if [[ ! $client_cpf =~ ^[0-9]{11}$ ]]; then
        echo "❌ Invalid CPF format! Must be 11 digits."
        echo "Usage: $0 [CPF]"
        echo "Example: $0 11111111111"
        exit 1
    fi
    
    delete_client "$client_cpf"
    
else
    echo "❌ Usage: $0 [CPF]"
    echo "   Interactive mode: $0"
    echo "   Direct mode: $0 11111111111"
    exit 1
fi
