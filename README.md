# DimDim API - Sistema de Gestão Financeira

## 📋 Sobre o Projeto

O **DimDim API** é um sistema de gestão financeira desenvolvido em Java com Spring Boot para a disciplina de **Cloud Computing - FIAP**. O sistema permite gerenciar usuários e suas transações financeiras, com persistência em Azure SQL Server e deploy na nuvem Azure.

Este projeto foi desenvolvido como parte do **2º Checkpoint** da disciplina, atendendo aos requisitos de aplicação Web em nuvem com banco de dados PaaS.

## 🏗️ Arquitetura

- **Backend**: Java 21 + Spring Boot 3.5.6
- **Banco de Dados**: Azure SQL Database (PaaS)
- **ORM**: JPA/Hibernate 6.6.29
- **Deploy**: Azure App Service
- **Monitoramento**: Application Insights
- **API**: REST com operações CRUD completas
- **Build Tool**: Gradle
- **Container**: Tomcat Embedded

## 🎯 Objetivos do Projeto

- ✅ Aplicação Web em Java deployada na Azure
- ✅ Banco de dados PaaS (Azure SQL Database)
- ✅ Relacionamento Master-Detail (usuarios ↔ transacoes)
- ✅ Monitoramento com Application Insights
- ✅ Deploy automatizado via GitHub Actions ou Azure CLI
- ✅ API REST completa com operações CRUD

## 📊 Estrutura do Banco de Dados

### Tabelas

#### 1. **usuarios** (Tabela Master)

- `id`: Chave primária
- `nome`: Nome do usuário
- `email`: Email único
- `cpf`: CPF único
- `telefone`: Telefone de contato
- `endereco`: Endereço completo
- `saldo`: Saldo atual da conta
- `ativo`: Status da conta
- `data_criacao`: Data de criação
- `data_atualizacao`: Data da última atualização

#### 2. **transacoes** (Tabela Detail)

- `id`: Chave primária
- `valor`: Valor da transação
- `tipo`: Tipo da transação (DEPOSITO, SAQUE, TRANSFERENCIA_ENVIADA, etc.)
- `descricao`: Descrição da transação
- `usuario_id`: Chave estrangeira para usuarios
- `data_transacao`: Data da transação
- `data_criacao`: Data de criação
- `data_atualizacao`: Data da última atualização

### Relacionamento

- **usuarios (1) -----> (N) transacoes**
- Relacionamento One-to-Many
- FK: `transacoes.usuario_id` -> `usuarios.id`

## 🚀 Como Executar Localmente

### Pré-requisitos

- Java 21+
- Maven ou Gradle
- Azure SQL Server (ou SQL Server local)

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd API-Java
```

### 2. Configure o banco de dados

Edite o arquivo `src/main/resources/application.properties`:

```properties
# Para Azure SQL Server
spring.datasource.url=jdbc:sqlserver://seu-servidor.database.windows.net:1433;database=dimdim_db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
spring.datasource.username=seu-usuario
spring.datasource.password=sua-senha

# Para SQL Server local
spring.datasource.url=jdbc:sqlserver://localhost:1433;database=dimdim_db;encrypt=false;
spring.datasource.username=sa
spring.datasource.password=sua-senha
```

### 3. Execute o DDL

Execute o script SQL localizado em `database/ddl_tabelas.sql` no seu banco de dados.

### 4. Execute a aplicação

```bash
./gradlew bootRun
```

A aplicação estará disponível em: `http://localhost:8080`

## 🌐 Deploy no Azure

### 📋 Pré-requisitos

- Conta Azure ativa
- Azure CLI instalado e configurado
- Java 21 instalado
- Git configurado

### 🚀 Opção 1: Deploy Automatizado via Azure CLI

#### 1. Criar Recursos na Azure

Execute o script para criar todos os recursos necessários:

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/API-Java.git
cd API-Java

# Execute o script de criação de recursos
./scripts/create-azure-resources.sh
```

Este script criará:

- ✅ Resource Group: `rg-dimdim-api`
- ✅ App Service Plan: `asp-dimdim-api`
- ✅ Web App: `dimdim-api-webapp`
- ✅ SQL Server: `dimdim-sql-server`
- ✅ SQL Database: `dimdim-database`
- ✅ Application Insights: `appi-dimdim-api`

#### 2. Configurar Variáveis de Ambiente

```bash
# Execute o script de configuração
./scripts/configure-environment.sh
```

#### 3. Deploy da Aplicação

```bash
# Build e deploy
./scripts/deploy-app.sh
```

### 🎯 Opção 2: Deploy via IDE (VSCode/IntelliJ/Eclipse)

#### Pré-requisitos

- Plugin Azure instalado no IDE
- Azure CLI configurado
- Conta Azure ativa

#### Passos

1. **Instalar Plugin Azure**:

   - VSCode: Azure App Service extension
   - IntelliJ: Azure Toolkit for IntelliJ
   - Eclipse: Azure Toolkit for Eclipse

2. **Fazer Login na Azure**:

   ```bash
   az login
   ```

3. **Deploy via Plugin**:
   - Clique com botão direito no projeto
   - Selecione "Deploy to Azure"
   - Configure as opções de deploy
   - Execute o deploy

## 🚀 CI/CD com Azure DevOps Pipeline

### 📋 Configuração do Azure DevOps

Este projeto inclui um pipeline completo de CI/CD configurado no Azure DevOps para automatizar build, testes e deploy.

### 📝 Estrutura do Pipeline

O arquivo `azure-pipelines.yml` contém dois estágios:

1. **Build e Testes (CI)**

   - Checkout do código
   - Configuração do JDK 17
   - Build com Gradle
   - Execução de testes unitários (JUnit)
   - Publicação de resultados de testes
   - Publicação de artefatos JAR

2. **Deploy (CD)**
   - Download dos artefatos
   - Deploy para Azure App Service
   - Verificação do status do deploy

### 🔧 Como Configurar no Azure DevOps

#### 1. Criar Projeto no Azure DevOps

1. Acesse [https://dev.azure.com](https://dev.azure.com)
2. Crie um novo projeto (ex: "DimDim API Migration")
3. Selecione "Agile" como metodologia de trabalho
4. Configure o controle de versão como Git

#### 2. Azure Boards - Criar Task

1. Vá em **Boards** > **Work Items**
2. Crie uma nova Task com título: **"Implementar DimDim API no Azure DevOps"**
3. Atribua a task para você
4. Mude o Status para **Active**
5. Adicione o Work Item obrigatório ao Criar branch (configurado nas políticas)

#### 3. Azure Repos - Importar Código

**Opção A: Push do repositório local**

```bash
git remote add azure-devops <URL_DO_AZURE_REPOS>
git push azure-devops main
```

**Opção B: Importar via interface**

1. Vá em **Repos** > **Files**
2. Clique em **Import Repository**
3. Cole a URL do seu repositório Git
4. Aguarde a importação

#### 4. Configurar Branch Policies

1. Vá em **Repos** > **Branches**
2. No menu de 3 pontos ao lado da branch `main`, selecione **Branch Policies**
3. Configure as seguintes políticas:
   - ✅ **Build validation**: Pipeline de Build
   - ✅ **Work item linking required**: Requer link de Work Item
   - ✅ **Minimum number of reviewers**: 1 revisor
   - ✅ **Automated reviewers**: Adicionar pf0841@fiap.com.br como revisor automático

#### 5. Criar Branch para Tarefa

1. Vá em **Boards** > abra a task criada
2. Clique em **Create Branch** (cria automaticamente a branch baseada na task)
3. Trabalhe na nova branch

#### 6. Configurar Pipeline de Build

1. Vá em **Pipelines** > **Pipelines**
2. Clique em **New Pipeline**
3. Selecione **Azure Repos Git**
4. Selecione seu repositório
5. Configure como **YAML**
6. Escolha a branch `main`
7. O arquivo `azure-pipelines.yml` será detectado automaticamente
8. Clique em **Run** para executar manualmente

**Configurar Service Connection para Azure:**

1. Vá em **Project Settings** > **Service Connections**
2. Clique em **New Service Connection**
3. Selecione **Azure Resource Manager**
4. Escolha **Workload Identity federation**
5. Selecione a Subscription
6. Dê um nome: **Azure Service Connection**
7. Selecione o Resource Group: `rg-dimdim-api`
8. Clique em **Save**

#### 7. Executar Pipeline Manualmente

1. Vá em **Pipelines** > **Pipelines**
2. Selecione seu pipeline
3. Clique em **Run Pipeline**
4. Selecione a branch `main`
5. Clique em **Run**
6. Aguarde o build e verifique os testes unitários

#### 8. Configurar Pipeline de Release

1. Vá em **Pipelines** > **Releases**
2. Clique em **New Pipeline**
3. Adicione um **Artifact** > **Build**
4. Selecione o pipeline de build criado anteriormente
5. Na **Stage 1**, adicione tasks:
   - **Azure App Service deploy**
   - **Azure CLI** (para verificação)

#### 9. Executar Release Manualmente

1. Vá em **Releases**
2. Clique em **Create Release**
3. Selecione a versão do artifact
4. Clique em **Create**
5. Aguarde o deploy

### 📊 Testes Unitários

Os testes foram implementados com JUnit 5 e MockMvc:

**Testes de Usuário (`UsuarioControllerTest`):**

- ✅ Criar usuário com sucesso
- ✅ Validar email duplicado
- ✅ Listar todos os usuários
- ✅ Buscar usuário por ID
- ✅ Atualizar usuário
- ✅ Desativar usuário

**Testes de Transação (`TransacaoControllerTest`):**

- ✅ Criar depósito
- ✅ Criar saque com sucesso
- ✅ Validar saldo insuficiente
- ✅ Listar todas as transações
- ✅ Buscar transações por usuário
- ✅ Remover transação

**Executar testes localmente:**

```bash
./gradlew test
```

### 🐳 Docker

O projeto inclui suporte completo para Docker:

**Build da imagem:**

```bash
docker build -t dimdim-api .
```

**Executar com Docker:**

```bash
docker run -p 8080:8080 dimdim-api
```

**Executar com Docker Compose:**

```bash
docker-compose up
```

### 📦 Arquivos de Entrega

✅ **Pipeline YAML**: `azure-pipelines.yml`  
✅ **Dockerfile**: `Dockerfile`  
✅ **Docker Compose**: `docker-compose.yml`  
✅ **Script SQL**: `database/script.sql`  
✅ **API Examples**: `api-examples/operacoes-api.json`  
✅ **Testes Unitários**: `src/test/java/`

### 🎬 Execução Ponta a Ponta

1. **Fazer alteração no código** na branch criada
2. **Commit e Push**
3. **Criar Pull Request** na interface do Azure DevOps
4. **Vincular Work Item** ao PR
5. **Aguardar aprovação** (auto-approve como revisor)
6. **Fazer Merge** (não deletar branch)
7. **Fechar Work Item** automaticamente
8. **Pipeline executa automaticamente**
9. **Release Pipeline executa automaticamente**
10. **Verificar deployment** no Azure Portal

### 🔍 Monitoramento

Após o deploy, você pode monitorar:

- **Application Insights**: Métricas e logs
- **Azure App Service**: Status e logs
- **Azure DevOps**: Histórico de builds e releases

### 🔄 Opção 3: Deploy via GitHub Actions (CI/CD)

#### Configurar GitHub Actions

1. **Crie o arquivo `.github/workflows/deploy.yml`**:

```yaml
name: Deploy DimDim API to Azure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AZURE_WEBAPP_NAME: dimdim-api-webapp
  AZURE_WEBAPP_PACKAGE_PATH: build/libs/*.jar
  JAVA_VERSION: "21"

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK ${{ env.JAVA_VERSION }}
        uses: actions/setup-java@v3
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: "temurin"

      - name: Cache Gradle packages
        uses: actions/cache@v3
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            ${{ runner.os }}-gradle-

      - name: Build with Gradle
        run: ./gradlew build --no-daemon

      - name: Run tests
        run: ./gradlew test --no-daemon

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.AZURE_WEBAPP_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
```

2. **Configure os Secrets no GitHub**:
   - Vá em Settings > Secrets and variables > Actions
   - Adicione: `AZURE_WEBAPP_PUBLISH_PROFILE`

### 🔧 Configuração Manual (Alternativa)

Se preferir configurar manualmente:

#### 1. Criar Resource Group

```bash
az group create --name rg-dimdim-api --location "Brazil South"
```

#### 2. Criar App Service Plan

```bash
az appservice plan create \
  --name asp-dimdim-api \
  --resource-group rg-dimdim-api \
  --sku B1 \
  --is-linux
```

#### 3. Criar Web App

```bash
az webapp create \
  --name dimdim-api-webapp \
  --resource-group rg-dimdim-api \
  --plan asp-dimdim-api \
  --runtime "JAVA|21-java21"
```

#### 4. Criar SQL Server

```bash
az sql server create \
  --name dimdim-sql-server \
  --resource-group rg-dimdim-api \
  --location "Brazil South" \
  --admin-user dimdimadmin \
  --admin-password "SuaSenhaSegura123!"
```

#### 5. Criar SQL Database

```bash
az sql db create \
  --name dimdim-database \
  --resource-group rg-dimdim-api \
  --server dimdim-sql-server \
  --service-objective S0
```

#### 6. Configurar Firewall do SQL

```bash
az sql server firewall-rule create \
  --resource-group rg-dimdim-api \
  --server dimdim-sql-server \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

#### 7. Criar Application Insights

```bash
az monitor app-insights component create \
  --app appi-dimdim-api \
  --location "Brazil South" \
  --resource-group rg-dimdim-api
```

## 📚 API Endpoints

### Usuários

#### GET /api/usuarios

Lista todos os usuários

```json
[
  {
    "id": 1,
    "nome": "João Silva",
    "email": "joao@email.com",
    "cpf": "12345678901",
    "telefone": "(11) 99999-9999",
    "endereco": "Rua das Flores, 123",
    "saldo": 1000.0,
    "ativo": true,
    "dataCriacao": "2024-01-01T10:00:00",
    "dataAtualizacao": "2024-01-01T10:00:00"
  }
]
```

#### POST /api/usuarios

Cria novo usuário

```json
{
  "nome": "Maria Santos",
  "email": "maria@email.com",
  "cpf": "98765432109",
  "telefone": "(11) 88888-8888",
  "endereco": "Av. Paulista, 456"
}
```

#### PUT /api/usuarios/{id}

Atualiza usuário existente

#### DELETE /api/usuarios/{id}

Desativa usuário (soft delete)

### Transações

#### GET /api/transacoes

Lista todas as transações

#### POST /api/transacoes

Cria nova transação

```json
{
  "valor": 500.0,
  "tipo": "DEPOSITO",
  "descricao": "Depósito inicial",
  "usuarioId": 1
}
```

#### PUT /api/transacoes/{id}

Atualiza transação existente

#### DELETE /api/transacoes/{id}

Remove transação

### Tipos de Transação

- `DEPOSITO`: Adiciona valor ao saldo
- `SAQUE`: Remove valor do saldo
- `TRANSFERENCIA_ENVIADA`: Remove valor do saldo
- `TRANSFERENCIA_RECEBIDA`: Adiciona valor ao saldo
- `PAGAMENTO`: Remove valor do saldo
- `RECEBIMENTO`: Adiciona valor ao saldo

## 🔍 Monitoramento com Application Insights

### Configuração

1. Crie um recurso Application Insights no Azure
2. Copie a Instrumentation Key
3. Configure a variável de ambiente:
   ```
   APPINSIGHTS_INSTRUMENTATIONKEY=sua-chave-aqui
   ```

### Métricas Disponíveis

- Requests por minuto
- Tempo de resposta
- Taxa de erro
- Dependências (banco de dados)
- Exceções
- Logs customizados

### Acesso aos Dados

- Portal Azure > Application Insights > Live Metrics
- Logs Analytics para consultas avançadas

## 🧪 Testes da API

### Usando Postman/Insomnia

#### 1. Criar Usuário

```http
POST http://localhost:8080/api/usuarios
Content-Type: application/json

{
  "nome": "Teste Usuario",
  "email": "teste@email.com",
  "cpf": "11122233344",
  "telefone": "(11) 77777-7777",
  "endereco": "Rua Teste, 123"
}
```

#### 2. Criar Transação

```http
POST http://localhost:8080/api/transacoes
Content-Type: application/json

{
  "valor": 1000.00,
  "tipo": "DEPOSITO",
  "descricao": "Depósito inicial",
  "usuarioId": 1
}
```

#### 3. Consultar Usuário

```http
GET http://localhost:8080/api/usuarios/1
```

#### 4. Consultar Transações do Usuário

```http
GET http://localhost:8080/api/transacoes/usuario/1
```

### Usando curl

```bash
# Criar usuário
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@email.com",
    "cpf": "12345678901"
  }'

# Criar transação
curl -X POST http://localhost:8080/api/transacoes \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 500.00,
    "tipo": "DEPOSITO",
    "descricao": "Depósito inicial",
    "usuarioId": 1
  }'
```

## 🔧 Configurações Avançadas

### Variáveis de Ambiente para Produção

```bash
DB_SERVER=dimdim-server.database.windows.net
DB_PORT=1433
DB_NAME=dimdim_db
DB_USERNAME=dimdim_admin
DB_PASSWORD=SenhaSegura123!
APPINSIGHTS_INSTRUMENTATIONKEY=abc123-def456-ghi789
```

### Configurações de Log

```properties
logging.level.br.com.fiap.API.Java=INFO
logging.level.org.springframework.web=INFO
logging.level.org.hibernate.SQL=WARN
```

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Erro de Conexão com Banco

- Verifique as credenciais no `application.properties`
- Confirme se o firewall do Azure permite conexões
- Teste a conectividade com telnet

#### 2. Erro de Deploy

- Verifique se todas as dependências estão no `build.gradle`
- Confirme se as variáveis de ambiente estão configuradas
- Verifique os logs do App Service no portal Azure

#### 3. Erro de Application Insights

- Confirme se a Instrumentation Key está correta
- Verifique se o recurso Application Insights está ativo
- Aguarde alguns minutos para os dados aparecerem

## 📁 Estrutura do Projeto

```
API-Java/
├── src/main/java/br/com/fiap/API/Java/
│   ├── entity/
│   │   ├── Usuario.java
│   │   └── Transacao.java
│   ├── repository/
│   │   ├── UsuarioRepository.java
│   │   └── TransacaoRepository.java
│   ├── controller/
│   │   ├── UsuarioController.java
│   │   └── TransacaoController.java
│   ├── dto/
│   │   ├── UsuarioDTO.java
│   │   └── TransacaoDTO.java
│   └── ApiJavaApplication.java
├── src/main/resources/
│   └── application.properties
├── database/
│   └── ddl_tabelas.sql
├── scripts/
│   ├── create-resources.sh
│   └── deploy-app.sh
├── build.gradle
└── README.md
```

## 👥 Integrantes do Grupo

- **Nome**: [Eduardo Miguel Forato Monteiro] - RM: [RM55871]
- **Nome**: [Cicero Gabriel Oliveira Serafim] - RM: [RM556996]
- **Nome**: [Murillo Sant'Anna - RM557183] - RM: [RM557183]
- **Nome**: [Nome do Integrante 4] - RM: [RM]

**Disciplina**: Cloud Computing - FIAP  
**Projeto**: DimDim API - Sistema de Gestão Financeira  
**Semestre**: [2S25
