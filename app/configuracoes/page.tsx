"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, Save, TestTube, Building2, Database, Shield, Bell, CheckCircle, AlertCircle } from "lucide-react"
import Link from "next/link"

interface ConfigNasajon {
  url: string
  usuario: string
  senha: string
  timeout: string
  ativo: boolean
}

interface ConfigBanco {
  codigo: string
  nome: string
  agencia: string
  conta: string
  convenio: string
  ativo: boolean
}

export default function Configuracoes() {
  const [configNasajon, setConfigNasajon] = useState<ConfigNasajon>({
    url: "https://api.nasajon.com.br/v1",
    usuario: "sistema_bancario",
    senha: "••••••••",
    timeout: "30",
    ativo: true,
  })

  const [bancos, setBancos] = useState<ConfigBanco[]>([
    {
      codigo: "033",
      nome: "Santander",
      agencia: "1234",
      conta: "567890-1",
      convenio: "123456",
      ativo: true,
    },
    {
      codigo: "001",
      nome: "Banco do Brasil",
      agencia: "5678",
      conta: "123456-7",
      convenio: "789012",
      ativo: true,
    },
  ])

  const [testando, setTestando] = useState(false)
  const [testeResultado, setTesteResultado] = useState<{
    status: "sucesso" | "erro" | null
    mensagem: string
  }>({ status: null, mensagem: "" })

  const testarConexao = async () => {
    setTestando(true)
    setTesteResultado({ status: null, mensagem: "" })

    // Simular teste de conexão
    setTimeout(() => {
      setTestando(false)
      setTesteResultado({
        status: "sucesso",
        mensagem: "Conexão com NASAJON estabelecida com sucesso!",
      })
    }, 2000)
  }

  const salvarConfiguracoes = () => {
    // Simular salvamento
    console.log("Salvando configurações:", { configNasajon, bancos })
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link href="/">
              <Button variant="outline" size="sm">
                <ArrowLeft className="h-4 w-4 mr-2" />
                Voltar
              </Button>
            </Link>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Configurações do Sistema</h1>
              <p className="text-gray-600">Configure integrações e parâmetros do sistema</p>
            </div>
          </div>
          <Button onClick={salvarConfiguracoes} className="bg-green-600 hover:bg-green-700">
            <Save className="h-4 w-4 mr-2" />
            Salvar Configurações
          </Button>
        </div>

        <Tabs defaultValue="nasajon" className="space-y-4">
          <TabsList className="bg-white">
            <TabsTrigger value="nasajon">NASAJON</TabsTrigger>
            <TabsTrigger value="bancos">Bancos</TabsTrigger>
            <TabsTrigger value="notificacoes">Notificações</TabsTrigger>
            <TabsTrigger value="seguranca">Segurança</TabsTrigger>
          </TabsList>

          <TabsContent value="nasajon" className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <Database className="h-5 w-5 mr-2" />
                      Configuração NASAJON
                    </CardTitle>
                    <CardDescription>Configure a conexão com o sistema NASAJON</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="url">URL da API</Label>
                      <Input
                        id="url"
                        value={configNasajon.url}
                        onChange={(e) => setConfigNasajon((prev) => ({ ...prev, url: e.target.value }))}
                        placeholder="https://api.nasajon.com.br/v1"
                      />
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="usuario">Usuário</Label>
                        <Input
                          id="usuario"
                          value={configNasajon.usuario}
                          onChange={(e) => setConfigNasajon((prev) => ({ ...prev, usuario: e.target.value }))}
                        />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="senha">Senha</Label>
                        <Input
                          id="senha"
                          type="password"
                          value={configNasajon.senha}
                          onChange={(e) => setConfigNasajon((prev) => ({ ...prev, senha: e.target.value }))}
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="timeout">Timeout (segundos)</Label>
                        <Input
                          id="timeout"
                          value={configNasajon.timeout}
                          onChange={(e) => setConfigNasajon((prev) => ({ ...prev, timeout: e.target.value }))}
                        />
                      </div>

                      <div className="flex items-center space-x-2 pt-6">
                        <Switch
                          id="ativo"
                          checked={configNasajon.ativo}
                          onCheckedChange={(checked) => setConfigNasajon((prev) => ({ ...prev, ativo: checked }))}
                        />
                        <Label htmlFor="ativo">Integração ativa</Label>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>

              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Teste de Conexão</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <Button onClick={testarConexao} disabled={testando} className="w-full" variant="outline">
                      <TestTube className="h-4 w-4 mr-2" />
                      {testando ? "Testando..." : "Testar Conexão"}
                    </Button>

                    {testando && (
                      <div className="flex items-center justify-center p-4">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                      </div>
                    )}

                    {testeResultado.status && (
                      <div
                        className={`flex items-center p-3 rounded-lg ${
                          testeResultado.status === "sucesso" ? "bg-green-50 text-green-700" : "bg-red-50 text-red-700"
                        }`}
                      >
                        {testeResultado.status === "sucesso" ? (
                          <CheckCircle className="h-5 w-5 mr-2" />
                        ) : (
                          <AlertCircle className="h-5 w-5 mr-2" />
                        )}
                        <span className="text-sm">{testeResultado.mensagem}</span>
                      </div>
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Status da Integração</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Status</span>
                      <Badge variant={configNasajon.ativo ? "default" : "secondary"}>
                        {configNasajon.ativo ? "Ativo" : "Inativo"}
                      </Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Última conexão</span>
                      <span className="text-sm text-gray-500">15/01/2024 16:30</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Versão da API</span>
                      <span className="text-sm text-gray-500">v1.2.3</span>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="bancos" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Building2 className="h-5 w-5 mr-2" />
                  Configuração dos Bancos
                </CardTitle>
                <CardDescription>Configure as informações dos bancos para remessas</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  {bancos.map((banco, index) => (
                    <div key={banco.codigo} className="p-4 border rounded-lg space-y-4">
                      <div className="flex items-center justify-between">
                        <h3 className="font-medium">
                          {banco.nome} ({banco.codigo})
                        </h3>
                        <Switch
                          checked={banco.ativo}
                          onCheckedChange={(checked) => {
                            const novosBancos = [...bancos]
                            novosBancos[index].ativo = checked
                            setBancos(novosBancos)
                          }}
                        />
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div className="space-y-2">
                          <Label>Agência</Label>
                          <Input
                            value={banco.agencia}
                            onChange={(e) => {
                              const novosBancos = [...bancos]
                              novosBancos[index].agencia = e.target.value
                              setBancos(novosBancos)
                            }}
                          />
                        </div>

                        <div className="space-y-2">
                          <Label>Conta</Label>
                          <Input
                            value={banco.conta}
                            onChange={(e) => {
                              const novosBancos = [...bancos]
                              novosBancos[index].conta = e.target.value
                              setBancos(novosBancos)
                            }}
                          />
                        </div>

                        <div className="space-y-2">
                          <Label>Convênio</Label>
                          <Input
                            value={banco.convenio}
                            onChange={(e) => {
                              const novosBancos = [...bancos]
                              novosBancos[index].convenio = e.target.value
                              setBancos(novosBancos)
                            }}
                          />
                        </div>
                      </div>
                    </div>
                  ))}

                  <Button variant="outline" className="w-full">
                    <Building2 className="h-4 w-4 mr-2" />
                    Adicionar Novo Banco
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="notificacoes" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Bell className="h-5 w-5 mr-2" />
                  Configurações de Notificações
                </CardTitle>
                <CardDescription>Configure quando e como receber notificações</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Remessa enviada com sucesso</Label>
                      <p className="text-sm text-gray-500">Notificar quando uma remessa for enviada</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Retorno processado</Label>
                      <p className="text-sm text-gray-500">Notificar quando um retorno for processado</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Erros de processamento</Label>
                      <p className="text-sm text-gray-500">Notificar quando houver erros</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Relatório diário</Label>
                      <p className="text-sm text-gray-500">Enviar resumo diário por email</p>
                    </div>
                    <Switch />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>Email para notificações</Label>
                  <Input placeholder="admin@empresa.com" />
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="seguranca" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Shield className="h-5 w-5 mr-2" />
                  Configurações de Segurança
                </CardTitle>
                <CardDescription>Configure parâmetros de segurança do sistema</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Autenticação de dois fatores</Label>
                      <p className="text-sm text-gray-500">Exigir 2FA para operações críticas</p>
                    </div>
                    <Switch />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Log de auditoria</Label>
                      <p className="text-sm text-gray-500">Registrar todas as operações</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label className="text-base">Criptografia de arquivos</Label>
                      <p className="text-sm text-gray-500">Criptografar arquivos de remessa</p>
                    </div>
                    <Switch defaultChecked />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Tempo limite de sessão (minutos)</Label>
                    <Input defaultValue="30" />
                  </div>

                  <div className="space-y-2">
                    <Label>Tentativas máximas de login</Label>
                    <Input defaultValue="3" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
