
\c donut_shop;

-- Insert sample data
INSERT INTO massa (tipo, preco) VALUES
('Tradicional', 1.00),
('Chocolate', 1.20),
('Integral', 1.30),
('Baunilha', 1.10),
('Levinha', 1.15),
('Vegana', 1.40),
('Fermento Natural', 1.50),
('Caramelo', 1.25),
('Sem glúten', 1.60),
('Red Velvet', 1.55);

INSERT INTO cobertura (tipo, preco) VALUES
('Chocolate', 1.50),
('Açúcar', 1.00),
('Morango', 1.80),
('Baunilha', 1.70),
('Doce de Leite', 1.90),
('Nutella', 2.00),
('Granulado', 1.60),
('Glacê', 1.50),
('Coco ralado', 1.40),
('Mel', 1.75);

INSERT INTO recheio (tipo, preco) VALUES
('Chocolate', 2.50),
('Morango', 2.80),
('Doce de Leite', 2.60),
('Creme', 2.40),
('Nutella', 3.00),
('Leite Condensado', 2.70),
('Abacaxi', 2.90),
('Banana', 2.30),
('Coco', 2.55),
('Uva', 2.45);

INSERT INTO topping (tipo, preco) VALUES
('Granulado', 0.50),
('Castanha', 0.70),
('Ovomaltine', 0.80),
('Choco Chips', 0.60),
('Mini M&Ms', 0.90),
('Coco ralado', 0.55),
('Amêndoas', 0.85),
('Nozes', 0.95),
('Gotas de chocolate', 0.75),
('Paçoca', 0.65);

INSERT INTO cliente (cpf, email, telefone, senha, nome, rua, numero, bairro, cidade) VALUES
('11111111111', 'ana@email.com', '11999990001', 'senha123', 'Ana Souza', 'Rua das Flores', '123', 'Centro', 'São Paulo'),
('22222222222', 'bruno@email.com', '21988880002', '12345678', 'Bruno Lima', 'Av. Brasil', '456', 'Copacabana', 'Rio de Janeiro'),
('33333333333', 'carla@email.com', '31977770003', 'minhasenha', 'Carla Mendes', 'Rua A', '789', 'Savassi', 'Belo Horizonte'),
('44444444444', 'daniel@email.com', '41966660004', 'abc12345', 'Daniel Rocha', 'Rua B', '101', 'Batel', 'Curitiba'),
('55555555555', 'eduardo@email.com', '51955550005', 'qwertyui', 'Eduardo Silva', 'Rua C', '202', 'Moinhos', 'Porto Alegre'),
('66666666666', 'fernanda@email.com', '61944440006', 'senha456', 'Fernanda Castro', 'Rua D', '303', 'Asa Sul', 'Brasília'),
('77777777777', 'gabriel@email.com', '71933330007', 'segura123', 'Gabriel Costa', 'Rua E', '404', 'Barra', 'Salvador'),
('88888888888', 'helena@email.com', '81922220008', '1234abcd', 'Helena Martins', 'Rua F', '505', 'Boa Viagem', 'Recife'),
('99999999999', 'igor@email.com', '91911110009', 'senha321', 'Igor Fernandes', 'Rua G', '606', 'Centro', 'Belém'),
('10101010101', 'juliana@email.com', '11900000010', 'senha789', 'Juliana Dias', 'Rua H', '707', 'Pinheiros', 'São Paulo');

INSERT INTO donut (preco, id_massa) VALUES
(5.00, 1), (5.20, 2), (5.10, 3), (5.30, 4), (5.40, 5),
(5.50, 6), (5.25, 7), (5.60, 8), (5.70, 9), (6.00, 10);

INSERT INTO donut_cobertura (id_donut, id_cobertura) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(1, 2), (1, 3), (2, 4), (3, 8), (2, 6), (7, 1);

INSERT INTO donut_recheio (id_donut, id_recheio) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO donut_topping (id_donut, id_topping) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10), (1, 2);

INSERT INTO pedido (data_h, valor, status, cpf_cliente) VALUES
('2025-06-26 14:35:18', 10.00, 'Pendente', '11111111111'),
('2025-06-26 14:35:18', 12.00, 'Entregue', '22222222222'),
('2025-06-26 14:35:18', 11.00, 'Cancelado', '33333333333'),
('2025-06-26 14:35:18', 13.50, 'Entregue', '44444444444'),
('2025-06-26 14:35:18', 14.00, 'Entregue', '55555555555'),
('2025-06-26 14:35:18', 15.00, 'Entregue', '66666666666'),
('2025-06-26 14:35:18', 16.50, 'Pendente', '77777777777'),
('2025-06-26 14:35:18', 17.00, 'Entregue', '88888888888'),
('2025-06-26 14:35:18', 18.25, 'Pendente', '99999999999'),
('2025-06-26 14:35:18', 19.00, 'Entregue', '10101010101');

INSERT INTO pedido_donut (id_pedido, id_donut) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10), (2, 3);

INSERT INTO pagamento (metodo, id_pedido) VALUES
('Cartão', 1), ('Pix', 2), ('Dinheiro', 3), ('Cartão', 4), ('Pix', 5),
('Cartão', 6), ('Dinheiro', 7), ('Pix', 8), ('Cartão', 9), ('Dinheiro', 10);

INSERT INTO favorito (cpf_cliente, id_donut) VALUES
('11111111111', 1), ('22222222222', 2), ('33333333333', 3),
('44444444444', 4), ('55555555555', 5), ('66666666666', 6),
('77777777777', 7), ('88888888888', 8), ('99999999999', 9),
('10101010101', 10), ('11111111111', 2), ('22222222222', 3);

-- Initialize stock
INSERT INTO estoque_ingredientes (tipo_ingrediente, id_ingrediente, quantidade_disponivel, quantidade_minima)
SELECT 'massa', id_massa, 50, 5 FROM massa
UNION ALL
SELECT 'cobertura', id_cobertura, 30, 3 FROM cobertura
UNION ALL  
SELECT 'recheio', id_recheio, 25, 2 FROM recheio
UNION ALL
SELECT 'topping', id_topping, 40, 4 FROM topping;
