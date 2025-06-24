-- Script para criação do banco de dados do sistema NASAJON Banking
-- Execute este script no seu servidor de banco de dados

-- Criação da tabela de configurações
CREATE TABLE IF NOT EXISTS configuracoes (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de bancos
CREATE TABLE IF NOT EXISTS bancos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    agencia VARCHAR(20),
    conta VARCHAR(30),
    convenio VARCHAR(50),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de remessas
CREATE TABLE IF NOT EXISTS remessas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    banco_id INTEGER REFERENCES bancos(id),
    tipo VARCHAR(20) NOT NULL, -- 'envio' ou 'retorno'
    status VARCHAR(20) NOT NULL DEFAULT 'pendente', -- 'pendente', 'processada', 'erro'
    arquivo_nome VARCHAR(255),
    arquivo_caminho TEXT,
    valor_total DECIMAL(15,2) DEFAULT 0,
    quantidade_registros INTEGER DEFAULT 0,
    observacoes TEXT,
    data_vencimento DATE,
    protocolo_banco VARCHAR(100),
    data_envio TIMESTAMP,
    data_processamento TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de registros de remessa
CREATE TABLE IF NOT EXISTS registros_remessa (
    id SERIAL PRIMARY KEY,
    remessa_id INTEGER REFERENCES remessas(id),
    numero_linha INTEGER,
    tipo_registro VARCHAR(10),
    conteudo TEXT,
    valor DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'pendente',
    erro_descricao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de logs de auditoria
CREATE TABLE IF NOT EXISTS logs_auditoria (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100),
    acao VARCHAR(100) NOT NULL,
    tabela VARCHAR(50),
    registro_id INTEGER,
    dados_anteriores JSONB,
    dados_novos JSONB,
    ip_address INET,
    user_agent TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de notificações
CREATE TABLE IF NOT EXISTS notificacoes (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensagem TEXT,
    destinatario VARCHAR(100),
    lida BOOLEAN DEFAULT false,
    data_envio TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_remessas_banco_id ON remessas(banco_id);
CREATE INDEX IF NOT EXISTS idx_remessas_status ON remessas(status);
CREATE INDEX IF NOT EXISTS idx_remessas_data_criacao ON remessas(data_criacao);
CREATE INDEX IF NOT EXISTS idx_registros_remessa_id ON registros_remessa(remessa_id);
CREATE INDEX IF NOT EXISTS idx_logs_auditoria_data ON logs_auditoria(data_criacao);
CREATE INDEX IF NOT EXISTS idx_notificacoes_destinatario ON notificacoes(destinatario);
