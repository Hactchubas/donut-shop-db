\c donut_shop;

-- Stored Procedure for Sales Reports
CREATE OR REPLACE FUNCTION sp_relatorio_vendas(
    p_data_inicio DATE,
    p_data_fim DATE
)
RETURNS TABLE (
    total_pedidos INTEGER,
    valor_total NUMERIC(10,2),
    valor_medio NUMERIC(10,2),
    donut_mais_vendido VARCHAR(50),
    cliente_mais_ativo VARCHAR(100),
    metodo_pagamento_preferido VARCHAR(50)
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH estatisticas_base AS (
        SELECT 
            COUNT(p.pedido_num) as total_pedidos,
            COALESCE(SUM(p.valor), 0) as valor_total,
            COALESCE(AVG(p.valor), 0) as valor_medio
        FROM pedido p
        WHERE p.data_h::DATE BETWEEN p_data_inicio AND p_data_fim
          AND p.status != 'Cancelado'
    ),
    donut_popular AS (
        SELECT d.id_donut, COUNT(*) as quantidade
        FROM pedido p
        JOIN pedido_donut pd ON p.pedido_num = pd.id_pedido
        JOIN donut d ON pd.id_donut = d.id_donut
        WHERE p.data_h::DATE BETWEEN p_data_inicio AND p_data_fim
          AND p.status != 'Cancelado'
        GROUP BY d.id_donut
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ),
    cliente_ativo AS (
        SELECT c.nome, COUNT(p.pedido_num) as total_pedidos
        FROM cliente c
        JOIN pedido p ON c.cpf = p.cpf_cliente
        WHERE p.data_h::DATE BETWEEN p_data_inicio AND p_data_fim
          AND p.status != 'Cancelado'
        GROUP BY c.cpf, c.nome
        ORDER BY COUNT(p.pedido_num) DESC
        LIMIT 1
    ),
    pagamento_preferido AS (
        SELECT pg.metodo, COUNT(*) as quantidade
        FROM pedido p
        JOIN pagamento pg ON p.pedido_num = pg.id_pedido
        WHERE p.data_h::DATE BETWEEN p_data_inicio AND p_data_fim
          AND p.status != 'Cancelado'
        GROUP BY pg.metodo
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    SELECT 
        eb.total_pedidos::INTEGER,
        eb.valor_total::NUMERIC(10,2),
        eb.valor_medio::NUMERIC(10,2),
        COALESCE('Donut ID: ' || dp.id_donut::VARCHAR, 'Nenhum')::VARCHAR(50) as donut_mais_vendido,
        COALESCE(ca.nome, 'Nenhum')::VARCHAR(100) as cliente_mais_ativo,
        COALESCE(pp.metodo, 'Nenhum')::VARCHAR(50) as metodo_pagamento_preferido
    FROM estatisticas_base eb
    LEFT JOIN donut_popular dp ON true
    LEFT JOIN cliente_ativo ca ON true  
    LEFT JOIN pagamento_preferido pp ON true;
END;
$$;

-- Audit trigger function
CREATE OR REPLACE FUNCTION trigger_auditoria_status_pedido()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status <> 'Em Preparo' THEN
        INSERT INTO auditoria_pedido (pedido_num, status_anterior, status_novo, motivo)
        VALUES (NEW.pedido_num, OLD.status, NEW.status, 'Alteração manual de status');
    END IF;
    RETURN NEW;
END;
$$;

-- Payment status trigger function
CREATE OR REPLACE FUNCTION trigger_atualizar_status_pedido()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_anterior VARCHAR(30);
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT status INTO v_status_anterior 
        FROM pedido 
        WHERE pedido_num = NEW.id_pedido;
        
        IF v_status_anterior = 'Pendente' THEN
            UPDATE pedido 
            SET status = 'Em Preparo' 
            WHERE pedido_num = NEW.id_pedido;
            
            INSERT INTO auditoria_pedido (pedido_num, status_anterior, status_novo, motivo)
            VALUES (NEW.id_pedido, v_status_anterior, 'Em Preparo', 'Pagamento confirmado');
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION trigger_controle_estoque()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Reduce stock for the massa (only 1 massa per donut)
        UPDATE estoque_ingredientes 
        SET quantidade_disponivel = quantidade_disponivel - 1,
            data_ultima_atualizacao = NOW()
        WHERE tipo_ingrediente = 'massa' 
          AND id_ingrediente = (SELECT id_massa FROM donut WHERE id_donut = NEW.id_donut);
        
        -- Reduce stock for coberturas (can have multiple)
        UPDATE estoque_ingredientes 
        SET quantidade_disponivel = quantidade_disponivel - 1,
            data_ultima_atualizacao = NOW()
        WHERE tipo_ingrediente = 'cobertura' 
          AND id_ingrediente IN (
              SELECT id_cobertura FROM donut_cobertura WHERE id_donut = NEW.id_donut
          );
        
        -- Reduce stock for recheios (can have multiple)
        UPDATE estoque_ingredientes 
        SET quantidade_disponivel = quantidade_disponivel - 1,
            data_ultima_atualizacao = NOW()
        WHERE tipo_ingrediente = 'recheio' 
          AND id_ingrediente IN (
              SELECT id_recheio FROM donut_recheio WHERE id_donut = NEW.id_donut
          );
        
        -- Reduce stock for toppings (can have multiple)
        UPDATE estoque_ingredientes 
        SET quantidade_disponivel = quantidade_disponivel - 1,
            data_ultima_atualizacao = NOW()
        WHERE tipo_ingrediente = 'topping' 
          AND id_ingrediente IN (
              SELECT id_topping FROM donut_topping WHERE id_donut = NEW.id_donut
          );
        
        -- Check for low stock
        PERFORM 1 FROM estoque_ingredientes 
        WHERE quantidade_disponivel <= quantidade_minima;
        
        IF FOUND THEN
            RAISE NOTICE 'ATENÇÃO: Alguns ingredientes estão com estoque baixo!';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create triggers
CREATE TRIGGER trigger_auditoria_status_pedido 
    AFTER UPDATE ON pedido 
    FOR EACH ROW 
    EXECUTE FUNCTION trigger_auditoria_status_pedido();

CREATE TRIGGER trigger_pagamento_status 
    AFTER INSERT ON pagamento 
    FOR EACH ROW 
    EXECUTE FUNCTION trigger_atualizar_status_pedido();

CREATE TRIGGER trigger_estoque_pedido
    AFTER INSERT ON pedido_donut
    FOR EACH ROW
    EXECUTE FUNCTION trigger_controle_estoque();

---
