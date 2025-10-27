# 🚀 Guia de Deploy - Azure App Service

## DimDim API - Checkpoint 3

---

## 📋 O Que Vamos Fazer

Deploy da DimDim API no **Azure App Service** usando o pipeline CI/CD do Azure DevOps.

### ✅ Arquivos Necessários

- ✅ `azure-pipelines.yml` - Pipeline principal (já criado)
- ✅ `build.gradle` - Build do projeto
- ✅ Application configurado para Azure SQL
- ✅ Testes unitários implementados

---

## 🎯 Passo a Passo

### ℹ️ Usando Azure Cloud Shell

Se estiver usando **Azure Cloud Shell**, você já está logado e pronto para executar os comandos.

Se não estiver usando Cloud Shell, execute primeiro:

```bash
az login
```

---

### ⚡ Execução Rápida (Cloud Shell)

Se quiser executar tudo de uma vez no Cloud Shell, copie e cole este bloco:

```bash
# Criar todos os recursos de uma vez
az group create --name rg-dimdim-api --location "Brazil South"

az sql server create \
  --name dimdim-server-fiap \
  --resource-group rg-dimdim-api \
  --location "Brazil South" \
  --admin-user dimdim_admin \
  --admin-password "MySecure2024@Abc123#XyZ"

az sql db create \
  --name dimdim_db \
  --resource-group rg-dimdim-api \
  --server dimdim-server-fiap \
  --service-objective S0

az sql server firewall-rule create \
  --resource-group rg-dimdim-api \
  --server dimdim-server-fiap \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

az appservice plan create \
  --name asp-dimdim-api \
  --resource-group rg-dimdim-api \
  --location "Brazil South" \
  --sku B1 \
  --is-linux

az webapp create \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --plan asp-dimdim-api \
  --runtime "JAVA|17-java17"

az webapp config appsettings set \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --settings \
    SPRING_DATASOURCE_URL="jdbc:sqlserver://dimdim-server-fiap.database.windows.net:1433;database=dimdim_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    SPRING_DATASOURCE_USERNAME="dimdim_admin" \
    SPRING_DATASOURCE_PASSWORD="MySecure2024@Abc123#XyZ" \
    APPINSIGHTS_INSTRUMENTATIONKEY=""

echo "✅ Recursos criados!"
echo "🌐 URL: https://dimdim-api-webapp.azurewebsites.net"
```

---

### Passo 1: Criar Recursos no Azure (Detalhado)

Primeiro, vamos criar os recursos necessários no Azure:

#### 1.1 Resource Group

```bash
az group create --name rg-dimdim-api --location "Brazil South"
```

#### 1.2 Azure SQL Database

```bash
# SQL Server
az sql server create \
  --name dimdim-server-fiap \
  --resource-group rg-dimdim-api \
  --location "Brazil South" \
  --admin-user dimdim_admin \
  --admin-password "MySecure2024@Abc123#XyZ"

# SQL Database
az sql db create \
  --name dimdim_db \
  --resource-group rg-dimdim-api \
  --server dimdim-server-fiap \
  --service-objective S0

# Firewall - Permitir Azure Services
az sql server firewall-rule create \
  --resource-group rg-dimdim-api \
  --server dimdim-server-fiap \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

#### 1.3 Azure App Service

```bash
# App Service Plan
az appservice plan create \
  --name asp-dimdim-api \
  --resource-group rg-dimdim-api \
  --location "Brazil South" \
  --sku B1 \
  --is-linux

# Web App
az webapp create \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --plan asp-dimdim-api \
  --runtime "JAVA|17-java17"
```

#### 1.4 Configurar Variáveis de Ambiente no App Service

```bash
# Configurar variáveis de ambiente
az webapp config appsettings set \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --settings \
    SPRING_DATASOURCE_URL="jdbc:sqlserver://dimdim-server-fiap.database.windows.net:1433;database=dimdim_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    SPRING_DATASOURCE_USERNAME="dimdim_admin" \
    SPRING_DATASOURCE_PASSWORD="MySecure2024@Abc123#XyZ" \
    APPINSIGHTS_INSTRUMENTATIONKEY=""
```

> **Nota**: Application Insights é opcional para o checkpoint. Configuramos como vazio. Se quiser usar depois, veja o arquivo `SOLUCAO-APPLICATION-INSIGHTS.md`

---

## 🔧 Passo 2: Configurar Azure DevOps

### 2.1 Criar Projeto no Azure DevOps

1. Acesse: https://dev.azure.com
2. Criar organização (se necessário)
3. **New Project**
   - Nome: "DimDim API Migration"
   - Visibility: Private
   - Work item process: **Agile**
   - Version control: **Git**
4. **Create**

### 2.2 Importar Código no Azure Repos

#### Opção A: Push via Git

```bash
# No terminal do projeto local
cd D:\FACULDADE-FIAP\API-Java

# Adicionar remote do Azure DevOps
git remote add azure-devops https://dev.azure.com/<org>/<projeto>/_git/<repositorio>

# Push do código
git push azure-devops main
```

#### Opção B: Importar via Interface

1. **Repos** > **Files**
2. Botão **...** > **Import Repository**
3. Cole a URL do seu repositório Git
4. **Import**

### 2.3 Criar Task no Azure Boards

1. **Boards** > **Work Items**
2. **New Work Item** > **Task**
3. Título: **"Implementar DimDim API no Azure DevOps"**
4. Assigned to: Seu nome
5. State: **Active**
6. **Save**

### 2.4 Configurar Branch Policies

1. **Repos** > **Branches**
2. **...** ao lado da branch `main` > **Branch policies**
3. Configurar:
   - ✅ **Minimum number of reviewers**: 1
   - ✅ **Add automatic reviewers**: Adicionar `pf0841@fiap.com.br`
   - ✅ **Check for linked work items**: Yes
   - ✅ **Check for comment resolution**: Yes
4. **Save changes**

### 2.5 Criar Branch para Tarefa

1. Abra a Task criada
2. Botão **Create Branch**
3. Branch será criada: `task-XXX-implementar-dimdim-api`
4. Trabalhe nessa branch

---

## 🚀 Passo 3: Configurar Pipeline de Build

### 3.1 Criar Pipeline

1. **Pipelines** > **Pipelines** > **New Pipeline**
2. **Where is your code?**: **Azure Repos Git**
3. **Select a repository**: Seu repositório
4. **Configure your pipeline**: **Existing Azure Pipelines YAML file**
5. Branch: **main**
6. Path: **azure-pipelines.yml**
7. **Continue**

### 3.2 Configurar Service Connection

1. **Project Settings** (⚙️) > **Service Connections**
2. **New Service Connection**
3. **Azure Resource Manager** > **Next**
4. **Workload Identity federation** (ou Service principal) > **Next**
5. Subscription: Selecionar sua subscription
6. Resource Group: **rg-dimdim-api**
7. Security: ✅ "Grant access permission to all pipelines"
8. Service connection name: **Azure Service Connection**
9. **Save**

### 3.3 Executar Pipeline Manualmente

1. Abrir o pipeline criado
2. **Run pipeline**
3. Branch: **main**
4. **Run**

Aguarde o build e verifique:

- ✅ Build bem-sucedido
- ✅ Testes executados
- ✅ Artefatos publicados

---

## 🎬 Passo 4: Executar Fluxo Ponta a Ponta

### 4.1 Fazer Alteração na Branch

**Se estiver usando Cloud Shell**, você pode fazer a alteração diretamente no Azure DevOps:

**Opção A: Via Azure DevOps (Web UI)**

1. Vá em **Repos** > **Files**
2. Navegue até sua branch `task-XXX-implementar-dimdim-api`
3. Edite qualquer arquivo (ex: README.md)
4. Faça commit na web

**Opção B: Via Git local**

```bash
# Fazer checkout da branch criada
git checkout task-XXX-implementar-dimdim-api

# Fazer uma pequena alteração
# Exemplo: Adicionar comentário no README
echo "# Checkpoint 3 - Pipeline CI/CD" >> README.md

# Commit e push
git add .
git commit -m "feat: adicionar comentário no README"
git push azure-devops task-XXX-implementar-dimdim-api
```

### 4.2 Criar Pull Request

1. **Repos** > **Pull Requests**
2. **New Pull Request**
3. Source: **task-XXX-implementar-dimdim-api**
4. Target: **main**
5. Título: "Implementar DimDim API no Azure DevOps"
6. **Work Items**: Vincul 若 r sua Task
7. **Create**

### 4.3 Aprovar e Fazer Merge

1. Revisar mudanças
2. **Approve**
3. **Complete**:
   - ✅ **Don't delete source branch**
   - ✅ **Complete associated work items**
4. **Complete Merge**

### 4.4 Pipeline Executa Automaticamente

Após o merge, o pipeline dispara automaticamente:

1. **Build e Testes** executam
2. **Deploy** para Azure App Service
3. **Verificação** do status

---

## 📊 Passo 5: Verificar Deployment

### 5.1 Verificar Pipeline

1. **Pipelines** > Seu pipeline
2. Verificar logs de build
3. Ver resultados dos testes

### 5.2 Verificar App Service

```bash
# Ver status do App Service
az webapp show \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --query "{State:state, URL:defaultHostName}"

# Verificar logs
az webapp log tail \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api
```

### 5.3 Testar API em Produção

```bash
# Acessar API
curl https://dimdim-api-webapp.azurewebsites.net/api/usuarios

# Criar usuário
curl -X POST https://dimdim-api-webapp.azurewebsites.net/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@email.com",
    "cpf": "12345678901"
  }'

# Listar usuários
curl https://dimdim-api-webapp.azurewebsites.net/api/usuarios
```

---

## 🎥 Gravar Vídeo de Evidência

### Cenas Obrigatórias:

1. ✅ Task criada no Azure Boards
2. ✅ Branch criada e código alterado
3. ✅ Pull Request criado (com Work Item vinculado)
4. ✅ Merge realizado (sem deletar branch)
5. ✅ **Pipeline de Build executando** (mostrar logs)
6. ✅ **Resultados dos Testes publicados** (tabela de testes)
7. ✅ **Pipeline de Deploy executando**
8. ✅ **Deploy bem-sucedido**
9. ✅ **CRUD de Usuários na API em produção**
10. ✅ **CRUD de Transações na API em produção**
11. ✅ **Evidência no banco** (mostrar registros no Azure SQL)

---

## ✅ Checklist Final

- [ ] Recursos Azure criados (SQL Server, App Service)
- [ ] Projeto criado no Azure DevOps
- [ ] Código importado no Azure Repos
- [ ] Task criada no Azure Boards
- [ ] Branch policies configuradas
- [ ] Branch criada para a task
- [ ] Service Connection configurada
- [ ] Pipeline de build configurado
- [ ] Pipeline executado com sucesso
- [ ] Testes passando
- [ ] Deploy executado com sucesso
- [ ] API testada em produção
- [ ] Evidências gravadas no vídeo
- [ ] Professor adicionado como admin

---

## 👥 Adicionar Professor

1. **Project Settings** > **Permissions**
2. **Users** > **Add**
3. Usuário: `pf0841@fiap.com.br`
4. Level: **Basic**
5. Project: **Contributor**
6. **Add**

---

## 📞 Troubleshooting

### Erro no Deploy

```bash
# Ver logs detalhados
az webapp log download \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --log-file ./app-logs.zip
```

### Erro de Conexão com Banco

Verificar:

1. Firewall do SQL configurado
2. Connection string correta
3. Credenciais corretas

### Pipeline Falha nos Testes

```bash
# Executar testes localmente
./gradlew test

# Ver relatório
start build/reports/tests/test/index.html
```

---

## 🎓 Próximos Passos

1. ✅ Executar deploy conforme este guia
2. ✅ Gravar vídeo de evidência
3. ✅ Criar PDF de entrega
4. ✅ Entregar checkpoint

---

**Status**: ✅ **PRONTO PARA DEPLOY**
