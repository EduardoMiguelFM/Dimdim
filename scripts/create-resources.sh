#!/bin/bash

# =====================================================
# Script para criar recursos Azure para DimDim API
# Disciplina: Cloud Computing - FIAP
# =====================================================

# Configurações
RESOURCE_GROUP="rg-dimdim-fiap"
LOCATION="Brazil South"
APP_NAME="dimdim-api"
DB_SERVER="dimdim-server"
DB_NAME="dimdim_db"
DB_USERNAME="dimdim_admin"
DB_PASSWORD="DimDim@2024"
APP_SERVICE_PLAN="asp-dimdim-fiap"
APP_INSIGHTS="ai-dimdim-fiap"

echo "🚀 Iniciando criação de recursos Azure para DimDim API..."

# Verificar se está logado no Azure
echo "📋 Verificando login no Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute 'az login' primeiro."
    exit 1
fi

echo "✅ Logado no Azure como: $(az account show --query user.name -o tsv)"

# Criar Resource Group
echo "📦 Criando Resource Group: $RESOURCE_GROUP"
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --tags "project=dimdim" "environment=production" "team=fiap"

if [ $? -eq 0 ]; then
    echo "✅ Resource Group criado com sucesso!"
else
    echo "❌ Erro ao criar Resource Group"
    exit 1
fi

# Criar App Service Plan
echo "🏗️ Criando App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --sku B1 \
    --is-linux

if [ $? -eq 0 ]; then
    echo "✅ App Service Plan criado com sucesso!"
else
    echo "❌ Erro ao criar App Service Plan"
    exit 1
fi

# Criar SQL Server
echo "🗄️ Criando SQL Server: $DB_SERVER"
az sql server create \
    --name $DB_SERVER \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --admin-user $DB_USERNAME \
    --admin-password $DB_PASSWORD

if [ $? -eq 0 ]; then
    echo "✅ SQL Server criado com sucesso!"
else
    echo "❌ Erro ao criar SQL Server"
    exit 1
fi

# Configurar firewall do SQL Server (permitir serviços Azure)
echo "🔥 Configurando firewall do SQL Server..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $DB_SERVER \
    --name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

if [ $? -eq 0 ]; then
    echo "✅ Firewall configurado com sucesso!"
else
    echo "❌ Erro ao configurar firewall"
    exit 1
fi

# Criar SQL Database
echo "💾 Criando SQL Database: $DB_NAME"
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $DB_SERVER \
    --name $DB_NAME \
    --service-objective S0

if [ $? -eq 0 ]; then
    echo "✅ SQL Database criado com sucesso!"
else
    echo "❌ Erro ao criar SQL Database"
    exit 1
fi

# Criar Application Insights
echo "📊 Criando Application Insights: $APP_INSIGHTS"
az monitor app-insights component create \
    --app $APP_INSIGHTS \
    --location "$LOCATION" \
    --resource-group $RESOURCE_GROUP

if [ $? -eq 0 ]; then
    echo "✅ Application Insights criado com sucesso!"
    # Obter Instrumentation Key
    INSTRUMENTATION_KEY=$(az monitor app-insights component show \
        --app $APP_INSIGHTS \
        --resource-group $RESOURCE_GROUP \
        --query instrumentationKey -o tsv)
    echo "🔑 Instrumentation Key: $INSTRUMENTATION_KEY"
else
    echo "❌ Erro ao criar Application Insights"
    exit 1
fi

# Criar Web App
echo "🌐 Criando Web App: $APP_NAME"
az webapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "JAVA|17-java17"

if [ $? -eq 0 ]; then
    echo "✅ Web App criada com sucesso!"
else
    echo "❌ Erro ao criar Web App"
    exit 1
fi

# Configurar variáveis de ambiente da Web App
echo "⚙️ Configurando variáveis de ambiente..."
az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "DB_SERVER=$DB_SERVER.database.windows.net" \
        "DB_PORT=1433" \
        "DB_NAME=$DB_NAME" \
        "DB_USERNAME=$DB_USERNAME" \
        "DB_PASSWORD=$DB_PASSWORD" \
        "APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY" \
        "SPRING_PROFILES_ACTIVE=production"

if [ $? -eq 0 ]; then
    echo "✅ Variáveis de ambiente configuradas!"
else
    echo "❌ Erro ao configurar variáveis de ambiente"
    exit 1
fi

# Configurar Application Insights na Web App
echo "📈 Configurando Application Insights na Web App..."
az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "APPINSIGHTS_PROFILERFEATURE_VERSION=1.0.0" \
        "APPINSIGHTS_SNAPSHOTFEATURE_VERSION=1.0.0" \
        "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$INSTRUMENTATION_KEY"

if [ $? -eq 0 ]; then
    echo "✅ Application Insights configurado na Web App!"
else
    echo "❌ Erro ao configurar Application Insights"
    exit 1
fi

# Obter URL da Web App
echo "🔗 Obtendo URL da Web App..."
WEBAPP_URL=$(az webapp show \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query defaultHostName -o tsv)

echo ""
echo "🎉 RECURSOS CRIADOS COM SUCESSO!"
echo "=================================="
echo "📋 Resumo dos recursos criados:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   App Service Plan: $APP_SERVICE_PLAN"
echo "   Web App: $APP_NAME"
echo "   SQL Server: $DB_SERVER"
echo "   SQL Database: $DB_NAME"
echo "   Application Insights: $APP_INSIGHTS"
echo ""
echo "🌐 URL da aplicação: https://$WEBAPP_URL"
echo "🔑 Instrumentation Key: $INSTRUMENTATION_KEY"
echo ""
echo "📝 Próximos passos:"
echo "   1. Execute o script DDL no banco de dados"
echo "   2. Execute o deploy da aplicação com: ./scripts/deploy-app.sh"
echo "   3. Teste a aplicação através da URL fornecida"
echo ""
echo "⚠️ IMPORTANTE: Anote as informações acima para referência futura!"
