-- Script de dados iniciais para PostgreSQL - Sistema NASAJON Banking
-- Execute após a criação das tabelas

SET search_path TO nasajon_banking, public;

-- =====================================================
-- INSERIR USUÁRIO ADMINISTRADOR PADRÃO
-- =====================================================
INSERT INTO usuarios (id, username, email, password_hash, nome_completo, perfil, ativo) VALUES
(uuid_generate_v4(), 'admin', 'admin@nasajon.com.br', crypt('admin123', gen_salt('bf')), 'Administrador do Sistema', 'admin', true),
(uuid_generate_v4(), 'operador', 'operador@nasajon.com.br', crypt('oper123', gen_salt('bf')), 'Operador Bancário', 'operador', true),
(uuid_generate_v4(), 'usuario', 'usuario@nasajon.com.br', crypt('user123', gen_salt('bf')), 'Usuário Padrão', 'usuario', true)
ON CONFLICT (username) DO NOTHING;

-- =====================================================
-- CONFIGURAÇÕES PADRÃO DO SISTEMA
-- =====================================================
INSERT INTO configuracoes (chave, valor, descricao, tipo, categoria, editavel) VALUES
-- Configurações NASAJON
('nasajon_url', 'https://api.nasajon.com.br/v1', 'URL da API do NASAJON', 'string', 'nasajon', true),
('nasajon_username', 'sistema_bancario', 'Usuário para autenticação NASAJON', 'string', 'nasajon', true),
('nasajon_password', 'senha_criptografada', 'Senha para autenticação NASAJON', 'string', 'nasajon', true),
('nasajon_timeout', '30', 'Timeout em segundos para requisições NASAJON', 'number', 'nasajon', true),
('nasajon_retry_attempts', '3', 'Número de tentativas em caso de erro', 'number', 'nasajon', true),

-- Configurações de Arquivos
('diretorio_arquivos', '/opt/nasajon/arquivos', 'Diretório para armazenar arquivos', 'string', 'arquivos', true),
('diretorio_backup', '/opt/nasajon/backup', 'Diretório para backup dos arquivos', 'string', 'arquivos', true),
('backup_automatico', 'true', 'Realizar backup automático dos arquivos', 'boolean', 'arquivos', true),
('compressao_arquivos', 'true', 'Comprimir arquivos de backup', 'boolean', 'arquivos', true),
('criptografia_arquivos', 'true', 'Criptografar arquivos sensíveis', 'boolean', 'arquivos', true),
('retencao_backup_dias', '90', 'Dias para retenção de backup', 'number', 'arquivos', true),

-- Configurações de Notificação
('notificacao_email_ativo', 'true', 'Ativar notificações por email', 'boolean', 'notificacao', true),
('notificacao_email_servidor', 'smtp.gmail.com', 'Servidor SMTP para envio de emails', 'string', 'notificacao', true),
('notificacao_email_porta', '587', 'Porta do servidor SMTP', 'number', 'notificacao', true),
('notificacao_email_usuario', 'sistema@empresa.com', 'Usuário para autenticação SMTP', 'string', 'notificacao', true),
('notificacao_email_senha', 'senha_email', 'Senha para autenticação SMTP', 'string', 'notificacao', true),
('notificacao_email_destinatario', 'admin@empresa.com', 'Email padrão para notificações', 'string', 'notificacao', true),

-- Configurações de Segurança
('sessao_timeout_minutos', '30', 'Timeout da sessão em minutos', 'number', 'seguranca', true),
('max_tentativas_login', '3', 'Máximo de tentativas de login', 'number', 'seguranca', true),
('bloqueio_login_minutos', '15', 'Tempo de bloqueio após tentativas excedidas', 'number', 'seguranca', true),
('log_auditoria_ativo', 'true', 'Ativar log de auditoria', 'boolean', 'seguranca', false),
('criptografia_senhas', 'true', 'Usar criptografia para senhas', 'boolean', 'seguranca', false),

-- Configurações de Processamento
('max_registros_remessa', '10000', 'Máximo de registros por remessa', 'number', 'processamento', true),
('max_valor_remessa', '10000000.00', 'Valor máximo por remessa', 'number', 'processamento', true),
('validacao_cnab_rigorosa', 'true', 'Validação rigorosa do formato CNAB', 'boolean', 'processamento', true),
('processamento_paralelo', 'true', 'Processar remessas em paralelo', 'boolean', 'processamento', true),
('max_threads_processamento', '4', 'Máximo de threads para processamento', 'number', 'processamento', true),

-- Configurações de Sistema
('versao_sistema', '1.0.0', 'Versão atual do sistema', 'string', 'sistema', false),
('ambiente', 'producao', 'Ambiente de execução (desenvolvimento/homologacao/producao)', 'string', 'sistema', true),
('debug_ativo', 'false', 'Ativar modo debug', 'boolean', 'sistema', true),
('manutencao_ativo', 'false', 'Sistema em manutenção', 'boolean', 'sistema', true)

ON CONFLICT (chave) DO NOTHING;

-- =====================================================
-- BANCOS PADRÃO
-- =====================================================
INSERT INTO bancos (codigo, nome, nome_completo, layout_remessa, layout_retorno, ativo) VALUES
('001', 'Banco do Brasil', 'Banco do Brasil S.A.', 'CNAB240', 'CNAB240', true),
('033', 'Santander', 'Banco Santander (Brasil) S.A.', 'CNAB240', 'CNAB240', true),
('104', 'Caixa', 'Caixa Econômica Federal', 'CNAB240', 'CNAB240', true),
('237', 'Bradesco', 'Banco Bradesco S.A.', 'CNAB240', 'CNAB240', true),
('341', 'Itaú', 'Itaú Unibanco S.A.', 'CNAB240', 'CNAB240', true),
('748', 'Sicredi', 'Banco Cooperativo Sicredi S.A.', 'CNAB240', 'CNAB240', true),
('756', 'Sicoob', 'Banco Cooperativo do Brasil S.A.', 'CNAB240', 'CNAB240', true),
('077', 'Inter', 'Banco Inter S.A.', 'CNAB240', 'CNAB240', true),
('212', 'Banco Original', 'Banco Original S.A.', 'CNAB240', 'CNAB240', true),
('260', 'Nu Pagamentos', 'Nu Pagamentos S.A.', 'CNAB240', 'CNAB240', true)
ON CONFLICT (codigo) DO NOTHING;

-- =====================================================
-- PARÂMETROS ESPECÍFICOS DOS BANCOS
-- =====================================================

-- Parâmetros Banco do Brasil
INSERT INTO parametros_bancarios (banco_id, parametro, valor, descricao, obrigatorio, tipo_dado) 
SELECT b.id, 'convenio', '123456', 'Número do convênio com o banco', true, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'carteira', '17', 'Código da carteira de cobrança', true, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'variacao_carteira', '019', 'Variação da carteira', false, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'cedente', 'EMPRESA EXEMPLO LTDA', 'Nome do cedente', true, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'cnpj_cedente', '12.345.678/0001-90', 'CNPJ do cedente', true, 'string'
FROM bancos b WHERE b.codigo = '001';

-- Parâmetros Santander
INSERT INTO parametros_bancarios (banco_id, parametro, valor, descricao, obrigatorio, tipo_dado) 
SELECT b.id, 'convenio', '654321', 'Número do convênio com o banco', true, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'carteira', '101', 'Código da carteira de cobrança', true, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'cedente', 'EMPRESA EXEMPLO LTDA', 'Nome do cedente', true, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'cnpj_cedente', '12.345.678/0001-90', 'CNPJ do cedente', true, 'string'
FROM bancos b WHERE b.codigo = '033';

-- =====================================================
-- REMESSAS DE EXEMPLO
-- =====================================================
INSERT INTO remessas (codigo, banco_id, tipo, subtipo, status, arquivo_nome, valor_total, quantidade_registros, data_vencimento, protocolo_banco, data_envio, data_processamento, usuario_criacao) 
SELECT 
    'REM000001',
    b.id,
    'envio',
    'cobranca',
    'processada',
    'remessa_santander_20240115.rem',
    125000.50,
    45,
    '2024-01-20',
    'SANT1705334400',
    '2024-01-15 14:30:00',
    '2024-01-15 14:35:00',
    u.id
FROM bancos b, usuarios u 
WHERE b.codigo = '033' AND u.username = 'admin'
LIMIT 1;

INSERT INTO remessas (codigo, banco_id, tipo, subtipo, status, arquivo_nome, valor_total, quantidade_registros, data_vencimento, protocolo_banco, data_envio, usuario_criacao) 
SELECT 
    'REM000002',
    b.id,
    'envio',
    'cobranca',
    'enviada',
    'remessa_bb_20240115.rem',
    89500.75,
    32,
    '2024-01-22',
    'BB1705338000',
    '2024-01-15 15:45:00',
    u.id
FROM bancos b, usuarios u 
WHERE b.codigo = '001' AND u.username = 'operador'
LIMIT 1;

INSERT INTO remessas (codigo, banco_id, tipo, subtipo, status, arquivo_nome, valor_total, quantidade_registros, protocolo_banco, data_processamento, usuario_criacao) 
SELECT 
    'RET000001',
    b.id,
    'retorno',
    'cobranca',
    'processada',
    'retorno_santander_20240115.ret',
    67800.25,
    28,
    'SANT1705341600',
    '2024-01-15 16:20:00',
    u.id
FROM bancos b, usuarios u 
WHERE b.codigo = '033' AND u.username = 'admin'
LIMIT 1;

-- =====================================================
-- REGISTROS DE EXEMPLO PARA AS REMESSAS
-- =====================================================
INSERT INTO registros_remessa (remessa_id, numero_linha, tipo_registro, codigo_segmento, conteudo_original, valor, nosso_numero, seu_numero, cpf_cnpj_pagador, nome_pagador, data_vencimento, status)
SELECT 
    r.id,
    1,
    'T',
    'T',
    '03300000001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',
    2500.00,
    '12345678901',
    'DOC001',
    '12345678901',
    'CLIENTE EXEMPLO 1',
    '2024-01-20',
    'processado'
FROM remessas r WHERE r.codigo = 'REM000001'
UNION ALL
SELECT 
    r.id,
    2,
    'T',
    'T',
    '03300000001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',
    1800.75,
    '12345678902',
    'DOC002',
    '98765432100',
    'CLIENTE EXEMPLO 2',
    '2024-01-20',
    'processado'
FROM remessas r WHERE r.codigo = 'REM000001';

-- =====================================================
-- LOGS DE AUDITORIA DE EXEMPLO
-- =====================================================
INSERT INTO logs_auditoria (usuario_id, usuario_nome, acao, tabela, registro_id, dados_novos, ip_address, modulo, nivel)
SELECT 
    u.id,
    u.nome_completo,
    'INSERT',
    'remessas',
    r.id,
    jsonb_build_object('codigo', r.codigo, 'status', 'criada'),
    '192.168.1.100'::inet,
    'remessas',
    'INFO'
FROM usuarios u, remessas r 
WHERE u.username = 'admin' AND r.codigo = 'REM000001'
LIMIT 1;

INSERT INTO logs_auditoria (usuario_id, usuario_nome, acao, tabela, registro_id, dados_novos, ip_address, modulo, nivel)
SELECT 
    u.id,
    u.nome_completo,
    'UPDATE',
    'remessas',
    r.id,
    jsonb_build_object('status', 'processada'),
    '192.168.1.101'::inet,
    'remessas',
    'INFO'
FROM usuarios u, remessas r 
WHERE u.username = 'admin' AND r.codigo = 'REM000001'
LIMIT 1;

-- =====================================================
-- NOTIFICAÇÕES DE EXEMPLO
-- =====================================================
INSERT INTO notificacoes (tipo, titulo, mensagem, destinatario, canal, prioridade, enviada, data_envio) VALUES
('remessa_enviada', 'Remessa REM000001 enviada com sucesso', 'A remessa REM000001 foi enviada com sucesso para o Santander com 45 registros no valor total de R$ 125.000,50', 'admin@empresa.com', 'email', 'normal', true, '2024-01-15 14:30:00'),
('retorno_processado', 'Retorno processado com sucesso', 'Retorno do Santander processado com 28 registros no valor total de R$ 67.800,25', 'admin@empresa.com', 'email', 'normal', true, '2024-01-15 16:20:00'),
('remessa_pendente', 'Remessa REM000002 aguardando processamento', 'A remessa REM000002 do Banco do Brasil está aguardando processamento há mais de 2 horas', 'operador@empresa.com', 'email', 'alta', true, '2024-01-15 17:50:00');

-- =====================================================
-- INTEGRAÇÃO NASAJON DE EXEMPLO
-- =====================================================
INSERT INTO integracao_nasajon (remessa_id, tipo_operacao, endpoint, metodo, payload_enviado, resposta_recebida, status_http, status, tempo_resposta_ms, data_envio, data_resposta)
SELECT 
    r.id,
    'envio_remessa',
    '/api/remessas',
    'POST',
    jsonb_build_object('remessa_id', r.codigo, 'banco_codigo', '033', 'valor_total', r.valor_total),
    jsonb_build_object('success', true, 'protocolo', r.protocolo_banco, 'status', 'processada'),
    200,
    'sucesso',
    1250,
    '2024-01-15 14:30:00',
    '2024-01-15 14:30:01'
FROM remessas r WHERE r.codigo = 'REM000001'
LIMIT 1;

-- =====================================================
-- ATUALIZAR SEQUÊNCIAS (se necessário)
-- =====================================================
-- PostgreSQL com UUID não precisa de ajuste de sequências

-- =====================================================
-- VERIFICAR DADOS INSERIDOS
-- =====================================================
DO $$
DECLARE
    total_usuarios INTEGER;
    total_bancos INTEGER;
    total_remessas INTEGER;
    total_configuracoes INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    SELECT COUNT(*) INTO total_bancos FROM bancos;
    SELECT COUNT(*) INTO total_remessas FROM remessas;
    SELECT COUNT(*) INTO total_configuracoes FROM configuracoes;
    
    RAISE NOTICE 'Dados inseridos com sucesso:';
    RAISE NOTICE '- Usuários: %', total_usuarios;
    RAISE NOTICE '- Bancos: %', total_bancos;
    RAISE NOTICE '- Remessas: %', total_remessas;
    RAISE NOTICE '- Configurações: %', total_configuracoes;
END $$;

COMMIT;
