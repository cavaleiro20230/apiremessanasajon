"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Building2, Send, Download, AlertCircle, CheckCircle, Clock, FileText, Settings } from "lucide-react"

interface RemessaStats {
  total: number
  enviadas: number
  processadas: number
  pendentes: number
  erros: number
}

interface Remessa {
  id: string
  banco: string
  tipo: "envio" | "retorno"
  status: "pendente" | "processada" | "erro"
  dataHora: string
  valor: number
  quantidade: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<RemessaStats>({
    total: 0,
    enviadas: 0,
    processadas: 0,
    pendentes: 0,
    erros: 0,
  })

  const [remessas, setRemessas] = useState<Remessa[]>([])

  useEffect(() => {
    // Simular carregamento de dados
    setStats({
      total: 156,
      enviadas: 89,
      processadas: 45,
      pendentes: 15,
      erros: 7,
    })

    setRemessas([
      {
        id: "REM001",
        banco: "Santander",
        tipo: "envio",
        status: "processada",
        dataHora: "2024-01-15 14:30",
        valor: 125000.5,
        quantidade: 45,
      },
      {
        id: "REM002",
        banco: "Banco do Brasil",
        tipo: "retorno",
        status: "pendente",
        dataHora: "2024-01-15 15:45",
        valor: 89500.75,
        quantidade: 32,
      },
      {
        id: "REM003",
        banco: "Santander",
        tipo: "envio",
        status: "erro",
        dataHora: "2024-01-15 16:20",
        valor: 67800.25,
        quantidade: 28,
      },
    ])
  }, [])

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "processada":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "pendente":
        return <Clock className="h-4 w-4 text-yellow-500" />
      case "erro":
        return <AlertCircle className="h-4 w-4 text-red-500" />
      default:
        return <Clock className="h-4 w-4 text-gray-500" />
    }
  }

  const getStatusBadge = (status: string) => {
    const variants = {
      processada: "default",
      pendente: "secondary",
      erro: "destructive",
    } as const

    return (
      <Badge variant={variants[status as keyof typeof variants] || "secondary"}>
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </Badge>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Sistema NASAJON - Remessas Bancárias</h1>
            <p className="text-gray-600 mt-1">Gerenciamento de remessas Santander e Banco do Brasil</p>
          </div>
          <div className="flex gap-3">
            <Button variant="outline" className="bg-white">
              <Settings className="h-4 w-4 mr-2" />
              Configurações
            </Button>
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Send className="h-4 w-4 mr-2" />
              Nova Remessa
            </Button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
          <Card className="bg-white">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">Total de Remessas</CardTitle>
              <FileText className="h-4 w-4 text-gray-400" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-gray-900">{stats.total}</div>
              <p className="text-xs text-green-600 mt-1">+12% este mês</p>
            </CardContent>
          </Card>

          <Card className="bg-white">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">Enviadas</CardTitle>
              <Send className="h-4 w-4 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-blue-600">{stats.enviadas}</div>
              <p className="text-xs text-gray-500 mt-1">Últimas 24h</p>
            </CardContent>
          </Card>

          <Card className="bg-white">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">Processadas</CardTitle>
              <CheckCircle className="h-4 w-4 text-green-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">{stats.processadas}</div>
              <p className="text-xs text-gray-500 mt-1">Concluídas</p>
            </CardContent>
          </Card>

          <Card className="bg-white">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">Pendentes</CardTitle>
              <Clock className="h-4 w-4 text-yellow-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-yellow-600">{stats.pendentes}</div>
              <p className="text-xs text-gray-500 mt-1">Aguardando</p>
            </CardContent>
          </Card>

          <Card className="bg-white">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">Erros</CardTitle>
              <AlertCircle className="h-4 w-4 text-red-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-red-600">{stats.erros}</div>
              <p className="text-xs text-gray-500 mt-1">Requer atenção</p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content */}
        <Tabs defaultValue="remessas" className="space-y-4">
          <TabsList className="bg-white">
            <TabsTrigger value="remessas">Remessas Recentes</TabsTrigger>
            <TabsTrigger value="envio">Enviar Remessa</TabsTrigger>
            <TabsTrigger value="retorno">Processar Retorno</TabsTrigger>
            <TabsTrigger value="config">Configurações</TabsTrigger>
          </TabsList>

          <TabsContent value="remessas" className="space-y-4">
            <Card className="bg-white">
              <CardHeader>
                <CardTitle>Remessas Recentes</CardTitle>
                <CardDescription>Últimas remessas enviadas e retornos processados</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {remessas.map((remessa) => (
                    <div key={remessa.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center space-x-4">
                        <div className="flex items-center space-x-2">
                          {getStatusIcon(remessa.status)}
                          <Building2 className="h-4 w-4 text-gray-400" />
                        </div>
                        <div>
                          <div className="font-medium">
                            {remessa.id} - {remessa.banco}
                          </div>
                          <div className="text-sm text-gray-500">
                            {remessa.tipo === "envio" ? "Envio" : "Retorno"} • {remessa.dataHora}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-4">
                        <div className="text-right">
                          <div className="font-medium">
                            R$ {remessa.valor.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
                          </div>
                          <div className="text-sm text-gray-500">{remessa.quantidade} registros</div>
                        </div>
                        {getStatusBadge(remessa.status)}
                        <Button variant="outline" size="sm">
                          <Download className="h-4 w-4 mr-1" />
                          Baixar
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="envio">
            <Card className="bg-white">
              <CardHeader>
                <CardTitle>Enviar Nova Remessa</CardTitle>
                <CardDescription>Configure e envie uma nova remessa bancária</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-center py-8">
                  <Send className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">Funcionalidade de envio será implementada</p>
                  <Button className="mt-4">Acessar Formulário de Envio</Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="retorno">
            <Card className="bg-white">
              <CardHeader>
                <CardTitle>Processar Retorno</CardTitle>
                <CardDescription>Processe arquivos de retorno dos bancos</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-center py-8">
                  <Download className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">Funcionalidade de processamento será implementada</p>
                  <Button className="mt-4">Acessar Processamento</Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="config">
            <Card className="bg-white">
              <CardHeader>
                <CardTitle>Configurações do Sistema</CardTitle>
                <CardDescription>Configure parâmetros de integração com NASAJON e bancos</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-center py-8">
                  <Settings className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">Painel de configurações será implementado</p>
                  <Button className="mt-4">Acessar Configurações</Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
