#!/bin/bash

# =====================================================
# Script de Debug e Recriação - Azure SQL Server
# =====================================================

echo "🔍 Diagnosticando problemas e recriando recursos..."

# Verificar se está logado
echo "📋 Verificando login no Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Não está logado no Azure. Execute 'az login' primeiro."
    exit 1
fi

echo "✅ Logado no Azure como: $(az account show --query user.name -o tsv)"

# Verificar provedor Microsoft.Sql
echo "🔍 Verificando provedor Microsoft.Sql..."
SQL_STATUS=$(az provider show --namespace Microsoft.Sql --query registrationState --output tsv)
echo "Microsoft.Sql status: $SQL_STATUS"

if [ "$SQL_STATUS" != "Registered" ]; then
    echo "⚠️ Registrando Microsoft.Sql..."
    az provider register --namespace Microsoft.Sql
    sleep 30
    SQL_STATUS=$(az provider show --namespace Microsoft.Sql --query registrationState --output tsv)
    echo "Microsoft.Sql status após registro: $SQL_STATUS"
fi

# Limpar recursos existentes
echo "🧹 Limpando recursos existentes..."
if az group show --name rg-dimdim-fiap &> /dev/null; then
    echo "Deletando resource group existente..."
    az group delete --name rg-dimdim-fiap --yes
    sleep 30
fi

# Configurações
RESOURCE_GROUP="rg-dimdim-fiap"
LOCATION="Brazil South"
SQL_SERVER_NAME="dimdim-server-$(date +%s)"
SQL_DATABASE_NAME="dimdim_db"
SQL_ADMIN_USER="dimdim_admin"
SQL_ADMIN_PASSWORD="DimDim@2024!$(date +%s)"

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

echo "✅ Resource Group criado com sucesso!"

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

echo "✅ SQL Server criado com sucesso!"

# Verificar se SQL Server existe
echo "🔍 Verificando SQL Server..."
if ! az sql server show --name $SQL_SERVER_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "❌ SQL Server não foi encontrado após criação"
    exit 1
fi

echo "✅ SQL Server verificado!"

# Configurar firewall
echo "🔥 Configurando firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

if [ $? -ne 0 ]; then
    echo "❌ Erro ao configurar firewall"
    exit 1
fi

echo "✅ Firewall configurado com sucesso!"

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

echo "✅ SQL Database criado com sucesso!"

# Verificar database
echo "🔍 Verificando database..."
if ! az sql db show --name $SQL_DATABASE_NAME --server $SQL_SERVER_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "❌ Database não foi encontrado após criação"
    exit 1
fi

echo "✅ Database verificado!"

# Obter string de conexão
echo "🔗 Obtendo string de conexão..."
CONNECTION_STRING=$(az sql db show-connection-string \
    --server $SQL_SERVER_NAME \
    --name $SQL_DATABASE_NAME \
    --client jdbc \
    --output tsv)

echo ""
echo "🎉 SUCESSO! Azure SQL Server criado e verificado!"
echo "================================================"
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
