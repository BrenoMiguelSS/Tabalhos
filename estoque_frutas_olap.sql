-- Criação das Tabelas

-- Tabela de fatos: Estoque de Frutas
CREATE TABLE estoque_frutas (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_fruta INT,
    id_localizacao INT,
    id_tempo INT,
    quantidade INT
);

-- Tabela de dimensão: Frutas
CREATE TABLE fruta (
    id_fruta INT AUTO_INCREMENT PRIMARY KEY,
    nome_fruta VARCHAR(50)
);

-- Tabela de dimensão: Tempo
CREATE TABLE tempo (
    id_tempo INT AUTO_INCREMENT PRIMARY KEY,
    ano INT,
    trimestre INT,
    mes INT
);

-- Tabela de dimensão: Localização
CREATE TABLE localizacao (
    id_localizacao INT AUTO_INCREMENT PRIMARY KEY,
    pais VARCHAR(50),
    estado VARCHAR(50),
    cidade VARCHAR(50)
);

-- Inserção de Dados

-- Inserir dados na tabela de frutas
INSERT INTO fruta (nome_fruta) VALUES
('Maçã'), ('Banana'), ('Laranja');

-- Inserir dados na tabela de tempo
INSERT INTO tempo (ano, trimestre, mes) VALUES
(2023, 1, 1), (2023, 1, 2), (2023, 1, 3),
(2023, 2, 4), (2023, 2, 5), (2023, 2, 6);

-- Inserir dados na tabela de localização
INSERT INTO localizacao (pais, estado, cidade) VALUES
('EUA', 'Califórnia', 'Los Angeles'),
('EUA', 'Califórnia', 'São Francisco'),
('EUA', 'Nova Iorque', 'Nova Iorque');

-- Inserir dados na tabela de estoque de frutas
INSERT INTO estoque_frutas (id_fruta, id_localizacao, id_tempo, quantidade) VALUES
(1, 1, 1, 100),
(1, 2, 2, 150),
(2, 3, 3, 200),
(1, 1, 4, 250),
(2, 2, 5, 300),
(1, 3, 6, 350),
(3, 1, 1, 120),
(3, 2, 2, 180),
(3, 3, 3, 240);

-- Consultas para Simular Operações OLAP

-- Agregação (Roll-Up)
SELECT t.ano, l.pais, f.nome_fruta, SUM(ef.quantidade) AS quantidade_total
FROM estoque_frutas ef
JOIN tempo t ON ef.id_tempo = t.id_tempo
JOIN localizacao l ON ef.id_localizacao = l.id_localizacao
JOIN fruta f ON ef.id_fruta = f.id_fruta
GROUP BY t.ano, l.pais, f.nome_fruta;

-- Detalhamento (Drill-Down)
SELECT t.ano, t.trimestre, t.mes, f.nome_fruta, SUM(ef.quantidade) AS quantidade_total
FROM estoque_frutas ef
JOIN tempo t ON ef.id_tempo = t.id_tempo
JOIN localizacao l ON ef.id_localizacao = l.id_localizacao
JOIN fruta f ON ef.id_fruta = f.id_fruta
WHERE t.ano = 2023 AND t.trimestre = 1
GROUP BY t.ano, t.trimestre, t.mes, f.nome_fruta;

-- Fatiar (Slice)
SELECT t.ano, t.trimestre, l.pais, l.estado, l.cidade, f.nome_fruta, SUM(ef.quantidade) AS quantidade_total
FROM estoque_frutas ef
JOIN tempo t ON ef.id_tempo = t.id_tempo
JOIN localizacao l ON ef.id_localizacao = l.id_localizacao
JOIN fruta f ON ef.id_fruta = f.id_fruta
WHERE t.ano = 2023 AND t.trimestre = 1
GROUP BY t.ano, t.trimestre, l.pais, l.estado, l.cidade, f.nome_fruta;

-- Cortar (Dice)
SELECT t.ano, t.trimestre, l.estado, l.cidade, f.nome_fruta, SUM(ef.quantidade) AS quantidade_total
FROM estoque_frutas ef
JOIN tempo t ON ef.id_tempo = t.id_tempo
JOIN localizacao l ON ef.id_localizacao = l.id_localizacao
JOIN fruta f ON ef.id_fruta = f.id_fruta
WHERE t.ano = 2023 AND (t.trimestre = 1 OR t.trimestre = 2) AND l.estado = 'Califórnia'
GROUP BY t.ano, t.trimestre, l.estado, l.cidade, f.nome_fruta;

-- Pivoteamento
SELECT
    f.nome_fruta,
    SUM(CASE WHEN t.trimestre = 1 THEN ef.quantidade ELSE 0 END) AS quantidade_Q1,
    SUM(CASE WHEN t.trimestre = 2 THEN ef.quantidade ELSE 0 END) AS quantidade_Q2,
    SUM(CASE WHEN t.trimestre = 3 THEN ef.quantidade ELSE 0 END) AS quantidade_Q3,
    SUM(CASE WHEN t.trimestre = 4 THEN ef.quantidade ELSE 0 END) AS quantidade_Q4
FROM estoque_frutas ef
JOIN tempo t ON ef.id_tempo = t.id_tempo
JOIN fruta f ON ef.id_fruta = f.id_fruta
GROUP BY f.nome_fruta;
