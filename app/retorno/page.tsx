"use client"

import type React from "react"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Download, Upload, FileText, CheckCircle, AlertCircle, Clock, Search, Filter } from "lucide-react"
import Link from "next/link"

interface RetornoProcessado {
  id: string
  banco: string
  dataProcessamento: string
  arquivo: string
  status: "processado" | "erro" | "pendente"
  registros: number
  valorTotal: number
  erros: number
}

export default function ProcessarRetorno() {
  const [arquivoRetorno, setArquivoRetorno] = useState<File | null>(null)
  const [processando, setProcessando] = useState(false)
  const [retornos] = useState<RetornoProcessado[]>([
    {
      id: "RET001",
      banco: "Santander",
      dataProcessamento: "2024-01-15 16:30",
      arquivo: "retorno_santander_150124.ret",
      status: "processado",
      registros: 145,
      valorTotal: 89500.75,
      erros: 0,
    },
    {
      id: "RET002",
      banco: "Banco do Brasil",
      dataProcessamento: "2024-01-15 14:20",
      arquivo: "retorno_bb_150124.ret",
      status: "erro",
      registros: 67,
      valorTotal: 45200.3,
      erros: 3,
    },
    {
      id: "RET003",
      banco: "Santander",
      dataProcessamento: "2024-01-15 12:15",
      arquivo: "retorno_santander_140124.ret",
      status: "processado",
      registros: 89,
      valorTotal: 125000.5,
      erros: 0,
    },
  ])

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      setArquivoRetorno(file)
    }
  }

  const processarRetorno = () => {
    if (!arquivoRetorno) return

    setProcessando(true)

    // Simular processamento
    setTimeout(() => {
      setProcessando(false)
      setArquivoRetorno(null)
      // Aqui seria feita a integração com a API
    }, 3000)
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "processado":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "erro":
        return <AlertCircle className="h-4 w-4 text-red-500" />
      case "pendente":
        return <Clock className="h-4 w-4 text-yellow-500" />
      default:
        return <Clock className="h-4 w-4 text-gray-500" />
    }
  }

  const getStatusBadge = (status: string) => {
    const variants = {
      processado: "default",
      erro: "destructive",
      pendente: "secondary",
    } as const

    return (
      <Badge variant={variants[status as keyof typeof variants] || "secondary"}>
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </Badge>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center space-x-4">
          <Link href="/">
            <Button variant="outline" size="sm">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Voltar
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Processar Retorno Bancário</h1>
            <p className="text-gray-600">Processe arquivos de retorno dos bancos</p>
          </div>
        </div>

        <Tabs defaultValue="processar" className="space-y-4">
          <TabsList className="bg-white">
            <TabsTrigger value="processar">Processar Novo</TabsTrigger>
            <TabsTrigger value="historico">Histórico</TabsTrigger>
          </TabsList>

          <TabsContent value="processar" className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Upload de Arquivo */}
              <div className="lg:col-span-2">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <Upload className="h-5 w-5 mr-2" />
                      Upload do Arquivo de Retorno
                    </CardTitle>
                    <CardDescription>Selecione o arquivo de retorno bancário para processamento</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                      <FileText className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                      <div className="space-y-2">
                        <Label htmlFor="arquivoRetorno" className="cursor-pointer">
                          <span className="text-blue-600 hover:text-blue-500 text-lg">
                            Clique para selecionar arquivo
                          </span>
                        </Label>
                        <Input
                          id="arquivoRetorno"
                          type="file"
                          accept=".ret,.txt"
                          onChange={handleFileUpload}
                          className="hidden"
                        />
                        <p className="text-gray-500">ou arraste o arquivo de retorno aqui</p>
                        <p className="text-xs text-gray-400">Formatos aceitos: .ret, .txt (máx. 50MB)</p>
                      </div>
                    </div>

                    {arquivoRetorno && (
                      <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <FileText className="h-6 w-6 text-blue-500" />
                          <div>
                            <p className="font-medium text-blue-900">{arquivoRetorno.name}</p>
                            <p className="text-sm text-blue-600">{(arquivoRetorno.size / 1024).toFixed(1)} KB</p>
                          </div>
                        </div>
                        <Badge variant="secondary">Pronto para processar</Badge>
                      </div>
                    )}

                    {processando && (
                      <div className="flex items-center justify-center p-6 bg-yellow-50 rounded-lg">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-yellow-600 mr-3"></div>
                        <span className="text-yellow-700">Processando arquivo de retorno...</span>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* Painel de Ações */}
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Ações</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <Button className="w-full" onClick={processarRetorno} disabled={!arquivoRetorno || processando}>
                      <Download className="h-4 w-4 mr-2" />
                      {processando ? "Processando..." : "Processar Retorno"}
                    </Button>

                    <Button variant="outline" className="w-full">
                      <FileText className="h-4 w-4 mr-2" />
                      Validar Formato
                    </Button>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Instruções</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2 text-sm text-gray-600">
                    <p>• Arquivos devem estar no formato CNAB 240/400</p>
                    <p>• Processamento pode levar alguns minutos</p>
                    <p>• Registros com erro serão destacados</p>
                    <p>• Backup automático é realizado</p>
                  </CardContent>
                </Card>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="historico" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle>Histórico de Retornos Processados</CardTitle>
                    <CardDescription>Últimos arquivos de retorno processados</CardDescription>
                  </div>
                  <div className="flex space-x-2">
                    <Button variant="outline" size="sm">
                      <Search className="h-4 w-4 mr-2" />
                      Buscar
                    </Button>
                    <Button variant="outline" size="sm">
                      <Filter className="h-4 w-4 mr-2" />
                      Filtrar
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {retornos.map((retorno) => (
                    <div
                      key={retorno.id}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50"
                    >
                      <div className="flex items-center space-x-4">
                        <div className="flex items-center space-x-2">{getStatusIcon(retorno.status)}</div>
                        <div>
                          <div className="font-medium">
                            {retorno.id} - {retorno.banco}
                          </div>
                          <div className="text-sm text-gray-500">{retorno.arquivo}</div>
                          <div className="text-xs text-gray-400">{retorno.dataProcessamento}</div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-6">
                        <div className="text-right">
                          <div className="font-medium">
                            R$ {retorno.valorTotal.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
                          </div>
                          <div className="text-sm text-gray-500">
                            {retorno.registros} registros
                            {retorno.erros > 0 && <span className="text-red-500 ml-2">• {retorno.erros} erros</span>}
                          </div>
                        </div>
                        {getStatusBadge(retorno.status)}
                        <div className="flex space-x-2">
                          <Button variant="outline" size="sm">
                            <Download className="h-4 w-4 mr-1" />
                            Baixar
                          </Button>
                          <Button variant="outline" size="sm">
                            <FileText className="h-4 w-4 mr-1" />
                            Detalhes
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
