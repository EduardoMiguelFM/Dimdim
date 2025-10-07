# 🗄️ Configuração Azure SQL Server - DimDim API

## 🚀 Passo a Passo para Criar o Banco PaaS na Azure

### 1. **Pré-requisitos**

- Conta Azure ativa
- Azure CLI instalado
- PowerShell (Windows) ou Bash (Linux/Mac)

### 2. **Login no Azure**

```bash
az login
```

### 3. **Criar Recursos Azure SQL Server**

#### Opção A: Via Script PowerShell (Recomendado para Windows)

```powershell
# Execute no PowerShell como Administrador
.\scripts\create-azure-sql.ps1
```

#### Opção B: Via Script Bash (Linux/Mac)

```bash
# Execute no terminal
chmod +x scripts/create-azure-sql.sh
./scripts/create-azure-sql.sh
```

#### Opção C: Via Portal Azure (Manual)

1. Acesse [portal.azure.com](https://portal.azure.com)
2. Clique em "Create a resource"
3. Procure por "SQL Database"
4. Configure:
   - **Resource Group**: `rg-dimdim-fiap`
   - **Database name**: `dimdim_db`
   - **Server**: Criar novo servidor
   - **Server name**: `dimdim-server-[sufixo]`
   - **Admin username**: `dimdim_admin`
   - **Password**: `DimDim@2024[sufixo]`
   - **Location**: `Brazil South`
   - **Compute + storage**: `Basic` ou `S0`

### 4. **Configurar Firewall**

No portal Azure:

1. Vá para o SQL Server criado
2. Clique em "Networking"
3. Adicione regra de firewall:
   - **Rule name**: `AllowAzureServices`
   - **Start IP**: `0.0.0.0`
   - **End IP**: `0.0.0.0`

### 5. **Executar Script DDL**

1. Conecte ao banco usando:

   - **SQL Server Management Studio** (SSMS)
   - **Azure Data Studio**
   - **Visual Studio Code** com extensão SQL Server

2. Execute o script `database/ddl_tabelas.sql`

### 6. **Configurar Aplicação**

#### Opção A: Variáveis de Ambiente

Crie um arquivo `.env` ou configure no sistema:

```bash
DB_SERVER=seu-servidor.database.windows.net
DB_PORT=1433
DB_NAME=dimdim_db
DB_USERNAME=dimdim_admin
DB_PASSWORD=sua-senha
```

#### Opção B: Editar application.properties

Edite `src/main/resources/application.properties`:

```properties
# Substitua pelos seus valores
spring.datasource.url=jdbc:sqlserver://SEU_SERVIDOR.database.windows.net:1433;database=dimdim_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
spring.datasource.username=SEU_USUARIO
spring.datasource.password=SUA_SENHA
```

### 7. **Testar Conexão**

```bash
# Build da aplicação
./gradlew clean build -x test

# Executar aplicação
./gradlew bootRun
```

### 8. **Verificar se Funcionou**

```bash
# Testar endpoint
curl http://localhost:8080/api/usuarios

# Criar usuário
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@email.com","cpf":"12345678901"}'
```

## 🔧 Comandos Azure CLI Úteis

### Listar recursos

```bash
az resource list --resource-group rg-dimdim-fiap
```

### Ver string de conexão

```bash
az sql db show-connection-string --server SEU_SERVIDOR --name dimdim_db --client jdbc
```

### Conectar ao banco

```bash
az sql db show --server SEU_SERVIDOR --name dimdim_db --resource-group rg-dimdim-fiap
```

## 🐛 Troubleshooting

### Erro: "Login failed"

- Verifique usuário e senha
- Confirme se o firewall está configurado

### Erro: "Cannot connect to server"

- Verifique se o servidor existe
- Confirme as regras de firewall
- Teste conectividade: `telnet SEU_SERVIDOR.database.windows.net 1433`

### Erro: "Database does not exist"

- Execute o script DDL
- Verifique se está conectando ao banco correto

## 📋 Checklist

- [ ] Azure CLI instalado e logado
- [ ] Resource Group criado
- [ ] SQL Server criado
- [ ] SQL Database criado
- [ ] Firewall configurado
- [ ] Script DDL executado
- [ ] Aplicação configurada
- [ ] Teste de conexão funcionando
- [ ] API respondendo

## 💰 Custos

- **SQL Database S0**: ~$15/mês
- **Resource Group**: Gratuito
- **Firewall rules**: Gratuito

**💡 Dica**: Use o tier "Basic" para desenvolvimento (mais barato).

---

**🎯 Próximo passo**: Após criar o banco, configure a aplicação e teste!
