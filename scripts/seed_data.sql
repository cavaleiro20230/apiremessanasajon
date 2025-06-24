-- Script para inserção de dados iniciais
-- Execute após a criação das tabelas

-- Inserir configurações padrão
INSERT INTO configuracoes (chave, valor, descricao) VALUES
('nasajon_url', 'https://api.nasajon.com.br/v1', 'URL da API do NASAJON'),
('nasajon_timeout', '30', 'Timeout em segundos para requisições'),
('backup_automatico', 'true', 'Realizar backup automático dos arquivos'),
('notificacao_email', 'admin@empresa.com', 'Email para notificações do sistema'),
('max_tentativas_envio', '3', 'Máximo de tentativas para envio de remessa'),
('diretorio_arquivos', '/opt/nasajon/arquivos', 'Diretório para armazenar arquivos')
ON CONFLICT (chave) DO NOTHING;

-- Inserir bancos padrão
INSERT INTO bancos (codigo, nome, agencia, conta, convenio, ativo) VALUES
('001', 'Banco do Brasil', '1234-5', '12345678-9', '789012', true),
('033', 'Santander', '5678', '987654321-0', '123456', true),
('104', 'Caixa Econômica Federal', '9012', '555666777-8', '456789', true),
('237', 'Bradesco', '3456', '111222333-4', '654321', true),
('341', 'Itaú', '7890', '444555666-7', '987654', true)
ON CONFLICT (codigo) DO NOTHING;

-- Inserir algumas remessas de exemplo
INSERT INTO remessas (codigo, banco_id, tipo, status, arquivo_nome, valor_total, quantidade_registros, data_vencimento, protocolo_banco, data_envio, data_processamento) VALUES
('REM001', 2, 'envio', 'processada', 'remessa_santander_20240115.rem', 125000.50, 45, '2024-01-20', 'SANT1705334400', '2024-01-15 14:30:00', '2024-01-15 14:35:00'),
('REM002', 1, 'envio', 'pendente', 'remessa_bb_20240115.rem', 89500.75, 32, '2024-01-22', 'BB1705338000', '2024-01-15 15:45:00', NULL),
('REM003', 2, 'retorno', 'processada', 'retorno_santander_20240115.ret', 67800.25, 28, NULL, 'SANT1705341600', NULL, '2024-01-15 16:20:00')
ON CONFLICT (codigo) DO NOTHING;

-- Inserir logs de auditoria de exemplo
INSERT INTO logs_auditoria (usuario, acao, tabela, registro_id, dados_novos, ip_address) VALUES
('sistema', 'CREATE', 'remessas', 1, '{"codigo": "REM001", "status": "criada"}', '192.168.1.100'),
('admin', 'UPDATE', 'remessas', 1, '{"status": "processada"}', '192.168.1.101'),
('sistema', 'CREATE', 'remessas', 2, '{"codigo": "REM002", "status": "criada"}', '192.168.1.100');

-- Inserir notificações de exemplo
INSERT INTO notificacoes (tipo, titulo, mensagem, destinatario, data_envio) VALUES
('remessa_enviada', 'Remessa REM001 enviada', 'A remessa REM001 foi enviada com sucesso para o Santander', 'admin@empresa.com', '2024-01-15 14:30:00'),
('retorno_processado', 'Retorno processado', 'Retorno do Santander processado com 28 registros', 'admin@empresa.com', '2024-01-15 16:20:00'),
('erro_processamento', 'Erro na remessa REM002', 'Erro no processamento da remessa REM002 - verificar arquivo', 'admin@empresa.com', '2024-01-15 15:50:00');
