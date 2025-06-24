-- Script de criação do banco de dados PostgreSQL para Sistema NASAJON Banking
-- Execute este script como superusuário do PostgreSQL

-- Criar database (execute separadamente se necessário)
-- CREATE DATABASE nasajon_banking;
-- \c nasajon_banking;

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Criar schema específico para o sistema
CREATE SCHEMA IF NOT EXISTS nasajon_banking;
SET search_path TO nasajon_banking, public;

-- =====================================================
-- TABELA DE USUÁRIOS E AUTENTICAÇÃO
-- =====================================================
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nome_completo VARCHAR(200) NOT NULL,
    ativo BOOLEAN DEFAULT true,
    ultimo_login TIMESTAMP,
    tentativas_login INTEGER DEFAULT 0,
    bloqueado_ate TIMESTAMP,
    perfil VARCHAR(20) DEFAULT 'usuario' CHECK (perfil IN ('admin', 'operador', 'usuario', 'readonly')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE CONFIGURAÇÕES DO SISTEMA
-- =====================================================
CREATE TABLE configuracoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT,
    descricao TEXT,
    tipo VARCHAR(20) DEFAULT 'string' CHECK (tipo IN ('string', 'number', 'boolean', 'json')),
    categoria VARCHAR(50) DEFAULT 'geral',
    ativo BOOLEAN DEFAULT true,
    editavel BOOLEAN DEFAULT true,
    usuario_criacao UUID REFERENCES usuarios(id),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE BANCOS
-- =====================================================
CREATE TABLE bancos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    nome_completo VARCHAR(200),
    agencia VARCHAR(20),
    agencia_dv VARCHAR(2),
    conta VARCHAR(30),
    conta_dv VARCHAR(2),
    convenio VARCHAR(50),
    carteira VARCHAR(10),
    variacao_carteira VARCHAR(10),
    cedente VARCHAR(100),
    cnpj_cedente VARCHAR(18),
    endereco_cedente TEXT,
    layout_remessa VARCHAR(10) DEFAULT 'CNAB240' CHECK (layout_remessa IN ('CNAB240', 'CNAB400')),
    layout_retorno VARCHAR(10) DEFAULT 'CNAB240' CHECK (layout_retorno IN ('CNAB240', 'CNAB400')),
    url_api VARCHAR(500),
    configuracao_api JSONB,
    ativo BOOLEAN DEFAULT true,
    usuario_criacao UUID REFERENCES usuarios(id),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE REMESSAS
-- =====================================================
CREATE TABLE remessas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(50) NOT NULL UNIQUE,
    banco_id UUID NOT NULL REFERENCES bancos(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('envio', 'retorno')),
    subtipo VARCHAR(30) CHECK (subtipo IN ('cobranca', 'pagamento', 'ted', 'doc', 'pix')),
    status VARCHAR(20) NOT NULL DEFAULT 'criada' CHECK (status IN ('criada', 'validada', 'enviada', 'processando', 'processada', 'erro', 'cancelada')),
    arquivo_nome VARCHAR(255),
    arquivo_caminho TEXT,
    arquivo_tamanho BIGINT,
    arquivo_hash VARCHAR(64),
    valor_total DECIMAL(15,2) DEFAULT 0,
    quantidade_registros INTEGER DEFAULT 0,
    quantidade_processados INTEGER DEFAULT 0,
    quantidade_erros INTEGER DEFAULT 0,
    observacoes TEXT,
    data_vencimento DATE,
    data_processamento_banco DATE,
    protocolo_banco VARCHAR(100),
    protocolo_nasajon VARCHAR(100),
    numero_sequencial INTEGER,
    data_envio TIMESTAMP,
    data_processamento TIMESTAMP,
    data_retorno TIMESTAMP,
    erro_descricao TEXT,
    metadados JSONB,
    usuario_criacao UUID REFERENCES usuarios(id),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE REGISTROS DE REMESSA (DETALHAMENTO)
-- =====================================================
CREATE TABLE registros_remessa (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    remessa_id UUID NOT NULL REFERENCES remessas(id) ON DELETE CASCADE,
    numero_linha INTEGER NOT NULL,
    tipo_registro VARCHAR(10) NOT NULL,
    codigo_segmento VARCHAR(5),
    conteudo_original TEXT NOT NULL,
    conteudo_processado JSONB,
    valor DECIMAL(15,2),
    nosso_numero VARCHAR(50),
    seu_numero VARCHAR(50),
    cpf_cnpj_pagador VARCHAR(18),
    nome_pagador VARCHAR(100),
    data_vencimento DATE,
    data_pagamento DATE,
    valor_pago DECIMAL(15,2),
    valor_desconto DECIMAL(15,2),
    valor_multa DECIMAL(15,2),
    valor_juros DECIMAL(15,2),
    codigo_ocorrencia VARCHAR(10),
    descricao_ocorrencia VARCHAR(200),
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processado', 'erro', 'rejeitado')),
    erro_descricao TEXT,
    data_processamento TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE INTEGRAÇÃO NASAJON
-- =====================================================
CREATE TABLE integracao_nasajon (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    remessa_id UUID REFERENCES remessas(id),
    tipo_operacao VARCHAR(30) NOT NULL CHECK (tipo_operacao IN ('envio_remessa', 'consulta_status', 'processar_retorno', 'sincronizar_dados')),
    endpoint VARCHAR(200),
    metodo VARCHAR(10) DEFAULT 'POST',
    payload_enviado JSONB,
    resposta_recebida JSONB,
    status_http INTEGER,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'sucesso', 'erro', 'timeout')),
    tempo_resposta_ms INTEGER,
    tentativas INTEGER DEFAULT 1,
    erro_descricao TEXT,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_resposta TIMESTAMP
);

-- =====================================================
-- TABELA DE LOGS DE AUDITORIA
-- =====================================================
CREATE TABLE logs_auditoria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id),
    usuario_nome VARCHAR(100),
    acao VARCHAR(100) NOT NULL,
    tabela VARCHAR(50),
    registro_id UUID,
    dados_anteriores JSONB,
    dados_novos JSONB,
    ip_address INET,
    user_agent TEXT,
    sessao_id VARCHAR(100),
    modulo VARCHAR(50),
    nivel VARCHAR(10) DEFAULT 'INFO' CHECK (nivel IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA DE NOTIFICAÇÕES
-- =====================================================
CREATE TABLE notificacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensagem TEXT,
    destinatario VARCHAR(100),
    canal VARCHAR(20) DEFAULT 'email' CHECK (canal IN ('email', 'sms', 'push', 'sistema')),
    prioridade VARCHAR(10) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'critica')),
    lida BOOLEAN DEFAULT false,
    data_leitura TIMESTAMP,
    enviada BOOLEAN DEFAULT false,
    data_envio TIMESTAMP,
    tentativas_envio INTEGER DEFAULT 0,
    erro_envio TEXT,
    metadados JSONB,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP
);

-- =====================================================
-- TABELA DE ARQUIVOS (BACKUP E VERSIONAMENTO)
-- =====================================================
CREATE TABLE arquivos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_original VARCHAR(255) NOT NULL,
    nome_fisico VARCHAR(255) NOT NULL,
    caminho_completo TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo_mime VARCHAR(100),
    hash_md5 VARCHAR(32),
    hash_sha256 VARCHAR(64),
    comprimido BOOLEAN DEFAULT false,
    criptografado BOOLEAN DEFAULT false,
    backup_realizado BOOLEAN DEFAULT false,
    data_backup TIMESTAMP,
    remessa_id UUID REFERENCES remessas(id),
    usuario_upload UUID REFERENCES usuarios(id),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_exclusao TIMESTAMP
);

-- =====================================================
-- TABELA DE SESSÕES DE USUÁRIO
-- =====================================================
CREATE TABLE sessoes_usuario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    token_sessao VARCHAR(255) NOT NULL UNIQUE,
    ip_address INET,
    user_agent TEXT,
    ativa BOOLEAN DEFAULT true,
    data_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_ultimo_acesso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP NOT NULL,
    data_logout TIMESTAMP
);

-- =====================================================
-- TABELA DE PARÂMETROS BANCÁRIOS
-- =====================================================
CREATE TABLE parametros_bancarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    banco_id UUID NOT NULL REFERENCES bancos(id),
    parametro VARCHAR(100) NOT NULL,
    valor VARCHAR(500),
    descricao TEXT,
    obrigatorio BOOLEAN DEFAULT false,
    tipo_dado VARCHAR(20) DEFAULT 'string',
    validacao_regex VARCHAR(200),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(banco_id, parametro)
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela usuarios
CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_ativo ON usuarios(ativo);

-- Índices para tabela configuracoes
CREATE INDEX idx_configuracoes_chave ON configuracoes(chave);
CREATE INDEX idx_configuracoes_categoria ON configuracoes(categoria);
CREATE INDEX idx_configuracoes_ativo ON configuracoes(ativo);

-- Índices para tabela bancos
CREATE INDEX idx_bancos_codigo ON bancos(codigo);
CREATE INDEX idx_bancos_ativo ON bancos(ativo);
CREATE INDEX idx_bancos_nome ON bancos(nome);

-- Índices para tabela remessas
CREATE INDEX idx_remessas_banco_id ON remessas(banco_id);
CREATE INDEX idx_remessas_status ON remessas(status);
CREATE INDEX idx_remessas_tipo ON remessas(tipo);
CREATE INDEX idx_remessas_data_criacao ON remessas(data_criacao);
CREATE INDEX idx_remessas_data_envio ON remessas(data_envio);
CREATE INDEX idx_remessas_codigo ON remessas(codigo);
CREATE INDEX idx_remessas_protocolo_banco ON remessas(protocolo_banco);

-- Índices para tabela registros_remessa
CREATE INDEX idx_registros_remessa_id ON registros_remessa(remessa_id);
CREATE INDEX idx_registros_status ON registros_remessa(status);
CREATE INDEX idx_registros_nosso_numero ON registros_remessa(nosso_numero);
CREATE INDEX idx_registros_cpf_cnpj ON registros_remessa(cpf_cnpj_pagador);

-- Índices para tabela integracao_nasajon
CREATE INDEX idx_integracao_remessa_id ON integracao_nasajon(remessa_id);
CREATE INDEX idx_integracao_tipo_operacao ON integracao_nasajon(tipo_operacao);
CREATE INDEX idx_integracao_status ON integracao_nasajon(status);
CREATE INDEX idx_integracao_data_envio ON integracao_nasajon(data_envio);

-- Índices para tabela logs_auditoria
CREATE INDEX idx_logs_usuario_id ON logs_auditoria(usuario_id);
CREATE INDEX idx_logs_acao ON logs_auditoria(acao);
CREATE INDEX idx_logs_tabela ON logs_auditoria(tabela);
CREATE INDEX idx_logs_data_criacao ON logs_auditoria(data_criacao);
CREATE INDEX idx_logs_nivel ON logs_auditoria(nivel);

-- Índices para tabela notificacoes
CREATE INDEX idx_notificacoes_destinatario ON notificacoes(destinatario);
CREATE INDEX idx_notificacoes_tipo ON notificacoes(tipo);
CREATE INDEX idx_notificacoes_lida ON notificacoes(lida);
CREATE INDEX idx_notificacoes_enviada ON notificacoes(enviada);
CREATE INDEX idx_notificacoes_data_criacao ON notificacoes(data_criacao);

-- Índices para tabela arquivos
CREATE INDEX idx_arquivos_remessa_id ON arquivos(remessa_id);
CREATE INDEX idx_arquivos_hash_md5 ON arquivos(hash_md5);
CREATE INDEX idx_arquivos_data_criacao ON arquivos(data_criacao);

-- Índices para tabela sessoes_usuario
CREATE INDEX idx_sessoes_usuario_id ON sessoes_usuario(usuario_id);
CREATE INDEX idx_sessoes_token ON sessoes_usuario(token_sessao);
CREATE INDEX idx_sessoes_ativa ON sessoes_usuario(ativa);
CREATE INDEX idx_sessoes_data_expiracao ON sessoes_usuario(data_expiracao);

-- =====================================================
-- TRIGGERS PARA AUDITORIA AUTOMÁTICA
-- =====================================================

-- Função para trigger de auditoria
CREATE OR REPLACE FUNCTION trigger_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_novos)
        VALUES ('INSERT', TG_TABLE_NAME, NEW.id, row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores, dados_novos)
        VALUES ('UPDATE', TG_TABLE_NAME, NEW.id, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs_auditoria (acao, tabela, registro_id, dados_anteriores)
        VALUES ('DELETE', TG_TABLE_NAME, OLD.id, row_to_json(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aplicar triggers de auditoria nas tabelas principais
CREATE TRIGGER trigger_auditoria_remessas
    AFTER INSERT OR UPDATE OR DELETE ON remessas
    FOR EACH ROW EXECUTE FUNCTION trigger_auditoria();

CREATE TRIGGER trigger_auditoria_bancos
    AFTER INSERT OR UPDATE OR DELETE ON bancos
    FOR EACH ROW EXECUTE FUNCTION trigger_auditoria();

CREATE TRIGGER trigger_auditoria_configuracoes
    AFTER INSERT OR UPDATE OR DELETE ON configuracoes
    FOR EACH ROW EXECUTE FUNCTION trigger_auditoria();

-- =====================================================
-- FUNÇÃO PARA ATUALIZAR data_atualizacao
-- =====================================================
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de timestamp nas tabelas
CREATE TRIGGER trigger_timestamp_usuarios
    BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_timestamp_configuracoes
    BEFORE UPDATE ON configuracoes
    FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_timestamp_bancos
    BEFORE UPDATE ON bancos
    FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_timestamp_remessas
    BEFORE UPDATE ON remessas
    FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();

-- =====================================================
-- VIEWS PARA RELATÓRIOS
-- =====================================================

-- View para dashboard principal
CREATE VIEW vw_dashboard_stats AS
SELECT 
    COUNT(*) as total_remessas,
    COUNT(*) FILTER (WHERE tipo = 'envio') as total_envios,
    COUNT(*) FILTER (WHERE tipo = 'retorno') as total_retornos,
    COUNT(*) FILTER (WHERE status = 'processada') as processadas,
    COUNT(*) FILTER (WHERE status = 'erro') as com_erro,
    COUNT(*) FILTER (WHERE status IN ('criada', 'validada', 'enviada', 'processando')) as pendentes,
    SUM(valor_total) as valor_total_geral,
    SUM(quantidade_registros) as total_registros
FROM remessas
WHERE data_criacao >= CURRENT_DATE - INTERVAL '30 days';

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
JOIN bancos b ON r.banco_id = b.id
LEFT JOIN usuarios u ON r.usuario_criacao = u.id;

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

-- =====================================================
-- FUNÇÕES UTILITÁRIAS
-- =====================================================

-- Função para gerar código de remessa
CREATE OR REPLACE FUNCTION gerar_codigo_remessa(tipo_remessa VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    prefixo VARCHAR(3);
    sequencial INTEGER;
    codigo VARCHAR(50);
BEGIN
    prefixo := CASE 
        WHEN tipo_remessa = 'envio' THEN 'REM'
        WHEN tipo_remessa = 'retorno' THEN 'RET'
        ELSE 'DOC'
    END;
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo FROM 4) AS INTEGER)), 0) + 1
    INTO sequencial
    FROM remessas 
    WHERE codigo LIKE prefixo || '%'
    AND LENGTH(codigo) = 9;
    
    codigo := prefixo || LPAD(sequencial::TEXT, 6, '0');
    
    RETURN codigo;
END;
$$ LANGUAGE plpgsql;

-- Função para validar CNPJ
CREATE OR REPLACE FUNCTION validar_cnpj(cnpj VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    cnpj_numeros VARCHAR(14);
    soma INTEGER;
    resto INTEGER;
    dv1 INTEGER;
    dv2 INTEGER;
BEGIN
    -- Remove caracteres não numéricos
    cnpj_numeros := REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g');
    
    -- Verifica se tem 14 dígitos
    IF LENGTH(cnpj_numeros) != 14 THEN
        RETURN FALSE;
    END IF;
    
    -- Verifica se todos os dígitos são iguais
    IF cnpj_numeros ~ '^(\d)\1{13}$' THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula primeiro dígito verificador
    soma := 0;
    FOR i IN 1..12 LOOP
        soma := soma + CAST(SUBSTRING(cnpj_numeros FROM i FOR 1) AS INTEGER) * 
                CASE i 
                    WHEN 1 THEN 5 WHEN 2 THEN 6 WHEN 3 THEN 7 WHEN 4 THEN 8 
                    WHEN 5 THEN 9 WHEN 6 THEN 2 WHEN 7 THEN 3 WHEN 8 THEN 4 
                    WHEN 9 THEN 5 WHEN 10 THEN 6 WHEN 11 THEN 7 WHEN 12 THEN 8 
                END;
    END LOOP;
    
    resto := soma % 11;
    dv1 := CASE WHEN resto < 2 THEN 0 ELSE 11 - resto END;
    
    -- Verifica primeiro dígito
    IF dv1 != CAST(SUBSTRING(cnpj_numeros FROM 13 FOR 1) AS INTEGER) THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula segundo dígito verificador
    soma := 0;
    FOR i IN 1..13 LOOP
        soma := soma + CAST(SUBSTRING(cnpj_numeros FROM i FOR 1) AS INTEGER) * 
                CASE i 
                    WHEN 1 THEN 6 WHEN 2 THEN 7 WHEN 3 THEN 8 WHEN 4 THEN 9 
                    WHEN 5 THEN 2 WHEN 6 THEN 3 WHEN 7 THEN 4 WHEN 8 THEN 5 
                    WHEN 9 THEN 6 WHEN 10 THEN 7 WHEN 11 THEN 8 WHEN 12 THEN 9 
                    WHEN 13 THEN 2 
                END;
    END LOOP;
    
    resto := soma % 11;
    dv2 := CASE WHEN resto < 2 THEN 0 ELSE 11 - resto END;
    
    -- Verifica segundo dígito
    RETURN dv2 = CAST(SUBSTRING(cnpj_numeros FROM 14 FOR 1) AS INTEGER);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS NAS TABELAS
-- =====================================================
COMMENT ON TABLE usuarios IS 'Tabela de usuários do sistema com controle de acesso';
COMMENT ON TABLE configuracoes IS 'Configurações gerais do sistema';
COMMENT ON TABLE bancos IS 'Cadastro de bancos e suas configurações';
COMMENT ON TABLE remessas IS 'Registro de todas as remessas enviadas e retornos processados';
COMMENT ON TABLE registros_remessa IS 'Detalhamento linha a linha das remessas';
COMMENT ON TABLE integracao_nasajon IS 'Log de integração com a API NASAJON';
COMMENT ON TABLE logs_auditoria IS 'Log completo de auditoria do sistema';
COMMENT ON TABLE notificacoes IS 'Sistema de notificações do sistema';
COMMENT ON TABLE arquivos IS 'Controle de arquivos com backup e versionamento';
COMMENT ON TABLE sessoes_usuario IS 'Controle de sessões ativas dos usuários';
COMMENT ON TABLE parametros_bancarios IS 'Parâmetros específicos por banco';

COMMENT ON COLUMN remessas.metadados IS 'Dados adicionais em formato JSON';
COMMENT ON COLUMN registros_remessa.conteudo_processado IS 'Dados processados do registro em formato JSON';
COMMENT ON COLUMN integracao_nasajon.payload_enviado IS 'Dados enviados para NASAJON em formato JSON';
COMMENT ON COLUMN integracao_nasajon.resposta_recebida IS 'Resposta recebida do NASAJON em formato JSON';

-- =====================================================
-- PERMISSÕES E SEGURANÇA
-- =====================================================

-- Criar role para aplicação
-- CREATE ROLE nasajon_app_role;

-- Conceder permissões básicas
-- GRANT USAGE ON SCHEMA nasajon_banking TO nasajon_app_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA nasajon_banking TO nasajon_app_role;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA nasajon_banking TO nasajon_app_role;

-- Criar usuário da aplicação
-- CREATE USER nasajon_app_user WITH PASSWORD 'senha_segura_aqui';
-- GRANT nasajon_app_role TO nasajon_app_user;

COMMIT;
