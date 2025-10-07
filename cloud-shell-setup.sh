#!/bin/bash

# =====================================================
# Script para Azure Cloud Shell - DimDim API
# Disciplina: Cloud Computing - FIAP
# =====================================================

echo "🚀 Configurando Azure SQL Server no Cloud Shell..."

# Configurações
RESOURCE_GROUP="rg-dimdim-fiap"
LOCATION="Brazil South"
SQL_SERVER_NAME="dimdim-server-$(date +%s)"
SQL_DATABASE_NAME="dimdim_db"
SQL_ADMIN_USER="dimdim_admin"
SQL_ADMIN_PASSWORD="DimDim@2024$(date +%s)"
FIREWALL_RULE_NAME="AllowAzureServices"

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

# Criar SQL Server
echo "🗄️ Criando SQL Server..."
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --admin-user $SQL_ADMIN_USER \
    --admin-password $SQL_ADMIN_PASSWORD

# Configurar firewall
echo "🔥 Configurando firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $FIREWALL_RULE_NAME \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Criar SQL Database
echo "💾 Criando SQL Database..."
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $SQL_DATABASE_NAME \
    --service-objective S0

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
echo "   2. Configure na aplicação"
echo "   3. Execute o script DDL"
echo ""
echo "⚠️ ANOTE ESSAS INFORMAÇÕES!"
