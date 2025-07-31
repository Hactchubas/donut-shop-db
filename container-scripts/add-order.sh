#!/bin/bash
# container-scripts/add-order.sh - Add a new order to the donut shop

echo "🛒 Add New Order - Donut Shop Database"
echo "====================================="
echo ""

# Function to show available customers
show_customers() {
    echo "👥 Available customers:"
    psql -U postgres -d donut_shop -c "
    SELECT cpf, nome, email 
    FROM cliente 
    ORDER BY nome;
    "
}

# Function to show available donuts
show_donuts() {
    echo "🍩 Available donuts:"
    psql -U postgres -d donut_shop -c "
    SELECT 
        d.id_donut,
        m.tipo as massa,
        string_agg(DISTINCT c.tipo, ', ') as coberturas,
        string_agg(DISTINCT r.tipo, ', ') as recheios,
        string_agg(DISTINCT t.tipo, ', ') as toppings,
        ROUND(d.preco + 
              COALESCE((SELECT SUM(c2.preco) FROM donut_cobertura dc2 
                       JOIN cobertura c2 ON dc2.id_cobertura = c2.id_cobertura 
                       WHERE dc2.id_donut = d.id_donut), 0) +
              COALESCE((SELECT SUM(r2.preco) FROM donut_recheio dr2 
                       JOIN recheio r2 ON dr2.id_recheio = r2.id_recheio 
                       WHERE dr2.id_donut = d.id_donut), 0) +
              COALESCE((SELECT SUM(t2.preco) FROM donut_topping dt2 
                       JOIN topping t2 ON dt2.id_topping = t2.id_topping 
                       WHERE dt2.id_donut = d.id_donut), 0), 2) as preco_total
    FROM donut d
    JOIN massa m ON d.id_massa = m.id_massa
    LEFT JOIN donut_cobertura dc ON d.id_donut = dc.id_donut
    LEFT JOIN cobertura c ON dc.id_cobertura = c.id_cobertura
    LEFT JOIN donut_recheio dr ON d.id_donut = dr.id_donut
    LEFT JOIN recheio r ON dr.id_recheio = r.id_recheio
    LEFT JOIN donut_topping dt ON d.id_donut = dt.id_donut
    LEFT JOIN topping t ON dt.id_topping = t.id_topping
    GROUP BY d.id_donut, m.tipo, d.preco
    ORDER BY d.id_donut;
    "
}

# Function to add order
add_order() {
    local customer_cpf=$1
    local donut_ids=$2
    local total_value=$3
    
    echo "📝 Creating order..."
    
    # Create the order - FIX: Use -A -t flags to get clean output
    order_id=$(psql -U postgres -d donut_shop -A -t -c "
    INSERT INTO pedido (data_h, valor, status, cpf_cliente) 
    VALUES (NOW(), $total_value, 'Pendente', '$customer_cpf')
    RETURNING pedido_num;
    ")
    
    # Clean the order_id (remove any extra whitespace)
    order_id=$(echo "$order_id" | xargs)
    
    if [ -z "$order_id" ] || [[ ! "$order_id" =~ ^[0-9]+$ ]]; then
        echo "❌ Failed to create order! Got: '$order_id'"
        return 1
    fi
    
    echo "✅ Order created with ID: $order_id"
    
    # Add donuts to order
    echo "🍩 Adding donuts to order..."
    IFS=',' read -ra DONUT_ARRAY <<< "$donut_ids"
    for donut_id in "${DONUT_ARRAY[@]}"; do
        donut_id=$(echo $donut_id | xargs) # trim whitespace
        
        # Validate donut_id is numeric
        if [[ ! "$donut_id" =~ ^[0-9]+$ ]]; then
            echo "  ❌ Invalid donut ID: $donut_id"
            continue
        fi
        
        psql -U postgres -d donut_shop -c "
        INSERT INTO pedido_donut (id_pedido, id_donut) 
        VALUES ($order_id, $donut_id);
        " > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "  ✅ Added donut $donut_id"
        else
            echo "  ❌ Failed to add donut $donut_id"
        fi
    done
    
    # Show order summary
    echo ""
    echo "📋 Order Summary:"
    psql -U postgres -d donut_shop -c "
    SELECT 
        p.pedido_num as \"Order ID\",
        c.nome as \"Customer\",
        p.data_h as \"Date/Time\",
        p.valor as \"Total Value\",
        p.status as \"Status\"
    FROM pedido p
    JOIN cliente c ON p.cpf_cliente = c.cpf
    WHERE p.pedido_num = $order_id;
    "
    
    echo ""
    echo "🍩 Donuts in order:"
    psql -U postgres -d donut_shop -c "
    SELECT 
        d.id_donut as \"Donut ID\",
        m.tipo as \"Massa\"
    FROM pedido_donut pd
    JOIN donut d ON pd.id_donut = d.id_donut
    JOIN massa m ON d.id_massa = m.id_massa
    WHERE pd.id_pedido = $order_id;
    "
    
    echo ""
    echo "📦 Stock levels updated automatically by trigger!"
    
    return 0
}

# Function to calculate total - SIMPLIFIED VERSION
calculate_total() {
    local donut_ids=$1
    local total=0
    
    IFS=',' read -ra DONUT_ARRAY <<< "$donut_ids"
    for donut_id in "${DONUT_ARRAY[@]}"; do
        donut_id=$(echo $donut_id | xargs)
        echo "$donut_id"
        # Skip invalid IDs
        if [[ ! "$donut_id" =~ ^[0-9]+$ ]]; then
            continue
        fi
        
        # Simple approach: just get the base donut price for now
        price=$(psql -U postgres -d donut_shop -A -t -c "
        SELECT preco_total FROM vw_donut_detalhado WHERE id_donut = $donut_id;
        " 2>/dev/null | xargs)
        
        if [ ! -z "$price" ] && [[ "$price" =~ ^[0-9.]+$ ]]; then
            total=$(echo "scale=2; $total + $price" | bc 2>/dev/null || echo "$total")
        fi
    done
    
    echo $total
}

# Main execution
if [ $# -eq 0 ]; then
    # Interactive mode
    echo "🎯 Interactive Order Creation"
    echo ""
    
    # Step 1: Show and select customer
    show_customers
    echo ""
    read -p "Enter customer CPF (11 digits): " customer_cpf
    
    # Validate CPF
    if [[ ! $customer_cpf =~ ^[0-9]{11}$ ]]; then
        echo "❌ Invalid CPF format! Must be 11 digits."
        exit 1
    fi
    
    # Check if customer exists
    customer_exists=$(psql -U postgres -d donut_shop -A -t -c "
    SELECT COUNT(*) FROM cliente WHERE cpf = '$customer_cpf';
    " | xargs)
    
    if [ "$customer_exists" -eq 0 ]; then
        echo "❌ Customer with CPF $customer_cpf does not exist!"
        exit 1
    fi
    
    # Step 2: Show and select donuts
    echo ""
    show_donuts
    echo ""
    echo "💡 Enter donut IDs separated by commas (e.g., 1,3,5)"
    read -p "Donut IDs: " donut_ids
    
    # Validate donut IDs
    if [[ ! $donut_ids =~ ^[0-9,[:space:]]+$ ]]; then
        echo "❌ Invalid donut IDs format! Use numbers separated by commas."
        exit 1
    fi
    
    # Step 3: Calculate total
    echo ""
    echo "💰 Calculating total..."
    total_value=$(calculate_total "$donut_ids")
    
    if [ "$total_value" = "0" ] || [ -z "$total_value" ]; then
        echo "❌ Could not calculate total. Please check donut IDs."
        exit 1
    fi
    
    echo "Total value: R$ $total_value"
    
    # Step 4: Confirm and create order
    echo ""
    read -p "❓ Create this order? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        add_order "$customer_cpf" "$donut_ids" "$total_value"
    else
        echo "❌ Order cancelled."
        exit 1
    fi
    
elif [ $# -eq 3 ]; then
    # Command line mode
    customer_cpf=$1
    donut_ids=$2
    total_value=$3
    
    # Validate inputs
    if [[ ! $customer_cpf =~ ^[0-9]{11}$ ]]; then
        echo "❌ Invalid CPF format!"
        echo "Usage: $0 [CPF] [donut_ids] [total_value]"
        echo "Example: $0 11111111111 \"1,2,3\" 25.50"
        exit 1
    fi
    
    add_order "$customer_cpf" "$donut_ids" "$total_value"
    
else
    echo "❌ Usage:"
    echo "   Interactive mode: $0"
    echo "   Direct mode: $0 [CPF] [donut_ids] [total_value]"
    echo "   Example: $0 11111111111 \"1,2,3\" 25.50"
    exit 1
fi

echo ""
echo "🎉 Order process completed!"
echo "💡 Use 'donut-status' to see updated database statistics"
