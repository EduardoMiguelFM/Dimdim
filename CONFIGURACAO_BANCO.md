# 🗄️ Configuração do Banco de Dados - DimDim API

## ⚠️ IMPORTANTE: Antes de executar a aplicação

A aplicação precisa de um banco de dados configurado para funcionar. Siga as instruções abaixo:

## 🚀 Opção 1: SQL Server Local (Mais Rápido para Testes)

### 1. Instalar SQL Server Local
- Baixe o SQL Server Express: https://www.microsoft.com/pt-br/sql-server/sql-server-downloads
- Instale com as configurações padrão
- Anote a senha do usuário `sa`

### 2. Configurar application.properties
Edite o arquivo `src/main/resources/application.properties`:

```properties
# Configurações do SQL Server Local
spring.datasource.url=jdbc:sqlserver://localhost:1433;database=dimdim_db;encrypt=false;
spring.datasource.username=sa
spring.datasource.password=SUA_SENHA_AQUI
```

### 3. Criar o banco de dados
Execute no SQL Server Management Studio ou Azure Data Studio:

```sql
CREATE DATABASE dimdim_db;
GO
```

### 4. Executar o DDL
Execute o script `database/ddl_tabelas.sql` no banco `dimdim_db`.

### 5. Executar a aplicação
```bash
./gradlew bootRun
```

## ☁️ Opção 2: Azure SQL Server (Para Deploy)

### 1. Criar recursos no Azure
```bash
# Login no Azure
az login

# Criar resource group
az group create --name rg-dimdim-fiap --location "Brazil South"

# Criar SQL Server
az sql server create --name dimdim-server --resource-group rg-dimdim-fiap --admin-user dimdim_admin --admin-password "DimDim@2024"

# Criar SQL Database
az sql db create --name dimdim_db --server dimdim-server --resource-group rg-dimdim-fiap
```

### 2. Configurar firewall
```bash
# Permitir serviços Azure
az sql server firewall-rule create --resource-group rg-dimdim-fiap --server dimdim-server --name "AllowAzureServices" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
```

### 3. Configurar application.properties
```properties
# Configurações do Azure SQL Server
spring.datasource.url=jdbc:sqlserver://dimdim-server.database.windows.net:1433;database=dimdim_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
spring.datasource.username=dimdim_admin
spring.datasource.password=DimDim@2024
```

### 4. Executar o DDL
Execute o script `database/ddl_tabelas.sql` no banco Azure.

## 🧪 Opção 3: H2 Database (Para Testes Rápidos)

### 1. Configurar application.properties
```properties
# Configurações do H2 (banco em memória)
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect
```

### 2. Executar a aplicação
```bash
./gradlew bootRun
```

**⚠️ ATENÇÃO**: O H2 é apenas para testes. Os dados são perdidos quando a aplicação para.

## 🔧 Verificar se está funcionando

### 1. Testar a aplicação
```bash
# Executar aplicação
./gradlew bootRun

# Em outro terminal, testar endpoint
curl http://localhost:8080/api/usuarios
```

### 2. Verificar logs
Procure por mensagens como:
```
Started ApiJavaApplication in X.XXX seconds
```

### 3. Testar endpoints
```bash
# Criar usuário
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@email.com","cpf":"12345678901"}'

# Listar usuários
curl http://localhost:8080/api/usuarios
```

## 🐛 Problemas Comuns

### Erro: "Cannot connect to database"
- Verifique se o SQL Server está rodando
- Confirme as credenciais no `application.properties`
- Teste a conexão com telnet: `telnet localhost 1433`

### Erro: "Database does not exist"
- Crie o banco de dados manualmente
- Execute o script DDL

### Erro: "Login failed"
- Verifique usuário e senha
- Confirme se o usuário tem permissões no banco

### Erro: "Firewall"
- Configure o firewall do SQL Server
- Para Azure: adicione regra de firewall

## 📋 Checklist

- [ ] Banco de dados criado
- [ ] Script DDL executado
- [ ] `application.properties` configurado
- [ ] Aplicação inicia sem erros
- [ ] Endpoint `/api/usuarios` responde
- [ ] Pode criar usuário via POST
- [ ] Pode criar transação via POST

## 🎯 Próximos Passos

1. **Configure o banco** usando uma das opções acima
2. **Execute a aplicação**: `./gradlew bootRun`
3. **Teste os endpoints** com curl ou Postman
4. **Faça o deploy** no Azure quando estiver funcionando

---

**💡 Dica**: Para desenvolvimento local, use SQL Server Express. Para deploy, use Azure SQL Server.
