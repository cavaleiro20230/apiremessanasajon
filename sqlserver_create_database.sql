-- Script de criação do banco de dados SQL Server para Sistema NASAJON Banking
-- Execute este script como administrador do SQL Server

-- Criar database (descomente se necessário)
-- CREATE DATABASE NasajonBanking;
-- GO
-- USE NasajonBanking;
-- GO

-- =====================================================
-- TABELA DE USUÁRIOS E AUTENTICAÇÃO
-- =====================================================
CREATE TABLE usuarios (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    nome_completo NVARCHAR(200) NOT NULL,
    ativo BIT DEFAULT 1,
    ultimo_login DATETIME2,
    tentativas_login INT DEFAULT 0,
    bloqueado_ate DATETIME2,
    perfil NVARCHAR(20) DEFAULT 'usuario' CHECK (perfil IN ('admin', 'operador', 'usuario', 'readonly')),
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE CONFIGURAÇÕES DO SISTEMA
-- =====================================================
CREATE TABLE configuracoes (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    chave NVARCHAR(100) NOT NULL UNIQUE,
    valor NVARCHAR(MAX),
    descricao NVARCHAR(MAX),
    tipo NVARCHAR(20) DEFAULT 'string' CHECK (tipo IN ('string', 'number', 'boolean', 'json')),
    categoria NVARCHAR(50) DEFAULT 'geral',
    ativo BIT DEFAULT 1,
    editavel BIT DEFAULT 1,
    usuario_criacao UNIQUEIDENTIFIER REFERENCES usuarios(id),
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE BANCOS
-- =====================================================
CREATE TABLE bancos (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    codigo NVARCHAR(10) NOT NULL UNIQUE,
    nome NVARCHAR(100) NOT NULL,
    nome_completo NVARCHAR(200),
    agencia NVARCHAR(20),
    agencia_dv NVARCHAR(2),
    conta NVARCHAR(30),
    conta_dv NVARCHAR(2),
    convenio NVARCHAR(50),
    carteira NVARCHAR(10),
    variacao_carteira NVARCHAR(10),
    cedente NVARCHAR(100),
    cnpj_cedente NVARCHAR(18),
    endereco_cedente NVARCHAR(MAX),
    layout_remessa NVARCHAR(10) DEFAULT 'CNAB240' CHECK (layout_remessa IN ('CNAB240', 'CNAB400')),
    layout_retorno NVARCHAR(10) DEFAULT 'CNAB240' CHECK (layout_retorno IN ('CNAB240', 'CNAB400')),
    url_api NVARCHAR(500),
    configuracao_api NVARCHAR(MAX), -- JSON como string no SQL Server
    ativo BIT DEFAULT 1,
    usuario_criacao UNIQUEIDENTIFIER REFERENCES usuarios(id),
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE REMESSAS
-- =====================================================
CREATE TABLE remessas (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    codigo NVARCHAR(50) NOT NULL UNIQUE,
    banco_id UNIQUEIDENTIFIER NOT NULL REFERENCES bancos(id),
    tipo NVARCHAR(20) NOT NULL CHECK (tipo IN ('envio', 'retorno')),
    subtipo NVARCHAR(30) CHECK (subtipo IN ('cobranca', 'pagamento', 'ted', 'doc', 'pix')),
    status NVARCHAR(20) NOT NULL DEFAULT 'criada' CHECK (status IN ('criada', 'validada', 'enviada', 'processando', 'processada', 'erro', 'cancelada')),
    arquivo_nome NVARCHAR(255),
    arquivo_caminho NVARCHAR(MAX),
    arquivo_tamanho BIGINT,
    arquivo_hash NVARCHAR(64),
    valor_total DECIMAL(15,2) DEFAULT 0,
    quantidade_registros INT DEFAULT 0,
    quantidade_processados INT DEFAULT 0,
    quantidade_erros INT DEFAULT 0,
    observacoes NVARCHAR(MAX),
    data_vencimento DATE,
    data_processamento_banco DATE,
    protocolo_banco NVARCHAR(100),
    protocolo_nasajon NVARCHAR(100),
    numero_sequencial INT,
    data_envio DATETIME2,
    data_processamento DATETIME2,
    data_retorno DATETIME2,
    erro_descricao NVARCHAR(MAX),
    metadados NVARCHAR(MAX), -- JSON como string
    usuario_criacao UNIQUEIDENTIFIER REFERENCES usuarios(id),
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_atualizacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE REGISTROS DE REMESSA (DETALHAMENTO)
-- =====================================================
CREATE TABLE registros_remessa (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    remessa_id UNIQUEIDENTIFIER NOT NULL REFERENCES remessas(id) ON DELETE CASCADE,
    numero_linha INT NOT NULL,
    tipo_registro NVARCHAR(10) NOT NULL,
    codigo_segmento NVARCHAR(5),
    conteudo_original NVARCHAR(MAX) NOT NULL,
    conteudo_processado NVARCHAR(MAX), -- JSON como string
    valor DECIMAL(15,2),
    nosso_numero NVARCHAR(50),
    seu_numero NVARCHAR(50),
    cpf_cnpj_pagador NVARCHAR(18),
    nome_pagador NVARCHAR(100),
    data_vencimento DATE,
    data_pagamento DATE,
    valor_pago DECIMAL(15,2),
    valor_desconto DECIMAL(15,2),
    valor_multa DECIMAL(15,2),
    valor_juros DECIMAL(15,2),
    codigo_ocorrencia NVARCHAR(10),
    descricao_ocorrencia NVARCHAR(200),
    status NVARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processado', 'erro', 'rejeitado')),
    erro_descricao NVARCHAR(MAX),
    data_processamento DATETIME2,
    data_criacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE INTEGRAÇÃO NASAJON
-- =====================================================
CREATE TABLE integracao_nasajon (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    remessa_id UNIQUEIDENTIFIER REFERENCES remessas(id),
    tipo_operacao NVARCHAR(30) NOT NULL CHECK (tipo_operacao IN ('envio_remessa', 'consulta_status', 'processar_retorno', 'sincronizar_dados')),
    endpoint NVARCHAR(200),
    metodo NVARCHAR(10) DEFAULT 'POST',
    payload_enviado NVARCHAR(MAX), -- JSON como string
    resposta_recebida NVARCHAR(MAX), -- JSON como string
    status_http INT,
    status NVARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'sucesso', 'erro', 'timeout')),
    tempo_resposta_ms INT,
    tentativas INT DEFAULT 1,
    erro_descricao NVARCHAR(MAX),
    data_envio DATETIME2 DEFAULT GETDATE(),
    data_resposta DATETIME2
);

-- =====================================================
-- TABELA DE LOGS DE AUDITORIA
-- =====================================================
CREATE TABLE logs_auditoria (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    usuario_id UNIQUEIDENTIFIER REFERENCES usuarios(id),
    usuario_nome NVARCHAR(100),
    acao NVARCHAR(100) NOT NULL,
    tabela NVARCHAR(50),
    registro_id UNIQUEIDENTIFIER,
    dados_anteriores NVARCHAR(MAX), -- JSON como string
    dados_novos NVARCHAR(MAX), -- JSON como string
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(MAX),
    sessao_id NVARCHAR(100),
    modulo NVARCHAR(50),
    nivel NVARCHAR(10) DEFAULT 'INFO' CHECK (nivel IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL')),
    data_criacao DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- TABELA DE NOTIFICAÇÕES
-- =====================================================
CREATE TABLE notificacoes (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    tipo NVARCHAR(50) NOT NULL,
    titulo NVARCHAR(200) NOT NULL,
    mensagem NVARCHAR(MAX),
    destinatario NVARCHAR(100),
    canal NVARCHAR(20) DEFAULT 'email' CHECK (canal IN ('email', 'sms', 'push', 'sistema')),
    prioridade NVARCHAR(10) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'critica')),
    lida BIT DEFAULT 0,
    data_leitura DATETIME2,
    enviada BIT DEFAULT 0,
    data_envio DATETIME2,
    tentativas_envio INT DEFAULT 0,
    erro_envio NVARCHAR(MAX),
    metadados NVARCHAR(MAX), -- JSON como string
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_expiracao DATETIME2
);

-- =====================================================
-- TABELA DE ARQUIVOS (BACKUP E VERSIONAMENTO)
-- =====================================================
CREATE TABLE arquivos (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    nome_original NVARCHAR(255) NOT NULL,
    nome_fisico NVARCHAR(255) NOT NULL,
    caminho_completo NVARCHAR(MAX) NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo_mime NVARCHAR(100),
    hash_md5 NVARCHAR(32),
    hash_sha256 NVARCHAR(64),
    comprimido BIT DEFAULT 0,
    criptografado BIT DEFAULT 0,
    backup_realizado BIT DEFAULT 0,
    data_backup DATETIME2,
    remessa_id UNIQUEIDENTIFIER REFERENCES remessas(id),
    usuario_upload UNIQUEIDENTIFIER REFERENCES usuarios(id),
    data_criacao DATETIME2 DEFAULT GETDATE(),
    data_exclusao DATETIME2
);

-- =====================================================
-- TABELA DE SESSÕES DE USUÁRIO
-- =====================================================
CREATE TABLE sessoes_usuario (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    usuario_id UNIQUEIDENTIFIER NOT NULL REFERENCES usuarios(id),
    token_sessao NVARCHAR(255) NOT NULL UNIQUE,
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(MAX),
    ativa BIT DEFAULT 1,
    data_login DATETIME2 DEFAULT GETDATE(),
    data_ultimo_acesso DATETIME2 DEFAULT GETDATE(),
    data_expiracao DATETIME2 NOT NULL,
    data_logout DATETIME2
);

-- =====================================================
-- TABELA DE PARÂMETROS BANCÁRIOS
-- =====================================================
CREATE TABLE parametros_bancarios (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    banco_id UNIQUEIDENTIFIER NOT NULL REFERENCES bancos(id),
    parametro NVARCHAR(100) NOT NULL,
    valor NVARCHAR(500),
    descricao NVARCHAR(MAX),
    obrigatorio BIT DEFAULT 0,
    tipo_dado NVARCHAR(20) DEFAULT 'string',
    validacao_regex NVARCHAR(200),
    ativo BIT DEFAULT 1,
    data_criacao DATETIME2 DEFAULT GETDATE(),
    UNIQUE(banco_id, parametro)
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela usuarios
CREATE INDEX IX_usuarios_username ON usuarios(username);
CREATE INDEX IX_usuarios_email ON usuarios(email);
CREATE INDEX IX_usuarios_ativo ON usuarios(ativo);

-- Índices para tabela configuracoes
CREATE INDEX IX_configuracoes_chave ON configuracoes(chave);
CREATE INDEX IX_configuracoes_categoria ON configuracoes(categoria);
CREATE INDEX IX_configuracoes_ativo ON configuracoes(ativo);

-- Índices para tabela bancos
CREATE INDEX IX_bancos_codigo ON bancos(codigo);
CREATE INDEX IX_bancos_ativo ON bancos(ativo);
CREATE INDEX IX_bancos_nome ON bancos(nome);

-- Índices para tabela remessas
CREATE INDEX IX_remessas_banco_id ON remessas(banco_id);
CREATE INDEX IX_remessas_status ON remessas(status);
CREATE INDEX IX_remessas_tipo ON remessas(tipo);
CREATE INDEX IX_remessas_data_criacao ON remessas(data_criacao);
CREATE INDEX IX_remessas_data_envio ON remessas(data_envio);
CREATE INDEX IX_remessas_codigo ON remessas(codigo);
CREATE INDEX IX_remessas_protocolo_banco ON remessas(protocolo_banco);

-- Índices para tabela registros_remessa
CREATE INDEX IX_registros_remessa_id ON registros_remessa(remessa_id);
CREATE INDEX IX_registros_status ON registros_remessa(status);
CREATE INDEX IX_registros_nosso_numero ON registros_remessa(nosso_numero);
CREATE INDEX IX_registros_cpf_cnpj ON registros_remessa(cpf_cnpj_pagador);

-- Índices para tabela integracao_nasajon
CREATE INDEX IX_integracao_remessa_id ON integracao_nasajon(remessa_id);
CREATE INDEX IX_integracao_tipo_operacao ON integracao_nasajon(tipo_operacao);
CREATE INDEX IX_integracao_status ON integracao_nasajon(status);
CREATE INDEX IX_integracao_data_envio ON integracao_nasajon(data_envio);

-- Índices para tabela logs_auditoria
CREATE INDEX IX_logs_usuario_id ON logs_auditoria(usuario_id);
CREATE INDEX IX_logs_acao ON logs_auditoria(acao);
CREATE INDEX IX_logs_tabela ON logs_auditoria(tabela);
CREATE INDEX IX_logs_data_criacao ON logs_auditoria(data_criacao);
CREATE INDEX IX_logs_nivel ON logs_auditoria(nivel);

-- Índices para tabela notificacoes
CREATE INDEX IX_notificacoes_destinatario ON notificacoes(destinatario);
CREATE INDEX IX_notificacoes_tipo ON notificacoes(tipo);
CREATE INDEX IX_notificacoes_lida ON notificacoes(lida);
CREATE INDEX IX_notificacoes_enviada ON notificacoes(enviada);
CREATE INDEX IX_notificacoes_data_criacao ON notificacoes(data_criacao);

-- Índices para tabela arquivos
CREATE INDEX IX_arquivos_remessa_id ON arquivos(remessa_id);
CREATE INDEX IX_arquivos_hash_md5 ON arquivos(hash_md5);
CREATE INDEX IX_arquivos_data_criacao ON arquivos(data_criacao);

-- Índices para tabela sessoes_usuario
CREATE INDEX IX_sessoes_usuario_id ON sessoes_usuario(usuario_id);
CREATE INDEX IX_sessoes_token ON sessoes_usuario(token_sessao);
CREATE INDEX IX_sessoes_ativa ON sessoes_usuario(ativa);
CREATE INDEX IX_sessoes_data_expiracao ON sessoes_usuario(data_expiracao);

-- =====================================================
-- TRIGGERS PARA AUDITORIA AUTOMÁTICA
-- =====================================================

-- Trigger para atualizar data_atualizacao
CREATE TRIGGER TR_usuarios_update_timestamp
ON usuarios
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE usuarios 
    SET data_atualizacao = GETDATE()
    FROM usuarios u
    INNER JOIN inserted i ON u.id = i.id;
END;
GO

CREATE TRIGGER TR_configuracoes_update_timestamp
ON configuracoes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE configuracoes 
    SET data_atualizacao = GETDATE()
    FROM configuracoes c
    INNER JOIN inserted i ON c.id = i.id;
END;
GO

CREATE TRIGGER TR_bancos_update_timestamp
ON bancos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE bancos 
    SET data_atualizacao = GETDATE()
    FROM bancos b
    INNER JOIN inserted i ON b.id = i.id;
END;
GO

CREATE TRIGGER TR_remessas_update_timestamp
ON remessas
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE remessas 
    SET data_atualizacao = GETDATE()
    FROM remessas r
    INNER JOIN inserted i ON r.id = i.id;
END;
GO

-- Triggers de auditoria
CREATE TRIGGER TR_remessas_audit
ON remessas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- INSERT
    IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_novos)
        SELECT 'INSERT', 'remessas', i.id, 
               '{"codigo":"' + i.codigo + '","status":"' + i.status + '"}'
        FROM inserted i;
    END
    
    -- UPDATE
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores, dados_novos)
        SELECT 'UPDATE', 'remessas', i.id,
               '{"status":"' + d.status + '"}',
               '{"status":"' + i.status + '"}'
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id;
    END
    
    -- DELETE
    IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores)
        SELECT 'DELETE', 'remessas', d.id,
               '{"codigo":"' + d.codigo + '","status":"' + d.status + '"}'
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER TR_bancos_audit
ON bancos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- INSERT
    IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_novos)
        SELECT 'INSERT', 'bancos', i.id, 
               '{"codigo":"' + i.codigo + '","nome":"' + i.nome + '"}'
        FROM inserted i;
    END
    
    -- UPDATE
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores, dados_novos)
        SELECT 'UPDATE', 'bancos', i.id,
               '{"ativo":"' + CAST(d.ativo AS NVARCHAR) + '"}',
               '{"ativo":"' + CAST(i.ativo AS NVARCHAR) + '"}'
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id;
    END
    
    -- DELETE
    IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores)
        SELECT 'DELETE', 'bancos', d.id,
               '{"codigo":"' + d.codigo + '","nome":"' + d.nome + '"}'
        FROM deleted d;
    END
END;
GO

-- =====================================================
-- VIEWS PARA RELATÓRIOS
-- =====================================================

-- View para dashboard principal
CREATE VIEW vw_dashboard_stats AS
SELECT 
    COUNT(*) as total_remessas,
    COUNT(CASE WHEN tipo = 'envio' THEN 1 END) as total_envios,
    COUNT(CASE WHEN tipo = 'retorno' THEN 1 END) as total_retornos,
    COUNT(CASE WHEN status = 'processada' THEN 1 END) as processadas,
    COUNT(CASE WHEN status = 'erro' THEN 1 END) as com_erro,
    COUNT(CASE WHEN status IN ('criada', 'validada', 'enviada', 'processando') THEN 1 END) as pendentes,
    SUM(valor_total) as valor_total_geral,
    SUM(quantidade_registros) as total_registros
FROM remessas
WHERE data_criacao >= DATEADD(day, -30, GETDATE());
GO

-- View para remessas com informações do banco
CREATE VIEW vw_remessas_completas AS
SELECT 
    r.id,
    r.codigo,
    r.tipo,
    r.subtipo,
    r.status,
    r.valor_total,
    r.quantidade_registros,
    r.data_criacao,
    r.data_envio,
    r.data_processamento,
    b.codigo as banco_codigo,
    b.nome as banco_nome,
    u.nome_completo as usuario_criacao_nome
FROM remessas r
INNER JOIN bancos b ON r.banco_id = b.id
LEFT JOIN usuarios u ON r.usuario_criacao = u.id;
GO

-- View para logs de auditoria com informações do usuário
CREATE VIEW vw_logs_auditoria_completos AS
SELECT 
    l.id,
    l.acao,
    l.tabela,
    l.registro_id,
    l.data_criacao,
    l.ip_address,
    l.nivel,
    u.nome_completo as usuario_nome,
    u.username
FROM logs_auditoria l
LEFT JOIN usuarios u ON l.usuario_id = u.id;
GO

-- =====================================================
-- FUNÇÕES UTILITÁRIAS
-- =====================================================

-- Função para gerar código de remessa
CREATE FUNCTION dbo.fn_gerar_codigo_remessa(@tipo_remessa NVARCHAR(10))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @prefixo NVARCHAR(3);
    DECLARE @sequencial INT;
    DECLARE @codigo NVARCHAR(50);
    
    SET @prefixo = CASE 
        WHEN @tipo_remessa = 'envio' THEN 'REM'
        WHEN @tipo_remessa = 'retorno' THEN 'RET'
        ELSE 'DOC'
    END;
    
    SELECT @sequencial = ISNULL(MAX(CAST(SUBSTRING(codigo, 4, 6) AS INT)), 0) + 1
    FROM remessas 
    WHERE codigo LIKE @prefixo + '%'
    AND LEN(codigo) = 9;
    
    SET @codigo = @prefixo + RIGHT('000000' + CAST(@sequencial AS NVARCHAR), 6);
    
    RETURN @codigo;
END;
GO

-- Função para validar CNPJ
CREATE FUNCTION dbo.fn_validar_cnpj(@cnpj NVARCHAR(18))
RETURNS BIT
AS
BEGIN
    DECLARE @cnpj_numeros NVARCHAR(14);
    DECLARE @soma INT;
    DECLARE @resto INT;
    DECLARE @dv1 INT;
    DECLARE @dv2 INT;
    DECLARE @i INT;
    DECLARE @multiplicador INT;
    
    -- Remove caracteres não numéricos
    SET @cnpj_numeros = '';
    SET @i = 1;
    WHILE @i <= LEN(@cnpj)
    BEGIN
        IF SUBSTRING(@cnpj, @i, 1) LIKE '[0-9]'
            SET @cnpj_numeros = @cnpj_numeros + SUBSTRING(@cnpj, @i, 1);
        SET @i = @i + 1;
    END;
    
    -- Verifica se tem 14 dígitos
    IF LEN(@cnpj_numeros) != 14
        RETURN 0;
    
    -- Verifica se todos os dígitos são iguais
    IF @cnpj_numeros LIKE REPLICATE(LEFT(@cnpj_numeros, 1), 14)
        RETURN 0;
    
    -- Calcula primeiro dígito verificador
    SET @soma = 0;
    SET @i = 1;
    WHILE @i <= 12
    BEGIN
        SET @multiplicador = CASE @i 
            WHEN 1 THEN 5 WHEN 2 THEN 6 WHEN 3 THEN 7 WHEN 4 THEN 8 
            WHEN 5 THEN 9 WHEN 6 THEN 2 WHEN 7 THEN 3 WHEN 8 THEN 4 
            WHEN 9 THEN 5 WHEN 10 THEN 6 WHEN 11 THEN 7 WHEN 12 THEN 8 
        END;
        SET @soma = @soma + CAST(SUBSTRING(@cnpj_numeros, @i, 1) AS INT) * @multiplicador;
        SET @i = @i + 1;
    END;
    
    SET @resto = @soma % 11;
    SET @dv1 = CASE WHEN @resto < 2 THEN 0 ELSE 11 - @resto END;
    
    -- Verifica primeiro dígito
    IF @dv1 != CAST(SUBSTRING(@cnpj_numeros, 13, 1) AS INT)
        RETURN 0;
    
    -- Calcula segundo dígito verificador
    SET @soma = 0;
    SET @i = 1;
    WHILE @i <= 13
    BEGIN
        SET @multiplicador = CASE @i 
            WHEN 1 THEN 6 WHEN 2 THEN 7 WHEN 3 THEN 8 WHEN 4 THEN 9 
            WHEN 5 THEN 2 WHEN 6 THEN 3 WHEN 7 THEN 4 WHEN 8 THEN 5 
            WHEN 9 THEN 6 WHEN 10 THEN 7 WHEN 11 THEN 8 WHEN 12 THEN 9 
            WHEN 13 THEN 2 
        END;
        SET @soma = @soma + CAST(SUBSTRING(@cnpj_numeros, @i, 1) AS INT) * @multiplicador;
        SET @i = @i + 1;
    END;
    
    SET @resto = @soma % 11;
    SET @dv2 = CASE WHEN @resto < 2 THEN 0 ELSE 11 - @resto END;
    
    -- Verifica segundo dígito
    RETURN CASE WHEN @dv2 = CAST(SUBSTRING(@cnpj_numeros, 14, 1) AS INT) THEN 1 ELSE 0 END;
END;
GO

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure para limpeza de logs antigos
CREATE PROCEDURE sp_limpar_logs_antigos
    @dias_retencao INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @data_limite DATETIME2 = DATEADD(day, -@dias_retencao, GETDATE());
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Limpar logs de auditoria
        DELETE FROM logs_auditoria 
        WHERE data_criacao < @data_limite 
        AND nivel NOT IN ('ERROR', 'CRITICAL');
        
        -- Limpar notificações antigas lidas
        DELETE FROM notificacoes 
        WHERE data_criacao < @data_limite 
        AND lida = 1;
        
        -- Limpar sessões expiradas
        DELETE FROM sessoes_usuario 
        WHERE data_expiracao < GETDATE();
        
        COMMIT TRANSACTION;
        
        PRINT 'Limpeza de logs concluída com sucesso.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Procedure para backup de remessas
CREATE PROCEDURE sp_backup_remessas
    @data_inicio DATE,
    @data_fim DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Esta procedure seria implementada para fazer backup das remessas
    -- em um período específico para arquivamento
    
    SELECT 
        r.*,
        b.nome as banco_nome,
        u.nome_completo as usuario_nome
    FROM remessas r
    INNER JOIN bancos b ON r.banco_id = b.id
    LEFT JOIN usuarios u ON r.usuario_criacao = u.id
    WHERE r.data_criacao BETWEEN @data_inicio AND @data_fim
    ORDER BY r.data_criacao;
END;
GO

-- =====================================================
-- COMENTÁRIOS NAS TABELAS
-- =====================================================
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Tabela de usuários do sistema com controle de acesso', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'usuarios';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Configurações gerais do sistema', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'configuracoes';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Cadastro de bancos e suas configurações', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'bancos';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Registro de todas as remessas enviadas e retornos processados', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'remessas';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Detalhamento linha a linha das remessas', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'registros_remessa';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Log de integração com a API NASAJON', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'integracao_nasajon';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Log completo de auditoria do sistema', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'logs_auditoria';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Sistema de notificações do sistema', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'notificacoes';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Controle de arquivos com backup e versionamento', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'arquivos';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Controle de sessões ativas dos usuários', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'sessoes_usuario';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Parâmetros específicos por banco', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'parametros_bancarios';

-- =====================================================
-- PERMISSÕES E SEGURANÇA
-- =====================================================

-- Criar login e usuário para aplicação (descomente se necessário)
/*
CREATE LOGIN nasajon_app_user WITH PASSWORD = 'SenhaSegura123!';
CREATE USER nasajon_app_user FOR LOGIN nasajon_app_user;

-- Criar role personalizada
CREATE ROLE nasajon_app_role;

-- Conceder permissões à role
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO nasajon_app_role;
GRANT EXECUTE ON SCHEMA::dbo TO nasajon_app_role;

-- Adicionar usuário à role
ALTER ROLE nasajon_app_role ADD MEMBER nasajon_app_user;
*/

PRINT 'Script de criação do banco de dados SQL Server executado com sucesso!';
