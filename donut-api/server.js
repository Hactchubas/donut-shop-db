const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = 3001;

// Database connection with retry logic
const pool = new Pool({
  user: 'admin_donut_db',
  host: 'postgres',
  database: 'donut_shop',
  password: 'admin_donut_2025!',
  port: 5432,
  max: 20,
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 30000,
});

app.use(cors());
app.use(express.json());

// Test database connection on startup
async function testConnection() {
  let retries = 10;
  while (retries > 0) {
    try {
      const client = await pool.connect();
      await client.query('SELECT 1');
      client.release();
      console.log('✅ Database connected successfully');
      return true;
    } catch (err) {
      console.log(`❌ Database connection failed, retries left: ${retries - 1}`);
      console.log(`Error: ${err.message}`);
      retries--;
      if (retries > 0) {
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
  }
  console.log('❌ Could not connect to database after 10 retries');
  return false;
}

// API routes
app.get('/api/test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ success: true, time: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/customers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM cliente ORDER BY nome');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/customers', async (req, res) => {
  try {
    const { cpf, email, telefone, nome, rua, numero, bairro, cidade } = req.body;
    const result = await pool.query(
      "INSERT INTO cliente (cpf, email, telefone, nome, rua, numero, bairro, cidade, senha) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *",
      [cpf, email, telefone, nome, rua, numero, bairro, cidade, nome.split(" ")[0]+"senha"]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/customers/:cpf', async (req, res) => {
  try {
    const { cpf } = req.params;
    const { email, telefone, nome, rua, numero, bairro, cidade } = req.body;
    
    // Check if customer exists
    const checkResult = await pool.query(
      'SELECT cpf FROM cliente WHERE cpf = $1',
      [cpf]
    );
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }
    
    // Update customer (CPF cannot be changed as it's the primary key)
    const result = await pool.query(
      'UPDATE cliente SET email = $2, telefone = $3, nome = $4, rua = $5, numero = $6, bairro = $7, cidade = $8 WHERE cpf = $1 RETURNING *',
      [cpf, email, telefone, nome, rua, numero, bairro, cidade]
    );
    
    res.json({ 
      message: 'Customer updated successfully',
      customer: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/customers/:cpf', async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { cpf } = req.params;
    
    // Start transaction
    await client.query('BEGIN');
    
    // Check if customer exists
    const customerCheck = await client.query(
      'SELECT cpf, nome, email FROM cliente WHERE cpf = $1',
      [cpf]
    );
    
    if (customerCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Customer not found' });
    }
    
    const customer = customerCheck.rows[0];
    
    // Get counts of related data for response
    const ordersCount = await client.query(
      'SELECT COUNT(*) as count FROM pedido WHERE cpf_cliente = $1',
      [cpf]
    );
    
    const favoritesCount = await client.query(
      'SELECT COUNT(*) as count FROM favorito WHERE cpf_cliente = $1',
      [cpf]
    );
    
    // Execute deletion in correct order (same as the script)
    
    // 1. Delete audit records for customer's orders
    await client.query(`
      DELETE FROM auditoria_pedido 
      WHERE pedido_num IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = $1)
    `, [cpf]);
    
    // 2. Delete payments for customer's orders
    await client.query(`
      DELETE FROM pagamento 
      WHERE id_pedido IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = $1)
    `, [cpf]);
    
    // 3. Delete pedido_donut relationships for customer's orders
    await client.query(`
      DELETE FROM pedido_donut 
      WHERE id_pedido IN (SELECT pedido_num FROM pedido WHERE cpf_cliente = $1)
    `, [cpf]);
    
    // 4. Delete customer's orders
    await client.query('DELETE FROM pedido WHERE cpf_cliente = $1', [cpf]);
    
    // 5. Delete customer's favorites
    await client.query('DELETE FROM favorito WHERE cpf_cliente = $1', [cpf]);
    
    // 6. Finally, delete the customer
    await client.query('DELETE FROM cliente WHERE cpf = $1', [cpf]);
    
    // Commit transaction
    await client.query('COMMIT');
    
    res.json({ 
      message: 'Customer and all related data deleted successfully',
      customer: customer,
      deletedData: {
        orders: parseInt(ordersCount.rows[0].count),
        favorites: parseInt(favoritesCount.rows[0].count)
      }
    });
    
  } catch (err) {
    // Rollback transaction on error
    await client.query('ROLLBACK');
    console.error('Customer deletion error:', err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.get('/api/orders', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT p.*, c.nome as cliente_nome, pa.metodo as metodo_pagamento
      FROM pedido p
      LEFT JOIN cliente c ON p.cpf_cliente = c.cpf
      LEFT JOIN pagamento pa ON p.pedido_num = pa.id_pedido
      ORDER BY p.data_h DESC
    `);
    
    // Convert valor to number
    const orders = result.rows.map(order => ({
      ...order,
      valor: parseFloat(order.valor) || 0
    }));
    
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const result = await pool.query(
      'UPDATE pedido SET status = $1 WHERE pedido_num = $2 RETURNING *',
      [status, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/orders/:id/donuts', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get donuts for this order with detailed information
    const result = await pool.query(`
      SELECT 
        vdd.id_donut,
        vdd.preco_total,
        vdd.massa,
        vdd.cobertura,
        vdd.recheio,
        vdd.toppings
      FROM pedido_donut pd
      JOIN vw_donut_detalhado vdd ON pd.id_donut = vdd.id_donut
      WHERE pd.id_pedido = $1
      ORDER BY vdd.id_donut
    `, [id]);
    
    // Convert price to number
    const donuts = result.rows.map(donut => ({
      ...donut,
      preco_total: parseFloat(donut.preco_total) || 0
    }));
    
    res.json(donuts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/donuts', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vw_donut_detalhado ORDER BY id_donut');
    
    // Convert price fields to numbers and explicitly map all fields
    const donuts = result.rows.map(donut => ({
      id_donut: donut.id_donut,
      preco: parseFloat(donut.preco) || 0,
      toppings: donut.toppings,
      cobertura: donut.cobertura,
      recheio: donut.recheio,
      massa: donut.massa,
      preco_total: parseFloat(donut.preco_total) || 0
    }));
    
    res.json(donuts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/donuts', async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { preco, id_massa, coberturas, recheios, toppings } = req.body;
    
    // Validate required fields
    if (!preco || !id_massa) {
      return res.status(400).json({ error: 'Price and massa are required' });
    }
    
    // Start transaction
    await client.query('BEGIN');
    
    // Create the base donut
    const donutResult = await client.query(
      'INSERT INTO donut (preco, id_massa) VALUES ($1, $2) RETURNING id_donut',
      [preco, id_massa]
    );
    
    const donutId = donutResult.rows[0].id_donut;
    
    // Add coberturas if provided
    if (coberturas && coberturas.length > 0) {
      for (const coberturaId of coberturas) {
        await client.query(
          'INSERT INTO donut_cobertura (id_donut, id_cobertura) VALUES ($1, $2)',
          [donutId, coberturaId]
        );
      }
    }
    
    // Add recheios if provided
    if (recheios && recheios.length > 0) {
      for (const recheioId of recheios) {
        await client.query(
          'INSERT INTO donut_recheio (id_donut, id_recheio) VALUES ($1, $2)',
          [donutId, recheioId]
        );
      }
    }
    
    // Add toppings if provided
    if (toppings && toppings.length > 0) {
      for (const toppingId of toppings) {
        await client.query(
          'INSERT INTO donut_topping (id_donut, id_topping) VALUES ($1, $2)',
          [donutId, toppingId]
        );
      }
    }
    
    // Commit transaction
    await client.query('COMMIT');
    
    // Get the complete donut with all details
    const newDonutResult = await client.query(
      'SELECT * FROM vw_donut_detalhado WHERE id_donut = $1',
      [donutId]
    );
    
    const newDonut = {
      ...newDonutResult.rows[0],
      preco: parseFloat(newDonutResult.rows[0].preco) || 0,
      preco_total: parseFloat(newDonutResult.rows[0].preco_total) || 0
    };
    
    res.json({
      message: 'Donut created successfully',
      donut: newDonut
    });
    
  } catch (err) {
    // Rollback transaction on error
    await client.query('ROLLBACK');
    console.error('Donut creation error:', err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

// Get available ingredients for donut creation
app.get('/api/ingredients', async (req, res) => {
  try {
    const [massas, coberturas, recheios, toppings] = await Promise.all([
      pool.query('SELECT * FROM massa ORDER BY tipo'),
      pool.query('SELECT * FROM cobertura ORDER BY tipo'),
      pool.query('SELECT * FROM recheio ORDER BY tipo'),
      pool.query('SELECT * FROM topping ORDER BY tipo')
    ]);
    
    // Convert prices to numbers
    const processIngredients = (ingredients) => 
      ingredients.rows.map(ingredient => ({
        ...ingredient,
        preco: parseFloat(ingredient.preco) || 0
      }));
    
    res.json({
      massas: processIngredients(massas),
      coberturas: processIngredients(coberturas),
      recheios: processIngredients(recheios),
      toppings: processIngredients(toppings)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/inventory', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        ei.*,
        CASE 
          WHEN ei.tipo_ingrediente = 'massa' THEN m.tipo
          WHEN ei.tipo_ingrediente = 'cobertura' THEN c.tipo
          WHEN ei.tipo_ingrediente = 'recheio' THEN r.tipo
          WHEN ei.tipo_ingrediente = 'topping' THEN t.tipo
        END as nome_ingrediente
      FROM estoque_ingredientes ei
      LEFT JOIN massa m ON ei.tipo_ingrediente = 'massa' AND ei.id_ingrediente = m.id_massa
      LEFT JOIN cobertura c ON ei.tipo_ingrediente = 'cobertura' AND ei.id_ingrediente = c.id_cobertura
      LEFT JOIN recheio r ON ei.tipo_ingrediente = 'recheio' AND ei.id_ingrediente = r.id_recheio
      LEFT JOIN topping t ON ei.tipo_ingrediente = 'topping' AND ei.id_ingrediente = t.id_topping
      ORDER BY ei.tipo_ingrediente, nome_ingrediente
    `);
    
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/inventory/low-stock', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vw_estoque_baixo');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/analytics/dashboard-supplementary', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let stats, recentOrders, statusDistribution;
    
    if (startDate && endDate) {
      // Date-filtered queries - only supplementary data not in stored procedure
      stats = await Promise.all([
        pool.query('SELECT COUNT(*) as total_customers FROM cliente'),
        pool.query("SELECT COUNT(*) as pending_orders FROM pedido WHERE status = 'Pendente' AND data_h::DATE BETWEEN $1 AND $2", [startDate, endDate]),
        pool.query('SELECT COUNT(*) as low_stock_items FROM vw_estoque_baixo')
      ]);

      recentOrders = await pool.query(`
        SELECT p.pedido_num, p.data_h, p.valor, p.status, c.nome as cliente_nome
        FROM pedido p
        LEFT JOIN cliente c ON p.cpf_cliente = c.cpf
        WHERE p.data_h::DATE BETWEEN $1 AND $2
        ORDER BY p.data_h DESC
        LIMIT 10
      `, [startDate, endDate]);

      statusDistribution = await pool.query(`
        SELECT status, COUNT(*) as count
        FROM pedido
        WHERE data_h::DATE BETWEEN $1 AND $2
        GROUP BY status
        ORDER BY count DESC
      `, [startDate, endDate]);
    } else {
      // All-time queries - use big date range for stored procedure compatibility
      const bigStartDate = '1900-01-01';
      const bigEndDate = '2099-12-31';
      
      stats = await Promise.all([
        pool.query('SELECT COUNT(*) as total_customers FROM cliente'),
        pool.query("SELECT COUNT(*) as pending_orders FROM pedido WHERE status = 'Pendente' AND data_h::DATE BETWEEN $1 AND $2", [bigStartDate, bigEndDate]),
        pool.query('SELECT COUNT(*) as low_stock_items FROM vw_estoque_baixo')
      ]);

      recentOrders = await pool.query(`
        SELECT p.pedido_num, p.data_h, p.valor, p.status, c.nome as cliente_nome
        FROM pedido p
        LEFT JOIN cliente c ON p.cpf_cliente = c.cpf
        WHERE p.data_h::DATE BETWEEN $1 AND $2
        ORDER BY p.data_h DESC
        LIMIT 10
      `, [bigStartDate, bigEndDate]);

      statusDistribution = await pool.query(`
        SELECT status, COUNT(*) as count
        FROM pedido
        WHERE data_h::DATE BETWEEN $1 AND $2
        GROUP BY status
        ORDER BY count DESC
      `, [bigStartDate, bigEndDate]);
    }

    // Convert numeric values properly
    const processedRecentOrders = recentOrders.rows.map(order => ({
      ...order,
      valor: parseFloat(order.valor) || 0
    }));

    res.json({
      totalCustomers: parseInt(stats[0].rows[0].total_customers),
      pendingOrders: parseInt(stats[1].rows[0].pending_orders),
      lowStockItems: parseInt(stats[2].rows[0].low_stock_items),
      recentOrders: processedRecentOrders,
      statusDistribution: statusDistribution.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/analytics/sales-report', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'startDate and endDate are required' });
    }
    
    const result = await pool.query(
      'SELECT * FROM sp_relatorio_vendas($1, $2)',
      [startDate, endDate]
    );
    
    // Convert numeric values properly
    const report = result.rows[0] ? {
      ...result.rows[0],
      valor_total: parseFloat(result.rows[0].valor_total) || 0,
      valor_medio: parseFloat(result.rows[0].valor_medio) || 0
    } : null;
    
    res.json(report);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/analytics/date-range', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        MIN(data_h::DATE) as start_date,
        MAX(data_h::DATE) as end_date
      FROM pedido
      WHERE data_h IS NOT NULL
    `);
    
    const dateRange = result.rows[0];
    res.json({
      startDate: dateRange.start_date,
      endDate: dateRange.end_date
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server after testing database connection
async function startServer() {
  console.log('🍩 Starting Donut Shop API Server...');
  
  const dbConnected = await testConnection();
  if (!dbConnected) {
    console.log('⚠️  Starting server anyway, database may not be ready yet');
  }
  
  app.listen(port, '0.0.0.0', () => {
    console.log(`✅ Donut Shop API running at http://0.0.0.0:${port}`);
  });
}

startServer().catch(err => {
  console.error('❌ Failed to start server:', err);
  process.exit(1);
});
