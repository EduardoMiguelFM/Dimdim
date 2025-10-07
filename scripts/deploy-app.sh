#!/bin/bash

# =====================================================
# Script para deploy da DimDim API no Azure
# Disciplina: Cloud Computing - FIAP
# =====================================================

# Configurações (ajuste conforme necessário)
RESOURCE_GROUP="rg-dimdim-fiap"
APP_NAME="dimdim-api"
LOCATION="Brazil South"

echo "🚀 Iniciando deploy da DimDim API no Azure..."

# Verificar se está logado no Azure
echo "📋 Verificando login no Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute 'az login' primeiro."
    exit 1
fi

echo "✅ Logado no Azure como: $(az account show --query user.name -o tsv)"

# Verificar se a Web App existe
echo "🔍 Verificando se a Web App existe..."
if ! az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "❌ Web App '$APP_NAME' não encontrada no Resource Group '$RESOURCE_GROUP'"
    echo "💡 Execute primeiro o script: ./scripts/create-resources.sh"
    exit 1
fi

echo "✅ Web App encontrada!"

# Parar a aplicação antes do deploy
echo "⏹️ Parando a aplicação..."
az webapp stop --name $APP_NAME --resource-group $RESOURCE_GROUP

# Build da aplicação
echo "🔨 Fazendo build da aplicação..."
if ! ./gradlew clean build; then
    echo "❌ Erro no build da aplicação"
    exit 1
fi

echo "✅ Build concluído com sucesso!"

# Verificar se o JAR foi gerado
JAR_FILE="build/libs/ApiJava-0.0.1-SNAPSHOT.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR não encontrado em: $JAR_FILE"
    exit 1
fi

echo "✅ JAR encontrado: $JAR_FILE"

# Fazer backup da versão anterior (opcional)
echo "💾 Fazendo backup da versão anterior..."
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Deploy usando Azure CLI
echo "📦 Fazendo deploy da aplicação..."
az webapp deployment source config-zip \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src $JAR_FILE

if [ $? -eq 0 ]; then
    echo "✅ Deploy realizado com sucesso!"
else
    echo "❌ Erro no deploy"
    exit 1
fi

# Iniciar a aplicação
echo "▶️ Iniciando a aplicação..."
az webapp start --name $APP_NAME --resource-group $RESOURCE_GROUP

# Aguardar a aplicação inicializar
echo "⏳ Aguardando aplicação inicializar..."
sleep 30

# Verificar status da aplicação
echo "🔍 Verificando status da aplicação..."
az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query state -o tsv

# Obter URL da aplicação
WEBAPP_URL=$(az webapp show \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query defaultHostName -o tsv)

echo ""
echo "🎉 DEPLOY CONCLUÍDO COM SUCESSO!"
echo "=================================="
echo "🌐 URL da aplicação: https://$WEBAPP_URL"
echo ""
echo "🧪 Testando endpoints principais..."

# Testar endpoint de health check (se existir)
echo "🔍 Testando conectividade..."
if curl -f -s "https://$WEBAPP_URL/api/usuarios" > /dev/null; then
    echo "✅ API respondendo corretamente!"
else
    echo "⚠️ API pode estar ainda inicializando. Aguarde alguns minutos."
fi

echo ""
echo "📋 Endpoints disponíveis:"
echo "   GET  https://$WEBAPP_URL/api/usuarios"
echo "   POST https://$WEBAPP_URL/api/usuarios"
echo "   GET  https://$WEBAPP_URL/api/transacoes"
echo "   POST https://$WEBAPP_URL/api/transacoes"
echo ""
echo "📊 Monitoramento:"
echo "   - Acesse o portal Azure para ver logs da aplicação"
echo "   - Application Insights para métricas detalhadas"
echo "   - Logs em tempo real: az webapp log tail --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo ""

# Opcional: Executar testes básicos
echo "🧪 Executando testes básicos..."
echo "Testando GET /api/usuarios..."
curl -s "https://$WEBAPP_URL/api/usuarios" | head -c 100
echo "..."

echo ""
echo "✅ Deploy finalizado! A aplicação está disponível em:"
echo "🔗 https://$WEBAPP_URL"
