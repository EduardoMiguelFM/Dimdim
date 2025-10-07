# =====================================================
# Script PowerShell para criar Azure SQL Server
# Disciplina: Cloud Computing - FIAP
# =====================================================

# Configurações
$ResourceGroup = "rg-dimdim-fiap"
$Location = "Brazil South"
$SqlServerName = "dimdim-server-$(Get-Date -Format 'yyyyMMddHHmmss')"
$SqlDatabaseName = "dimdim_db"
$SqlAdminUser = "dimdim_admin"
$SqlAdminPassword = "DimDim@2024$(Get-Date -Format 'HHmmss')"
$FirewallRuleName = "AllowAzureServices"

Write-Host "🚀 Criando Azure SQL Server para DimDim API..." -ForegroundColor Green

# Verificar se está logado no Azure
Write-Host "📋 Verificando login no Azure..." -ForegroundColor Yellow
try {
    $account = az account show --query user.name -o tsv 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Não está logado no Azure"
    }
    Write-Host "✅ Logado no Azure como: $account" -ForegroundColor Green
} catch {
    Write-Host "❌ Não está logado no Azure. Execute 'az login' primeiro." -ForegroundColor Red
    exit 1
}

# Criar Resource Group
Write-Host "📦 Criando Resource Group: $ResourceGroup" -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --tags "project=dimdim" "environment=production" "team=fiap"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource Group criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar Resource Group" -ForegroundColor Red
    exit 1
}

# Criar SQL Server
Write-Host "🗄️ Criando SQL Server: $SqlServerName" -ForegroundColor Yellow
az sql server create --name $SqlServerName --resource-group $ResourceGroup --location $Location --admin-user $SqlAdminUser --admin-password $SqlAdminPassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SQL Server criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar SQL Server" -ForegroundColor Red
    exit 1
}

# Configurar firewall do SQL Server
Write-Host "🔥 Configurando firewall do SQL Server..." -ForegroundColor Yellow
az sql server firewall-rule create --resource-group $ResourceGroup --server $SqlServerName --name $FirewallRuleName --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Firewall configurado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao configurar firewall" -ForegroundColor Red
    exit 1
}

# Criar SQL Database
Write-Host "💾 Criando SQL Database: $SqlDatabaseName" -ForegroundColor Yellow
az sql db create --resource-group $ResourceGroup --server $SqlServerName --name $SqlDatabaseName --service-objective S0

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SQL Database criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao criar SQL Database" -ForegroundColor Red
    exit 1
}

# Obter string de conexão
Write-Host "🔗 Obtendo string de conexão..." -ForegroundColor Yellow
$ConnectionString = az sql db show-connection-string --server $SqlServerName --name $SqlDatabaseName --client jdbc --output tsv

Write-Host ""
Write-Host "🎉 AZURE SQL SERVER CRIADO COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "📋 Informações do banco:" -ForegroundColor Cyan
Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   SQL Server: $SqlServerName" -ForegroundColor White
Write-Host "   Database: $SqlDatabaseName" -ForegroundColor White
Write-Host "   Username: $SqlAdminUser" -ForegroundColor White
Write-Host "   Password: $SqlAdminPassword" -ForegroundColor White
Write-Host ""
Write-Host "🔗 String de conexão JDBC:" -ForegroundColor Cyan
Write-Host $ConnectionString -ForegroundColor White
Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Execute o script DDL no banco de dados" -ForegroundColor White
Write-Host "   2. Configure as variáveis de ambiente na aplicação" -ForegroundColor White
Write-Host "   3. Teste a conexão com a aplicação" -ForegroundColor White
Write-Host ""
Write-Host "⚠️ IMPORTANTE: Anote essas informações para configurar a aplicação!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Para conectar via SQL Server Management Studio:" -ForegroundColor Cyan
Write-Host "   Server: $SqlServerName.database.windows.net" -ForegroundColor White
Write-Host "   Login: $SqlAdminUser" -ForegroundColor White
Write-Host "   Password: $SqlAdminPassword" -ForegroundColor White
Write-Host "   Database: $SqlDatabaseName" -ForegroundColor White
