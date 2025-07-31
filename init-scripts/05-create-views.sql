
\c donut_shop;

-- Detailed donut view
CREATE OR REPLACE VIEW vw_donut_detalhado AS
SELECT 
    d.id_donut,
    d.preco,
    string_agg(DISTINCT t.tipo, ', ') AS toppings,
    string_agg(DISTINCT c.tipo, ', ') AS cobertura,
    string_agg(DISTINCT r.tipo, ', ') AS recheio,
    m.tipo AS massa,
    (COALESCE(SUM(DISTINCT t.preco), 0) + 
     COALESCE(SUM(DISTINCT c.preco), 0) + 
     COALESCE(SUM(DISTINCT r.preco), 0) + 
     m.preco + d.preco) AS preco_total
FROM donut d
JOIN massa m ON d.id_massa = m.id_massa
LEFT JOIN donut_topping dt ON d.id_donut = dt.id_donut
LEFT JOIN topping t ON dt.id_topping = t.id_topping
LEFT JOIN donut_cobertura dc ON d.id_donut = dc.id_donut
LEFT JOIN cobertura c ON dc.id_cobertura = c.id_cobertura
LEFT JOIN donut_recheio dr ON d.id_donut = dr.id_donut
LEFT JOIN recheio r ON dr.id_recheio = r.id_recheio
GROUP BY d.id_donut, d.preco, m.tipo, m.preco;

-- Pending orders time view
CREATE OR REPLACE VIEW vw_pedidos_tempo AS
SELECT 
    pedido_num,
    data_h,
    (NOW() - data_h) AS intervalo,
    CONCAT(
        EXTRACT(HOUR FROM (NOW() - data_h))::INTEGER, 'h ',
        EXTRACT(MINUTE FROM (NOW() - data_h))::INTEGER, 'min ',
        EXTRACT(SECOND FROM (NOW() - data_h))::INTEGER, 's'
    ) AS esperando
FROM pedido
WHERE status = 'Pendente'
  AND (NOW() - data_h) < INTERVAL '24 hours';

-- Low stock view
CREATE OR REPLACE VIEW vw_estoque_baixo AS
SELECT 
    ei.tipo_ingrediente,
    ei.id_ingrediente,
    CASE 
        WHEN ei.tipo_ingrediente = 'massa' THEN m.tipo
        WHEN ei.tipo_ingrediente = 'cobertura' THEN c.tipo  
        WHEN ei.tipo_ingrediente = 'recheio' THEN r.tipo
        WHEN ei.tipo_ingrediente = 'topping' THEN t.tipo
    END as nome_ingrediente,
    ei.quantidade_disponivel,
    ei.quantidade_minima,
    ei.data_ultima_atualizacao
FROM estoque_ingredientes ei
LEFT JOIN massa m ON ei.tipo_ingrediente = 'massa' AND ei.id_ingrediente = m.id_massa
LEFT JOIN cobertura c ON ei.tipo_ingrediente = 'cobertura' AND ei.id_ingrediente = c.id_cobertura
LEFT JOIN recheio r ON ei.tipo_ingrediente = 'recheio' AND ei.id_ingrediente = r.id_recheio  
LEFT JOIN topping t ON ei.tipo_ingrediente = 'topping' AND ei.id_ingrediente = t.id_topping
WHERE ei.quantidade_disponivel <= ei.quantidade_minima
ORDER BY ei.tipo_ingrediente, ei.quantidade_disponivel;
