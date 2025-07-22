\c donut_shop;

-- Create tables
CREATE TABLE IF NOT EXISTS massa (
    id_massa SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    preco NUMERIC(6,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS cobertura (
    id_cobertura SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    preco NUMERIC(6,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS recheio (
    id_recheio SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    preco NUMERIC(6,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS topping (
    id_topping SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    preco NUMERIC(6,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS cliente (
    cpf VARCHAR(11) PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(100) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    rua VARCHAR(100),
    numero VARCHAR(10),
    bairro VARCHAR(50),
    cidade VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS donut (
    id_donut SERIAL PRIMARY KEY,
    preco NUMERIC(6,2) NOT NULL,
    id_massa INTEGER REFERENCES massa(id_massa)
);

CREATE TABLE IF NOT EXISTS donut_cobertura (
    id_donut INTEGER REFERENCES donut(id_donut),
    id_cobertura INTEGER REFERENCES cobertura(id_cobertura),
    PRIMARY KEY (id_donut, id_cobertura)
);

CREATE TABLE IF NOT EXISTS donut_recheio (
    id_donut INTEGER REFERENCES donut(id_donut),
    id_recheio INTEGER REFERENCES recheio(id_recheio),
    PRIMARY KEY (id_donut, id_recheio)
);

CREATE TABLE IF NOT EXISTS donut_topping (
    id_donut INTEGER REFERENCES donut(id_donut),
    id_topping INTEGER REFERENCES topping(id_topping),
    PRIMARY KEY (id_donut, id_topping)
);

CREATE TABLE IF NOT EXISTS pedido (
    pedido_num SERIAL PRIMARY KEY,
    data_h TIMESTAMP NOT NULL DEFAULT NOW(),
    valor NUMERIC(8,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pendente',
    cpf_cliente VARCHAR(11) REFERENCES cliente(cpf)
);

CREATE TABLE IF NOT EXISTS pedido_donut (
    id_pedido INTEGER REFERENCES pedido(pedido_num),
    id_donut INTEGER REFERENCES donut(id_donut),
    PRIMARY KEY (id_pedido, id_donut)
);

CREATE TABLE IF NOT EXISTS pagamento (
    id_pagamento SERIAL PRIMARY KEY,
    metodo VARCHAR(50) NOT NULL,
    id_pedido INTEGER REFERENCES pedido(pedido_num)
);

CREATE TABLE IF NOT EXISTS favorito (
    cpf_cliente VARCHAR(11) REFERENCES cliente(cpf),
    id_donut INTEGER REFERENCES donut(id_donut),
    PRIMARY KEY (cpf_cliente, id_donut)
);

CREATE TABLE IF NOT EXISTS auditoria_pedido (
    id_auditoria SERIAL PRIMARY KEY,
    pedido_num INTEGER NOT NULL,
    status_anterior VARCHAR(30),
    status_novo VARCHAR(30),
    data_alteracao TIMESTAMP DEFAULT NOW(),
    motivo VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS estoque_ingredientes (
    id_estoque SERIAL PRIMARY KEY,
    tipo_ingrediente VARCHAR(20) NOT NULL,
    id_ingrediente INTEGER NOT NULL,
    quantidade_disponivel INTEGER NOT NULL DEFAULT 100,
    quantidade_minima INTEGER NOT NULL DEFAULT 10,
    data_ultima_atualizacao TIMESTAMP DEFAULT NOW(),
    UNIQUE(tipo_ingrediente, id_ingrediente)
);
