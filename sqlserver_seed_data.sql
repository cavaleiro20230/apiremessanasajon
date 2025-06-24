-- Script de dados iniciais para SQL Server - Sistema NASAJON Banking
-- Execute após a criação das tabelas

-- =====================================================
-- INSERIR USUÁRIO ADMINISTRADOR PADRÃO
-- =====================================================
INSERT INTO usuarios (username, email, password_hash, nome_completo, perfil, ativo) VALUES
('admin', 'admin@nasajon.com.br', HASHBYTES('SHA2_256', 'admin123'), 'Administrador do Sistema', 'admin', 1),
('operador', 'operador@nasajon.com.br', HASHBYTES('SHA2_256', 'oper123'), 'Operador Bancário', 'operador', 1),
('usuario', 'usuario@nasajon.com.br', HASHBYTES('SHA2_256', 'user123'), 'Usuário Padrão', 'usuario', 1);

-- =====================================================
-- CONFIGURAÇÕES PADRÃO DO SISTEMA
-- =====================================================
INSERT INTO configuracoes (chave, valor, descricao, tipo, categoria, editavel) VALUES
-- Configurações NASAJON
('nasajon_url', 'https://api.nasajon.com.br/v1', 'URL da API do NASAJON', 'string', 'nasajon', 1),
('nasajon_username', 'sistema_bancario', 'Usuário para autenticação NASAJON', 'string', 'nasajon', 1),
('nasajon_password', 'senha_criptografada', 'Senha para autenticação NASAJON', 'string', 'nasajon', 1),
('nasajon_timeout', '30', 'Timeout em segundos para requisições NASAJON', 'number', 'nasajon', 1),
('nasajon_retry_attempts', '3', 'Número de tentativas em caso de erro', 'number', 'nasajon', 1),

-- Configurações de Arquivos
('diretorio_arquivos', 'C:\NasajonBanking\Arquivos', 'Diretório para armazenar arquivos', 'string', 'arquivos', 1),
('diretorio_backup', 'C:\NasajonBanking\Backup', 'Diretório para backup dos arquivos', 'string', 'arquivos', 1),
('backup_automatico', 'true', 'Realizar backup automático dos arquivos', 'boolean', 'arquivos', 1),
('compressao_arquivos', 'true', 'Comprimir arquivos de backup', 'boolean', 'arquivos', 1),
('criptografia_arquivos', 'true', 'Criptografar arquivos sensíveis', 'boolean', 'arquivos', 1),
('retencao_backup_dias', '90', 'Dias para retenção de backup', 'number', 'arquivos', 1),

-- Configurações de Notificação
('notificacao_email_ativo', 'true', 'Ativar notificações por email', 'boolean', 'notificacao', 1),
('notificacao_email_servidor', 'smtp.gmail.com', 'Servidor SMTP para envio de emails', 'string', 'notificacao', 1),
('notificacao_email_porta', '587', 'Porta do servidor SMTP', 'number', 'notificacao', 1),
('notificacao_email_usuario', 'sistema@empresa.com', 'Usuário para autenticação SMTP', 'string', 'notificacao', 1),
('notificacao_email_senha', 'senha_email', 'Senha para autenticação SMTP', 'string', 'notificacao', 1),
('notificacao_email_destinatario', 'admin@empresa.com', 'Email padrão para notificações', 'string', 'notificacao', 1),

-- Configurações de Segurança
('sessao_timeout_minutos', '30', 'Timeout da sessão em minutos', 'number', 'seguranca', 1),
('max_tentativas_login', '3', 'Máximo de tentativas de login', 'number', 'seguranca', 1),
('bloqueio_login_minutos', '15', 'Tempo de bloqueio após tentativas excedidas', 'number', 'seguranca', 1),
('log_auditoria_ativo', 'true', 'Ativar log de auditoria', 'boolean', 'seguranca', 0),
('criptografia_senhas', 'true', 'Usar criptografia para senhas', 'boolean', 'seguranca', 0),

-- Configurações de Processamento
('max_registros_remessa', '10000', 'Máximo de registros por remessa', 'number', 'processamento', 1),
('max_valor_remessa', '10000000.00', 'Valor máximo por remessa', 'number', 'processamento', 1),
('validacao_cnab_rigorosa', 'true', 'Validação rigorosa do formato CNAB', 'boolean', 'processamento', 1),
('processamento_paralelo', 'true', 'Processar remessas em paralelo', 'boolean', 'processamento', 1),
('max_threads_processamento', '4', 'Máximo de threads para processamento', 'number', 'processamento', 1),

-- Configurações de Sistema
('versao_sistema', '1.0.0', 'Versão atual do sistema', 'string', 'sistema', 0),
('ambiente', 'producao', 'Ambiente de execução (desenvolvimento/homologacao/producao)', 'string', 'sistema', 1),
('debug_ativo', 'false', 'Ativar modo debug', 'boolean', 'sistema', 1),
('manutencao_ativo', 'false', 'Sistema em manutenção', 'boolean', 'sistema', 1);

-- =====================================================
-- BANCOS PADRÃO
-- =====================================================
INSERT INTO bancos (codigo, nome, nome_completo, layout_remessa, layout_retorno, ativo) VALUES
('001', 'Banco do Brasil', 'Banco do Brasil S.A.', 'CNAB240', 'CNAB240', 1),
('033', 'Santander', 'Banco Santander (Brasil) S.A.', 'CNAB240', 'CNAB240', 1),
('104', 'Caixa', 'Caixa Econômica Federal', 'CNAB240', 'CNAB240', 1),
('237', 'Bradesco', 'Banco Bradesco S.A.', 'CNAB240', 'CNAB240', 1),
('341', 'Itaú', 'Itaú Unibanco S.A.', 'CNAB240', 'CNAB240', 1),
('748', 'Sicredi', 'Banco Cooperativo Sicredi S.A.', 'CNAB240', 'CNAB240', 1),
('756', 'Sicoob', 'Banco Cooperativo do Brasil S.A.', 'CNAB240', 'CNAB240', 1),
('077', 'Inter', 'Banco Inter S.A.', 'CNAB240', 'CNAB240', 1),
('212', 'Banco Original', 'Banco Original S.A.', 'CNAB240', 'CNAB240', 1),
('260', 'Nu Pagamentos', 'Nu Pagamentos S.A.', 'CNAB240', 'CNAB240', 1);

-- =====================================================
-- PARÂMETROS ESPECÍFICOS DOS BANCOS
-- =====================================================

-- Parâmetros Banco do Brasil
INSERT INTO parametros_bancarios (banco_id, parametro, valor, descricao, obrigatorio, tipo_dado) 
SELECT b.id, 'convenio', '123456', 'Número do convênio com o banco', 1, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'carteira', '17', 'Código da carteira de cobrança', 1, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'variacao_carteira', '019', 'Variação da carteira', 0, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'cedente', 'EMPRESA EXEMPLO LTDA', 'Nome do cedente', 1, 'string'
FROM bancos b WHERE b.codigo = '001'
UNION ALL
SELECT b.id, 'cnpj_cedente', '12.345.678/0001-90', 'CNPJ do cedente', 1, 'string'
FROM bancos b WHERE b.codigo = '001';

-- Parâmetros Santander
INSERT INTO parametros_bancarios (banco_id, parametro, valor, descricao, obrigatorio, tipo_dado) 
SELECT b.id, 'convenio', '654321', 'Número do convênio com o banco', 1, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'carteira', '101', 'Código da carteira de cobrança', 1, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'cedente', 'EMPRESA EXEMPLO LTDA', 'Nome do cedente', 1, 'string'
FROM bancos b WHERE b.codigo = '033'
UNION ALL
SELECT b.id, 'cnpj_cedente', '12.345.678/0001-90', 'CNPJ do cedente', 1, 'string'
FROM bancos b WHERE b.codigo = '033';

-- =====================================================
-- REMESSAS DE EXEMPLO
-- =====================================================
DECLARE @admin_id UNIQUEIDENTIFIER = (SELECT id FROM usuarios WHERE username = 'admin');
DECLARE @operador_id UNIQUEIDENTIFIER = (SELECT id FROM usuarios WHERE username = 'operador');
DECLARE @santander_id UNIQUEIDENTIFIER = (SELECT id FROM bancos WHERE codigo = '033');
DECLARE @bb_id UNIQUEIDENTIFIER = (SELECT id FROM bancos WHERE codigo = '001');

INSERT INTO remessas (codigo, banco_id, tipo, subtipo, status, arquivo_nome, valor_total, quantidade_registros, data_vencimento, protocolo_banco, data_envio, data_processamento, usuario_criacao) VALUES
('REM000001', @santander_id, 'envio', 'cobranca', 'processada', 'remessa_santander_20240115.rem', 125000.50, 45, '2024-01-20', 'SANT1705334400', '2024-01-15 14:30:00', '2024-01-15 14:35:00', @admin_id),
('REM000002', @bb_id, 'envio', 'cobranca', 'enviada', 'remessa_bb_20240115.rem', 89500.75, 32, '2024-01-22', 'BB1705338000', '2024-01-15 15:45:00', NULL, @operador_id),
('RET000001', @santander_id, 'retorno', 'cobranca', 'processada', 'retorno_santander_20240115.ret', 67800.25, 28, NULL, 'SANT1705341600', NULL, '2024-01-15 16:20:00', @admin_id);

-- =====================================================
-- REGISTROS DE EXEMPLO PARA AS REMESSAS
-- =====================================================
DECLARE @remessa1_id UNIQUEIDENTIFIER = (SELECT id FROM remessas WHERE codigo = 'REM000001');

INSERT INTO registros_remessa (remessa_id, numero_linha, tipo_registro, codigo_segmento, conteudo_original, valor, nosso_numero, seu_numero, cpf_cnpj_pagador, nome_pagador, data_vencimento, status) VALUES
(@remessa1_id, 1, 'T', 'T', '03300000001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890', 2500.00, '12345678901', 'DOC001', '12345678901', 'CLIENTE EXEMPLO 1', '2024-01-20', 'processado'),
(@remessa1_id, 2, 'T', 'T', '03300000001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890', 1800.75, '12345678902', 'DOC002', '98765432100', 'CLIENTE EXEMPLO 2', '2024-01-20', 'processado');

-- =====================================================
-- LOGS DE AUDITORIA DE EXEMPLO
-- =====================================================
INSERT INTO logs_auditoria (usuario_id, usuario_nome, acao, tabela, registro_id, dados_novos, ip_address, modulo, nivel) VALUES
(@admin_id, 'Administrador do Sistema', 'INSERT', 'remessas', @remessa1_id, '{"codigo":"REM000001","status":"criada"}', '192.168.1.100', 'remessas', 'INFO'),
(@admin_id, 'Administrador do Sistema', 'UPDATE', 'remessas', @remessa1_id, '{"status":"processada"}', '192.168.1.101', 'remessas', 'INFO');

-- =====================================================
-- NOTIFICAÇÕES DE EXEMPLO
-- =====================================================
INSERT INTO notificacoes (tipo, titulo, mensagem, destinatario, canal, prioridade, enviada, data_envio) VALUES
('remessa_enviada', 'Remessa REM000001 enviada com sucesso', 'A remessa REM000001 foi enviada com sucesso para o Santander com 45 registros no valor total de R$ 125.000,50', 'admin@empresa.com', 'email', 'normal', 1, '2024-01-15 14:30:00'),
('retorno_processado', 'Retorno processado com sucesso', 'Retorno do Santander processado com 28 registros no valor total de R$ 67.800,25', 'admin@empresa.com', 'email', 'normal', 1, '2024-01-15 16:20:00'),
('remessa_pendente', 'Remessa REM000002 aguardando processamento', 'A remessa REM000002 do Banco do Brasil está aguardando processamento há mais de 2 horas', 'operador@empresa.com', 'email', 'alta', 1, '2024-01-15 17:50:00');

-- =====================================================
-- INTEGRAÇÃO NASAJON DE EXEMPLO
-- =====================================================
INSERT INTO integracao_nasajon (remessa_id, tipo_operacao, endpoint, metodo, payload_enviado, resposta_recebida, status_http, status, tempo_resposta_ms, data_envio, data_resposta) VALUES
(@remessa1_id, 'envio_remessa', '/api/remessas', 'POST', '{"remessa_id":"REM000001","banco_codigo":"033","valor_total":125000.50}', '{"success":true,"protocolo":"SANT1705334400","status":"processada"}', 200, 'sucesso', 1250, '2024-01-15 14:30:00', '2024-01-15 14:30:01');

-- =====================================================
-- VERIFICAR DADOS INSERIDOS
-- =====================================================
DECLARE @total_usuarios INT = (SELECT COUNT(*) FROM usuarios);
DECLARE @total_bancos INT = (SELECT COUNT(*) FROM bancos);
DECLARE @total_remessas INT = (SELECT COUNT(*) FROM remessas);
DECLARE @total_configuracoes INT = (SELECT COUNT(*) FROM configuracoes);

PRINT 'Dados inseridos com sucesso:';
PRINT '- Usuários: ' + CAST(@total_usuarios AS NVARCHAR);
PRINT '- Bancos: ' + CAST(@total_bancos AS NVARCHAR);
PRINT '- Remessas: ' + CAST(@total_remessas AS NVARCHAR);
PRINT '- Configurações: ' + CAST(@total_configuracoes AS NVARCHAR);
