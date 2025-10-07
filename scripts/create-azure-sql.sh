#!/bin/bash

# =====================================================
# Script para criar Azure SQL Server para DimDim API
# Disciplina: Cloud Computing - FIAP
# =====================================================

# Configurações
RESOURCE_GROUP="rg-dimdim-fiap"
LOCATION="Brazil South"
SQL_SERVER_NAME="dimdim-server-$(date +%s)"  # Nome único
SQL_DATABASE_NAME="dimdim_db"
SQL_ADMIN_USER="dimdim_admin"
SQL_ADMIN_PASSWORD="DimDim@2024$(date +%s)"  # Senha única
FIREWALL_RULE_NAME="AllowAzureServices"

echo "🚀 Criando Azure SQL Server para DimDim API..."

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

# Criar SQL Server
echo "🗄️ Criando SQL Server: $SQL_SERVER_NAME"
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --admin-user $SQL_ADMIN_USER \
    --admin-password $SQL_ADMIN_PASSWORD

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
    --server $SQL_SERVER_NAME \
    --name $FIREWALL_RULE_NAME \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

if [ $? -eq 0 ]; then
    echo "✅ Firewall configurado com sucesso!"
else
    echo "❌ Erro ao configurar firewall"
    exit 1
fi

# Criar SQL Database
echo "💾 Criando SQL Database: $SQL_DATABASE_NAME"
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $SQL_DATABASE_NAME \
    --service-objective S0

if [ $? -eq 0 ]; then
    echo "✅ SQL Database criado com sucesso!"
else
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
echo "🎉 AZURE SQL SERVER CRIADO COM SUCESSO!"
echo "========================================"
echo "📋 Informações do banco:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   SQL Server: $SQL_SERVER_NAME"
echo "   Database: $SQL_DATABASE_NAME"
echo "   Username: $SQL_ADMIN_USER"
echo "   Password: $SQL_ADMIN_PASSWORD"
echo ""
echo "🔗 String de conexão JDBC:"
echo "$CONNECTION_STRING"
echo ""
echo "📝 Próximos passos:"
echo "   1. Execute o script DDL no banco de dados"
echo "   2. Configure as variáveis de ambiente na aplicação"
echo "   3. Teste a conexão com a aplicação"
echo ""
echo "⚠️ IMPORTANTE: Anote essas informações para configurar a aplicação!"
echo ""
echo "🔧 Para conectar via SQL Server Management Studio:"
echo "   Server: $SQL_SERVER_NAME.database.windows.net"
echo "   Login: $SQL_ADMIN_USER"
echo "   Password: $SQL_ADMIN_PASSWORD"
echo "   Database: $SQL_DATABASE_NAME"
