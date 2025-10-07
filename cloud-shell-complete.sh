#!/bin/bash

# =====================================================
# Script Completo para Azure Cloud Shell - DimDim API
# Inclui registro de provedores necessários
# =====================================================

echo "🚀 Configurando Azure SQL Server no Cloud Shell..."
echo "📋 Registrando provedores necessários..."

# Registrar provedores necessários
echo "🔧 Registrando Microsoft.Sql..."
az provider register --namespace Microsoft.Sql

echo "🔧 Registrando Microsoft.Storage..."
az provider register --namespace Microsoft.Storage

echo "🔧 Registrando Microsoft.Network..."
az provider register --namespace Microsoft.Network

echo "🔧 Registrando Microsoft.Compute..."
az provider register --namespace Microsoft.Compute

echo "⏳ Aguardando registro dos provedores..."
sleep 30

# Verificar se Microsoft.Sql está registrado
echo "🔍 Verificando status dos provedores..."
SQL_STATUS=$(az provider show --namespace Microsoft.Sql --query registrationState --output tsv)
echo "Microsoft.Sql status: $SQL_STATUS"

if [ "$SQL_STATUS" != "Registered" ]; then
    echo "⚠️ Microsoft.Sql ainda não está registrado. Aguardando mais 30 segundos..."
    sleep 30
    SQL_STATUS=$(az provider show --namespace Microsoft.Sql --query registrationState --output tsv)
    echo "Microsoft.Sql status após espera: $SQL_STATUS"
fi

if [ "$SQL_STATUS" != "Registered" ]; then
    echo "❌ Erro: Microsoft.Sql não foi registrado. Tente novamente em alguns minutos."
    exit 1
fi

echo "✅ Provedores registrados com sucesso!"

# Configurações
RESOURCE_GROUP="rg-dimdim-fiap"
LOCATION="Brazil South"
SQL_SERVER_NAME="dimdim-server-$(date +%s)"
SQL_DATABASE_NAME="dimdim_db"
SQL_ADMIN_USER="dimdim_admin"
SQL_ADMIN_PASSWORD="DimDim@2024$(date +%s)"
FIREWALL_RULE_NAME="AllowAzureServices"

echo ""
echo "📋 Configurações:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   SQL Server: $SQL_SERVER_NAME"
echo "   Database: $SQL_DATABASE_NAME"
echo "   Username: $SQL_ADMIN_USER"
echo "   Password: $SQL_ADMIN_PASSWORD"
echo ""

# Criar Resource Group
echo "📦 Criando Resource Group..."
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --tags "project=dimdim" "environment=production" "team=fiap"

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar Resource Group"
    exit 1
fi

# Criar SQL Server
echo "🗄️ Criando SQL Server..."
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --admin-user $SQL_ADMIN_USER \
    --admin-password $SQL_ADMIN_PASSWORD

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar SQL Server"
    exit 1
fi

# Configurar firewall
echo "🔥 Configurando firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $FIREWALL_RULE_NAME \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

if [ $? -ne 0 ]; then
    echo "❌ Erro ao configurar firewall"
    exit 1
fi

# Criar SQL Database
echo "💾 Criando SQL Database..."
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $SQL_DATABASE_NAME \
    --service-objective S0

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar SQL Database"
    exit 1
fi

# Obter string de conexão
echo "🔗 Obtendo string de conexão..."
CONNECTION_STRING=$(az sql db show-connection-string \
    --server $SQL_SERVER_NAME \
    --name $SQL_DATABASE_NAME \
    --client jdbc \
    --output tsv)

echo ""
echo "🎉 SUCESSO! Azure SQL Server criado!"
echo "=================================="
echo "📋 Informações importantes:"
echo "   SQL Server: $SQL_SERVER_NAME.database.windows.net"
echo "   Database: $SQL_DATABASE_NAME"
echo "   Username: $SQL_ADMIN_USER"
echo "   Password: $SQL_ADMIN_PASSWORD"
echo ""
echo "🔗 String de conexão JDBC:"
echo "$CONNECTION_STRING"
echo ""
echo "📝 Próximos passos:"
echo "   1. Copie essas informações"
echo "   2. Configure na aplicação (application.properties)"
echo "   3. Execute o script DDL no banco"
echo ""
echo "⚠️ ANOTE ESSAS INFORMAÇÕES!"
