"use client"

import type React from "react"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Checkbox } from "@/components/ui/checkbox"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, Send, Upload, FileText, AlertTriangle, CheckCircle, Building2 } from "lucide-react"
import Link from "next/link"

interface RemessaForm {
  banco: string
  tipoRemessa: string
  dataVencimento: string
  valorTotal: string
  quantidadeRegistros: string
  observacoes: string
  validarAntes: boolean
}

export default function EnvioRemessa() {
  const [form, setForm] = useState<RemessaForm>({
    banco: "",
    tipoRemessa: "",
    dataVencimento: "",
    valorTotal: "",
    quantidadeRegistros: "",
    observacoes: "",
    validarAntes: true,
  })

  const [arquivo, setArquivo] = useState<File | null>(null)
  const [validacao, setValidacao] = useState<{
    status: "idle" | "validando" | "sucesso" | "erro"
    mensagens: string[]
  }>({
    status: "idle",
    mensagens: [],
  })

  const handleInputChange = (field: keyof RemessaForm, value: string | boolean) => {
    setForm((prev) => ({ ...prev, [field]: value }))
  }

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      setArquivo(file)
      // Simular validação automática
      if (form.validarAntes) {
        validarArquivo(file)
      }
    }
  }

  const validarArquivo = (file: File) => {
    setValidacao({ status: "validando", mensagens: [] })

    // Simular validação
    setTimeout(() => {
      const mensagens = [
        "Formato do arquivo: CNAB 240 ✓",
        "Estrutura dos registros: Válida ✓",
        "Códigos de banco: Válidos ✓",
        "Total de registros: 150",
        "Valor total: R$ 125.450,75",
      ]

      setValidacao({
        status: "sucesso",
        mensagens,
      })
    }, 2000)
  }

  const enviarRemessa = () => {
    // Simular envio
    console.log("Enviando remessa:", { form, arquivo })
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center space-x-4">
          <Link href="/">
            <Button variant="outline" size="sm">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Voltar
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Enviar Nova Remessa</h1>
            <p className="text-gray-600">Configure e envie remessa bancária para processamento</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Formulário Principal */}
          <div className="lg:col-span-2 space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Building2 className="h-5 w-5 mr-2" />
                  Dados da Remessa
                </CardTitle>
                <CardDescription>Informe os dados básicos da remessa bancária</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="banco">Banco de Destino</Label>
                    <Select value={form.banco} onValueChange={(value) => handleInputChange("banco", value)}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o banco" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="santander">Santander (033)</SelectItem>
                        <SelectItem value="bb">Banco do Brasil (001)</SelectItem>
                        <SelectItem value="itau">Itaú (341)</SelectItem>
                        <SelectItem value="bradesco">Bradesco (237)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="tipoRemessa">Tipo de Remessa</Label>
                    <Select value={form.tipoRemessa} onValueChange={(value) => handleInputChange("tipoRemessa", value)}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o tipo" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="cobranca">Cobrança</SelectItem>
                        <SelectItem value="pagamento">Pagamento</SelectItem>
                        <SelectItem value="ted">TED</SelectItem>
                        <SelectItem value="doc">DOC</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="dataVencimento">Data de Vencimento</Label>
                    <Input
                      id="dataVencimento"
                      type="date"
                      value={form.dataVencimento}
                      onChange={(e) => handleInputChange("dataVencimento", e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="valorTotal">Valor Total (R$)</Label>
                    <Input
                      id="valorTotal"
                      placeholder="0,00"
                      value={form.valorTotal}
                      onChange={(e) => handleInputChange("valorTotal", e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="quantidadeRegistros">Qtd. Registros</Label>
                    <Input
                      id="quantidadeRegistros"
                      placeholder="0"
                      value={form.quantidadeRegistros}
                      onChange={(e) => handleInputChange("quantidadeRegistros", e.target.value)}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="observacoes">Observações</Label>
                  <Textarea
                    id="observacoes"
                    placeholder="Observações adicionais sobre a remessa..."
                    value={form.observacoes}
                    onChange={(e) => handleInputChange("observacoes", e.target.value)}
                    rows={3}
                  />
                </div>
              </CardContent>
            </Card>

            {/* Upload de Arquivo */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Upload className="h-5 w-5 mr-2" />
                  Arquivo da Remessa
                </CardTitle>
                <CardDescription>Faça upload do arquivo CNAB 240/400 da remessa</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <div className="space-y-2">
                    <Label htmlFor="arquivo" className="cursor-pointer">
                      <span className="text-blue-600 hover:text-blue-500">Clique para selecionar</span>
                      <span className="text-gray-500"> ou arraste o arquivo aqui</span>
                    </Label>
                    <Input
                      id="arquivo"
                      type="file"
                      accept=".txt,.rem,.ret"
                      onChange={handleFileUpload}
                      className="hidden"
                    />
                    <p className="text-xs text-gray-500">Formatos aceitos: .txt, .rem, .ret (máx. 10MB)</p>
                  </div>
                </div>

                {arquivo && (
                  <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                    <div className="flex items-center space-x-3">
                      <FileText className="h-5 w-5 text-blue-500" />
                      <div>
                        <p className="font-medium text-blue-900">{arquivo.name}</p>
                        <p className="text-sm text-blue-600">{(arquivo.size / 1024).toFixed(1)} KB</p>
                      </div>
                    </div>
                    <Badge variant="secondary">Carregado</Badge>
                  </div>
                )}

                <div className="flex items-center space-x-2">
                  <Checkbox
                    id="validarAntes"
                    checked={form.validarAntes}
                    onCheckedChange={(checked) => handleInputChange("validarAntes", checked as boolean)}
                  />
                  <Label htmlFor="validarAntes" className="text-sm">
                    Validar arquivo antes do envio
                  </Label>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Painel Lateral */}
          <div className="space-y-6">
            {/* Status da Validação */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Status da Validação</CardTitle>
              </CardHeader>
              <CardContent>
                {validacao.status === "idle" && (
                  <div className="text-center py-4">
                    <AlertTriangle className="h-8 w-8 text-gray-400 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">Aguardando arquivo</p>
                  </div>
                )}

                {validacao.status === "validando" && (
                  <div className="text-center py-4">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
                    <p className="text-sm text-blue-600">Validando arquivo...</p>
                  </div>
                )}

                {validacao.status === "sucesso" && (
                  <div className="space-y-3">
                    <div className="flex items-center text-green-600">
                      <CheckCircle className="h-5 w-5 mr-2" />
                      <span className="font-medium">Validação concluída</span>
                    </div>
                    <div className="space-y-1">
                      {validacao.mensagens.map((msg, index) => (
                        <p key={index} className="text-sm text-gray-600">
                          {msg}
                        </p>
                      ))}
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Ações */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Ações</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button
                  className="w-full"
                  onClick={enviarRemessa}
                  disabled={!arquivo || validacao.status !== "sucesso"}
                >
                  <Send className="h-4 w-4 mr-2" />
                  Enviar Remessa
                </Button>

                <Button variant="outline" className="w-full">
                  <FileText className="h-4 w-4 mr-2" />
                  Salvar Rascunho
                </Button>

                <Button variant="ghost" className="w-full">
                  Limpar Formulário
                </Button>
              </CardContent>
            </Card>

            {/* Informações */}
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Informações</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm text-gray-600">
                <p>• Remessas são processadas em até 2 horas</p>
                <p>• Arquivos devem seguir padrão CNAB</p>
                <p>• Limite diário: R$ 1.000.000,00</p>
                <p>• Suporte: (11) 3000-0000</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}
