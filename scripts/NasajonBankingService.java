package com.nasajon.banking.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Serviço principal para integração com NASAJON e processamento de remessas bancárias
 * Compatível com JBoss Application Server
 */
@Service
public class NasajonBankingService {

    @Value("${nasajon.api.url}")
    private String nasajonApiUrl;

    @Value("${nasajon.api.username}")
    private String nasajonUsername;

    @Value("${nasajon.api.password}")
    private String nasajonPassword;

    @Value("${banking.files.directory}")
    private String filesDirectory;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private RemessaRepository remessaRepository;

    @Autowired
    private BancoRepository bancoRepository;

    /**
     * Envia remessa para o sistema NASAJON
     */
    public RemessaResponse enviarRemessa(RemessaRequest request, MultipartFile arquivo) {
        try {
            // Validar arquivo
            if (!validarArquivoRemessa(arquivo)) {
                throw new IllegalArgumentException("Arquivo de remessa inválido");
            }

            // Salvar arquivo no sistema de arquivos
            String caminhoArquivo = salvarArquivo(arquivo);

            // Criar registro da remessa no banco
            Remessa remessa = criarRemessa(request, caminhoArquivo);

            // Enviar para NASAJON
            NasajonResponse nasajonResponse = enviarParaNasajon(remessa, arquivo);

            // Atualizar status da remessa
            remessa.setStatus("enviada");
            remessa.setProtocoloBanco(nasajonResponse.getProtocolo());
            remessa.setDataEnvio(LocalDateTime.now());
            remessaRepository.save(remessa);

            // Enviar para o banco específico
            BancoResponse bancoResponse = enviarParaBanco(remessa, arquivo);

            return RemessaResponse.builder()
                    .success(true)
                    .remessaId(remessa.getCodigo())
                    .protocolo(bancoResponse.getProtocolo())
                    .status("processando")
                    .mensagem("Remessa enviada com sucesso")
                    .build();

        } catch (Exception e) {
            return RemessaResponse.builder()
                    .success(false)
                    .mensagem("Erro ao enviar remessa: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Processa arquivo de retorno bancário
     */
    public RetornoResponse processarRetorno(MultipartFile arquivo, String codigoBanco) {
        try {
            // Validar arquivo de retorno
            if (!validarArquivoRetorno(arquivo)) {
                throw new IllegalArgumentException("Arquivo de retorno inválido");
            }

            // Salvar arquivo
            String caminhoArquivo = salvarArquivo(arquivo);

            // Processar registros do arquivo
            RetornoProcessado resultado = processarRegistrosRetorno(caminhoArquivo, codigoBanco);

            // Atualizar registros no NASAJON
            atualizarNasajonComRetorno(resultado);

            // Criar registro de retorno
            Remessa retorno = criarRegistroRetorno(resultado, caminhoArquivo, codigoBanco);

            return RetornoResponse.builder()
                    .success(true)
                    .retornoId(retorno.getCodigo())
                    .registrosProcessados(resultado.getRegistrosProcessados())
                    .registrosComErro(resultado.getRegistrosComErro())
                    .valorTotal(resultado.getValorTotal())
                    .mensagem("Retorno processado com sucesso")
                    .build();

        } catch (Exception e) {
            return RetornoResponse.builder()
                    .success(false)
                    .mensagem("Erro ao processar retorno: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Consulta status de remessa no NASAJON
     */
    public StatusResponse consultarStatus(String remessaId) {
        try {
            HttpHeaders headers = criarHeadersAutenticacao();
            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = nasajonApiUrl + "/remessas/" + remessaId + "/status";
            ResponseEntity<Map> response = restTemplate.exchange(
                    url, HttpMethod.GET, entity, Map.class);

            Map<String, Object> responseBody = response.getBody();
            
            return StatusResponse.builder()
                    .success(true)
                    .status((String) responseBody.get("status"))
                    .detalhes((Map<String, Object>) responseBody.get("detalhes"))
                    .build();

        } catch (Exception e) {
            return StatusResponse.builder()
                    .success(false)
                    .mensagem("Erro ao consultar status: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Testa conexão com NASAJON
     */
    public ConexaoResponse testarConexao() {
        try {
            HttpHeaders headers = criarHeadersAutenticacao();
            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = nasajonApiUrl + "/health";
            ResponseEntity<Map> response = restTemplate.exchange(
                    url, HttpMethod.GET, entity, Map.class);

            return ConexaoResponse.builder()
                    .success(true)
                    .mensagem("Conexão estabelecida com sucesso")
                    .versaoApi((String) response.getBody().get("version"))
                    .timestamp(LocalDateTime.now())
                    .build();

        } catch (Exception e) {
            return ConexaoResponse.builder()
                    .success(false)
                    .mensagem("Erro na conexão: " + e.getMessage())
                    .build();
        }
    }

    // Métodos privados auxiliares

    private boolean validarArquivoRemessa(MultipartFile arquivo) {
        if (arquivo == null || arquivo.isEmpty()) {
            return false;
        }

        String nomeArquivo = arquivo.getOriginalFilename();
        if (nomeArquivo == null) {
            return false;
        }

        // Validar extensão
        return nomeArquivo.toLowerCase().endsWith(".rem") || 
               nomeArquivo.toLowerCase().endsWith(".txt");
    }

    private boolean validarArquivoRetorno(MultipartFile arquivo) {
        if (arquivo == null || arquivo.isEmpty()) {
            return false;
        }

        String nomeArquivo = arquivo.getOriginalFilename();
        if (nomeArquivo == null) {
            return false;
        }

        // Validar extensão
        return nomeArquivo.toLowerCase().endsWith(".ret") || 
               nomeArquivo.toLowerCase().endsWith(".txt");
    }

    private String salvarArquivo(MultipartFile arquivo) throws IOException {
        String nomeArquivo = System.currentTimeMillis() + "_" + arquivo.getOriginalFilename();
        Path caminho = Paths.get(filesDirectory, nomeArquivo);
        
        // Criar diretório se não existir
        Files.createDirectories(caminho.getParent());
        
        // Salvar arquivo
        Files.write(caminho, arquivo.getBytes());
        
        return caminho.toString();
    }

    private Remessa criarRemessa(RemessaRequest request, String caminhoArquivo) {
        Banco banco = bancoRepository.findByCodigo(request.getCodigoBanco())
                .orElseThrow(() -> new IllegalArgumentException("Banco não encontrado"));

        Remessa remessa = new Remessa();
        remessa.setCodigo("REM" + System.currentTimeMillis());
        remessa.setBanco(banco);
        remessa.setTipo("envio");
        remessa.setStatus("criada");
        remessa.setArquivoNome(request.getNomeArquivo());
        remessa.setArquivoCaminho(caminhoArquivo);
        remessa.setValorTotal(request.getValorTotal());
        remessa.setQuantidadeRegistros(request.getQuantidadeRegistros());
        remessa.setDataVencimento(request.getDataVencimento());
        remessa.setObservacoes(request.getObservacoes());
        remessa.setDataCriacao(LocalDateTime.now());

        return remessaRepository.save(remessa);
    }

    private NasajonResponse enviarParaNasajon(Remessa remessa, MultipartFile arquivo) {
        HttpHeaders headers = criarHeadersAutenticacao();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("action", "enviar_remessa");
        requestBody.put("data", Map.of(
                "remessa_id", remessa.getCodigo(),
                "banco_codigo", remessa.getBanco().getCodigo(),
                "valor_total", remessa.getValorTotal(),
                "quantidade", remessa.getQuantidadeRegistros()
        ));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        ResponseEntity<NasajonResponse> response = restTemplate.exchange(
                nasajonApiUrl + "/remessas", HttpMethod.POST, entity, NasajonResponse.class);

        return response.getBody();
    }

    private BancoResponse enviarParaBanco(Remessa remessa, MultipartFile arquivo) {
        String codigoBanco = remessa.getBanco().getCodigo();
        String url;

        // Determinar URL específica do banco
        switch (codigoBanco) {
            case "033":
                url = "/api/bancos/santander";
                break;
            case "001":
                url = "/api/bancos/bb";
                break;
            default:
                throw new IllegalArgumentException("Banco não suportado: " + codigoBanco);
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("tipo", "remessa_cobranca");
        requestBody.put("dados", Map.of(
                "quantidade", remessa.getQuantidadeRegistros(),
                "valor_total", remessa.getValorTotal(),
                "convenio", remessa.getBanco().getConvenio()
        ));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        ResponseEntity<BancoResponse> response = restTemplate.exchange(
                url, HttpMethod.POST, entity, BancoResponse.class);

        return response.getBody();
    }

    private RetornoProcessado processarRegistrosRetorno(String caminhoArquivo, String codigoBanco) throws IOException {
        // Implementar lógica específica de processamento CNAB
        // Este é um exemplo simplificado
        
        byte[] conteudo = Files.readAllBytes(Paths.get(caminhoArquivo));
        String conteudoTexto = new String(conteudo);
        
        String[] linhas = conteudoTexto.split("\n");
        int registrosProcessados = 0;
        int registrosComErro = 0;
        double valorTotal = 0.0;

        for (String linha : linhas) {
            if (linha.trim().isEmpty()) continue;
            
            try {
                // Processar linha conforme layout CNAB
                // Exemplo simplificado
                if (linha.length() >= 240) { // CNAB 240
                    registrosProcessados++;
                    // Extrair valor (posições específicas conforme layout)
                    // valorTotal += extrairValor(linha);
                }
            } catch (Exception e) {
                registrosComErro++;
            }
        }

        return RetornoProcessado.builder()
                .registrosProcessados(registrosProcessados)
                .registrosComErro(registrosComErro)
                .valorTotal(valorTotal)
                .build();
    }

    private void atualizarNasajonComRetorno(RetornoProcessado resultado) {
        HttpHeaders headers = criarHeadersAutenticacao();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("action", "processar_retorno");
        requestBody.put("data", Map.of(
                "registros_processados", resultado.getRegistrosProcessados(),
                "registros_erro", resultado.getRegistrosComErro(),
                "valor_total", resultado.getValorTotal()
        ));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        restTemplate.exchange(nasajonApiUrl + "/retornos", HttpMethod.POST, entity, Map.class);
    }

    private Remessa criarRegistroRetorno(RetornoProcessado resultado, String caminhoArquivo, String codigoBanco) {
        Banco banco = bancoRepository.findByCodigo(codigoBanco)
                .orElseThrow(() -> new IllegalArgumentException("Banco não encontrado"));

        Remessa retorno = new Remessa();
        retorno.setCodigo("RET" + System.currentTimeMillis());
        retorno.setBanco(banco);
        retorno.setTipo("retorno");
        retorno.setStatus("processada");
        retorno.setArquivoCaminho(caminhoArquivo);
        retorno.setValorTotal(resultado.getValorTotal());
        retorno.setQuantidadeRegistros(resultado.getRegistrosProcessados());
        retorno.setDataProcessamento(LocalDateTime.now());
        retorno.setDataCriacao(LocalDateTime.now());

        return remessaRepository.save(retorno);
    }

    private HttpHeaders criarHeadersAutenticacao() {
        HttpHeaders headers = new HttpHeaders();
        
        // Implementar autenticação conforme API NASAJON
        // Exemplo com Basic Auth
        String auth = nasajonUsername + ":" + nasajonPassword;
        byte[] encodedAuth = java.util.Base64.getEncoder().encode(auth.getBytes());
        String authHeader = "Basic " + new String(encodedAuth);
        
        headers.set("Authorization", authHeader);
        headers.set("Content-Type", "application/json");
        
        return headers;
    }
}
