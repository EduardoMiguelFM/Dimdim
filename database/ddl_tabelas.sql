-- =====================================================
-- DDL - DimDim API Database
-- Projeto: Sistema de Gestão Financeira DimDim
-- Disciplina: Cloud Computing - FIAP
-- =====================================================

-- Criar database
-- CREATE DATABASE dimdim_db;
-- GO

-- Usar database
-- USE dimdim_db;
-- GO

-- =====================================================
-- TABELA: usuarios (Tabela Master)
-- =====================================================
CREATE TABLE usuarios (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL UNIQUE,
    cpf NVARCHAR(14) NOT NULL UNIQUE,
    telefone NVARCHAR(20),
    endereco NVARCHAR(255),
    saldo DECIMAL(10,2) DEFAULT 0.00,
    ativo BIT DEFAULT 1,
    data_criacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA: transacoes (Tabela Detail)
-- =====================================================
CREATE TABLE transacoes (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    tipo NVARCHAR(50) NOT NULL CHECK (tipo IN (
        'DEPOSITO', 
        'SAQUE', 
        'TRANSFERENCIA_ENVIADA', 
        'TRANSFERENCIA_RECEBIDA', 
        'PAGAMENTO', 
        'RECEBIMENTO'
    )),
    descricao NVARCHAR(255),
    usuario_id BIGINT NOT NULL,
    data_transacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_criacao DATETIME2 NOT NULL DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE(),
    
    -- Chave estrangeira
    CONSTRAINT FK_transacoes_usuario 
        FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id) 
        ON DELETE CASCADE
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela usuarios
CREATE INDEX IX_usuarios_email ON usuarios(email);
CREATE INDEX IX_usuarios_cpf ON usuarios(cpf);
CREATE INDEX IX_usuarios_ativo ON usuarios(ativo);
CREATE INDEX IX_usuarios_nome ON usuarios(nome);

-- Índices para tabela transacoes
CREATE INDEX IX_transacoes_usuario_id ON transacoes(usuario_id);
CREATE INDEX IX_transacoes_tipo ON transacoes(tipo);
CREATE INDEX IX_transacoes_data_transacao ON transacoes(data_transacao);
CREATE INDEX IX_transacoes_valor ON transacoes(valor);

-- =====================================================
-- TRIGGERS PARA AUDITORIA
-- =====================================================

-- Trigger para atualizar data_atualizacao na tabela usuarios
CREATE TRIGGER TR_usuarios_update
ON usuarios
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE usuarios 
    SET data_atualizacao = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

-- Trigger para atualizar data_atualizacao na tabela transacoes
CREATE TRIGGER TR_transacoes_update
ON transacoes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE transacoes 
    SET data_atualizacao = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

-- =====================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir usuários de exemplo
INSERT INTO usuarios (nome, email, cpf, telefone, endereco, saldo, ativo) VALUES
('João Silva', 'joao.silva@email.com', '12345678901', '(11) 99999-9999', 'Rua das Flores, 123 - São Paulo/SP', 1000.00, 1),
('Maria Santos', 'maria.santos@email.com', '98765432109', '(11) 88888-8888', 'Av. Paulista, 456 - São Paulo/SP', 2500.50, 1),
('Pedro Oliveira', 'pedro.oliveira@email.com', '11122233344', '(11) 77777-7777', 'Rua Augusta, 789 - São Paulo/SP', 500.75, 1);

-- Inserir transações de exemplo
INSERT INTO transacoes (valor, tipo, descricao, usuario_id) VALUES
(500.00, 'DEPOSITO', 'Depósito inicial', 1),
(100.00, 'SAQUE', 'Saque para emergência', 1),
(250.00, 'TRANSFERENCIA_ENVIADA', 'Transferência para Maria', 1),
(250.00, 'TRANSFERENCIA_RECEBIDA', 'Transferência de João', 2),
(1000.00, 'DEPOSITO', 'Salário', 2),
(75.50, 'PAGAMENTO', 'Pagamento de conta de luz', 3);

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para relatório de usuários com saldo
CREATE VIEW vw_usuarios_saldo AS
SELECT 
    u.id,
    u.nome,
    u.email,
    u.cpf,
    u.saldo,
    u.ativo,
    COUNT(t.id) as total_transacoes,
    MAX(t.data_transacao) as ultima_transacao
FROM usuarios u
LEFT JOIN transacoes t ON u.id = t.usuario_id
GROUP BY u.id, u.nome, u.email, u.cpf, u.saldo, u.ativo;

-- View para relatório de transações detalhadas
CREATE VIEW vw_transacoes_detalhadas AS
SELECT 
    t.id,
    t.valor,
    t.tipo,
    t.descricao,
    t.data_transacao,
    u.nome as nome_usuario,
    u.email as email_usuario
FROM transacoes t
INNER JOIN usuarios u ON t.usuario_id = u.id;

-- =====================================================
-- STORED PROCEDURES ÚTEIS
-- =====================================================

-- Procedure para atualizar saldo do usuário
CREATE PROCEDURE sp_atualizar_saldo_usuario
    @usuario_id BIGINT,
    @valor DECIMAL(10,2),
    @tipo NVARCHAR(50)
AS
BEGIN
    DECLARE @saldo_atual DECIMAL(10,2);
    DECLARE @novo_saldo DECIMAL(10,2);
    
    SELECT @saldo_atual = saldo FROM usuarios WHERE id = @usuario_id;
    
    IF @tipo IN ('DEPOSITO', 'TRANSFERENCIA_RECEBIDA', 'RECEBIMENTO')
        SET @novo_saldo = @saldo_atual + @valor;
    ELSE IF @tipo IN ('SAQUE', 'TRANSFERENCIA_ENVIADA', 'PAGAMENTO')
        SET @novo_saldo = @saldo_atual - @valor;
    
    UPDATE usuarios 
    SET saldo = @novo_saldo, data_atualizacao = GETDATE()
    WHERE id = @usuario_id;
END;
GO

-- =====================================================
-- COMENTÁRIOS SOBRE A ESTRUTURA
-- =====================================================

/*
ESTRUTURA DO BANCO DE DADOS DIMDIM:

1. TABELA USUARIOS (MASTER):
   - id: Chave primária auto-incremento
   - nome: Nome completo do usuário
   - email: Email único para login
   - cpf: CPF único para identificação
   - telefone: Telefone de contato
   - endereco: Endereço completo
   - saldo: Saldo atual da conta
   - ativo: Status da conta (ativo/inativo)
   - data_criacao: Data de criação do registro
   - data_atualizacao: Data da última atualização

2. TABELA TRANSACOES (DETAIL):
   - id: Chave primária auto-incremento
   - valor: Valor da transação
   - tipo: Tipo da transação (enum com valores fixos)
   - descricao: Descrição opcional da transação
   - usuario_id: Chave estrangeira para usuarios (FK)
   - data_transacao: Data/hora da transação
   - data_criacao: Data de criação do registro
   - data_atualizacao: Data da última atualização

RELACIONAMENTO:
- usuarios (1) -----> (N) transacoes
- Relacionamento One-to-Many
- FK: transacoes.usuario_id -> usuarios.id
- Cascade delete: Se usuário for deletado, transações são deletadas

TIPOS DE TRANSAÇÃO:
- DEPOSITO: Adiciona valor ao saldo
- SAQUE: Remove valor do saldo
- TRANSFERENCIA_ENVIADA: Remove valor do saldo
- TRANSFERENCIA_RECEBIDA: Adiciona valor ao saldo
- PAGAMENTO: Remove valor do saldo
- RECEBIMENTO: Adiciona valor ao saldo

ÍNDICES CRIADOS PARA PERFORMANCE:
- Índices em campos frequentemente consultados
- Índices em chaves estrangeiras
- Índices em campos de busca

TRIGGERS:
- Atualização automática de data_atualizacao
- Auditoria de mudanças

VIEWS:
- vw_usuarios_saldo: Relatório de usuários com estatísticas
- vw_transacoes_detalhadas: Transações com dados do usuário

STORED PROCEDURES:
- sp_atualizar_saldo_usuario: Atualiza saldo baseado no tipo de transação
*/
