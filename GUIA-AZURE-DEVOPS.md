# 🚀 Guia Completo - Azure DevOps Pipeline DimDim API

## Checkpoint 3 - Cloud Computing FIAP

---

## 📋 Checklist de Entrega

### ✅ Requisitos Obrigatórios

- [x] Projeto Java com Spring Boot
- [x] Banco de Dados em nuvem (Azure SQL Database)
- [x] Mínimo 2 tabelas com relacionamento (usuarios ↔ transacoes)
- [x] Pipeline de CI com testes automáticos (JUnit)
- [x] Pipeline de CD para deploy automático
- [x] Arquivo YAML do pipeline (`azure-pipelines.yml`)
- [x] Dockerfile para containerização
- [x] docker-compose.yml
- [x] Script SQL renomeado (`database/script.sql`)
- [x] Exemplos de API em JSON (`api-examples/operacoes-api.json`)
- [x] Branch policies configuradas
- [x] Testes unitários implementados

---

## 🎯 Passos para Configuração

### 1️⃣ Criar Projeto no Azure DevOps

1. Acesse: https://dev.azure.com
2. Criar organização (se não tiver)
3. Criar projeto: **"DimDim API Migration"**
4. Work tracking: **Agile**
5. Version control: **Git**
6. Clicar em **"Create"**

---

### 2️⃣ Azure Boards - Criar Work Item

1. Vá em **Boards** > **Work Items**
2. Clique em **New Work Item** > **Task**
3. **Título**: `Implementar DimDim API no Azure DevOps`
4. **Description**: `Migração da DimDim API com pipeline CI/CD completo`
5. **Assigned to**: Seu nome
6. **State**: Mudar para **Active**
7. Clique em **Save**

---

### 3️⃣ Azure Repos - Importar Código

#### Opção A: Push via Git (Recomendado)

```bash
# No terminal do projeto
git remote add azure-devops <URL_DO_SEU_AZURE_REPOS>
git push azure-devops main
```

#### Opção B: Importar via Interface

1. **Repos** > **Files** > **Import repository**
2. Colar URL do repositório
3. Selecionar branch
4. **Import**

---

### 4️⃣ Configurar Branch Policies (Main)

1. **Repos** > **Branches**
2. Menu de 3 pontos ao lado de `main` > **Branch policies**
3. Configurar:

   ✅ **Require a minimum number of reviewers**: 1

   ✅ **Add automatic reviewers**: Adicionar `pf0841@fiap.com.br` como **Contributor**

   ✅ **Check for linked work items**: Enabled

   ✅ **Check for comment resolution**: Enabled

   ✅ **Require build validation**: Selecionar pipeline (será criado depois)

4. **Save changes**

---

### 5️⃣ Criar Branch para Tarefa

1. Vá em **Boards** > abra sua Task
2. Botão **Create Branch** (topo do card)
3. Branch será criada automaticamente: `task-XXX-implementar-dimdim-api`
4. Trabalhe nessa branch

---

### 6️⃣ Configurar Pipeline de Build (CI)

#### 6.1 Criar o Pipeline

1. **Pipelines** > **Pipelines** > **New Pipeline**
2. **Where is your code?**: Azure Repos Git
3. **Select a repository**: Seu repo
4. **Configure your pipeline**: YAML
5. Selecionar branch: `main`
6. Azure DevOps detectará o `azure-pipelines.yml`
7. **Review** > **Run** (executa manualmente)

#### 6.2 Configurar Service Connection

1. **Project Settings** > **Service Connections**
2. **New Service Connection**
3. **Azure Resource Manager** > **Next**
4. **Workload Identity federation** > **Next**
5. Escolher Subscription do Azure
6. Resource Group: `rg-dimdim-api`
7. **Security**: Marcar "Grant access to all pipelines"
8. **Save** com nome: `Azure Service Connection`

#### 6.3 Executar Pipeline

1. **Pipelines** > selecionar pipeline
2. **Run pipeline**
3. Branch: `main`
4. **Run**
5. Aguardar build (verificar logs)

---

### 7️⃣ Configurar Pipeline de Release (CD)

#### 7.1 Criar Pipeline de Release

1. **Pipelines** > **Releases** > **New Pipeline**
2. **Empty job**
3. **Artifacts** > **Add** > **Build**
4. Source (type): Build
5. Project: Seu projeto
6. Source (build pipeline): Selecionar pipeline de build
7. Default version: Latest
8. **Add**

#### 7.2 Configurar Stage

1. Clique em **"Stage 1"**
2. Renomear para: `Production`
3. **Deployment queue**: Configurar variáveis:

```yaml
APP_NAME: dimdim-api-webapp
RESOURCE_GROUP: rg-dimdim-api
```

#### 7.3 Adicionar Tasks ao Stage

Na aba **Tasks**:

**Task 1: Azure App Service deploy**

- Azure subscription: Azure Service Connection
- App Service type: App Service (Linux)
- App Service name: `dimdim-api-webapp`
- Package or folder: `$(System.DefaultWorkingDirectory)/**/*.jar`
- Startup command: `java -jar -Dserver.port=8080 api-java-*.jar`

**Task 2: Azure CLI (Verificação)**

- Azure subscription: Azure Service Connection
- Script type: Inline
- Script:

```bash
echo "Verificando status..."
az webapp show --name dimdim-api-webapp --resource-group rg-dimdim-api --query state
```

#### 7.4 Salvar e Executar Release

1. **Save**
2. **Create Release**
3. Version: selecionar build
4. **Create**
5. Aguardar deploy

---

### 8️⃣ Execução Ponta a Ponta

#### 8.1 Fazer Alteração no Código

```bash
# Na branch criada (task-XXX-implementar-dimdim-api)
git checkout task-XXX-implementar-dimdim-api

# Fazer uma pequena alteração
# Por exemplo: adicionar comentário em UsuarioController.java
# Ou modificar uma mensagem de log
```

#### 8.2 Commit e Push

```bash
git add .
git commit -m "feat: melhoria na documentação da API"
git push azure-devops task-XXX-implementar-dimdim-api
```

#### 8.3 Criar Pull Request

1. **Repos** > **Pull Requests**
2. **New Pull Request**
3. Source: `task-XXX-implementar-dimdim-api`
4. Target: `main`
5. Título: "Implementar DimDim API no Azure DevOps"
6. Vincular Work Item: Selecionar sua Task
7. **Create**

#### 8.4 Aprovar e Fazer Merge

1. Revisar as mudanças
2. Aprovar PR (você mesmo)
3. Em **Complete**:
   - **Don't delete source branch**: ✅ Ativar
   - **Complete associated work items**: ✅ Ativar
4. **Complete Merge**

---

### 9️⃣ Execução Automática

Após o merge:

✅ **Pipeline de Build** executa automaticamente  
✅ **Testes Unitários** rodam  
✅ **Pipeline de Release** executa automaticamente  
✅ **Deploy** é feito para Azure App Service

Verificar em:

- **Pipelines** > Logs do build
- **Releases** > Status do deploy
- **Application Insights** > Métricas

---

## 📊 Arquivos de Entrega

| Arquivo                           | Localização      | Descrição                    |
| --------------------------------- | ---------------- | ---------------------------- |
| `azure-pipelines.yml`             | Raiz do projeto  | Pipeline YAML de CI/CD       |
| `Dockerfile`                      | Raiz do projeto  | Containerização da aplicação |
| `docker-compose.yml`              | Raiz do projeto  | Orquestração de containers   |
| `database/script.sql`             | `database/`      | DDL completo das tabelas     |
| `api-examples/operacoes-api.json` | `api-examples/`  | Exemplos de chamadas API     |
| Testes Unitários                  | `src/test/java/` | Controller tests (JUnit)     |

---

## 🧪 Executar Testes Localmente

```bash
# Executar todos os testes
./gradlew test

# Executar testes específicos
./gradlew test --tests "UsuarioControllerTest"
./gradlew test --tests "TransacaoControllerTest"

# Ver relatório de testes
./gradlew test --info
```

---

## 🐳 Docker

### Build da Imagem

```bash
docker build -t dimdim-api:latest .
```

### Executar Container

```bash
docker run -p 8080:8080 --name dimdim-api dimdim-api:latest
```

### Docker Compose

```bash
# Subir aplicação
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar aplicação
docker-compose down
```

---

## 📝 Testes da API (CRUD)

### Usuários

**POST** `/api/usuarios`

```json
{
  "nome": "João Silva",
  "email": "joao@email.com",
  "cpf": "12345678901",
  "telefone": "(11) 99999-9999",
  "endereco": "Rua das Flores, 123"
}
```

**GET** `/api/usuarios` - Listar todos  
**GET** `/api/usuarios/1` - Buscar por ID  
**PUT** `/api/usuarios/1` - Atualizar  
**DELETE** `/api/usuarios/1` - Desativar

### Transações

**POST** `/api/transacoes`

```json
{
  "valor": 1000.0,
  "tipo": "DEPOSITO",
  "descricao": "Depósito inicial",
  "usuarioId": 1
}
```

**GET** `/api/transacoes` - Listar todas  
**GET** `/api/transacoes/usuario/1` - Por usuário  
**PUT** `/api/transacoes/1` - Atualizar  
**DELETE** `/api/transacoes/1` - Remover

---

## 🎥 Gravar Vídeo de Evidência

### Cenas Obrigatórias no Vídeo

1. **Task criada** no Azure Boards (mostrar título e status)
2. **Branch criada** a partir da Task
3. **Alteração no código** (mostrar diff)
4. **Commit e push**
5. **Criação do Pull Request** (mostrar integração com Work Item)
6. **Aprovação do PR**
7. **Merge** sem deletar branch
8. **Pipeline de Build executando** (mostrar logs de testes)
9. **Resultados dos testes** publicados
10. **Pipeline de Release executando**
11. **Deploy bem-sucedido**
12. **CRUD no App em nuvem** (testar em produção)
13. **Evidência no banco** (mostrar registros no Azure SQL)

### Dicas para o Vídeo

- ✅ Narração clara e objetiva
- ✅ Captura de tela em boa resolução
- ✅ Sem pausas longas ou cortes indevidos
- ✅ Mostrar todos os logs
- ✅ Testar ambos os CRUDs (usuarios e transacoes)

---

## 👥 Adicionar Professor como Admin

1. **Project Settings** > **Permissions**
2. **Users**
3. Adicionar: `pf0841@fiap.com.br`
4. Level: **Basic**
5. Project: **Contributor**
6. **Add**

---

## 📄 PDF de Entrega

### Conteúdo Obrigatório

1. **Folha de Rosto**

   - Nome do grupo
   - RM e nome completo de cada integrante
   - Disciplina e Semestre

2. **Link do Projeto**

   - URL do Azure DevOps: `https://dev.azure.com/{org}/{projeto}`

3. **Link do Vídeo**
   - URL do YouTube (privado com acesso via link)

---

## ⚠️ Penalidades a Evitar

| Erro                                            | Penalidade              |
| ----------------------------------------------- | ----------------------- |
| Sem Task criada ou sem relacionamento com Repos | -1 ponto                |
| Apenas uma tabela                               | -3 pontos               |
| Banco H2 ou Oracle FIAP                         | -5 pontos               |
| Branch main sem políticas                       | -2 pontos               |
| Sem PR solicitado                               | -1 ponto                |
| Pipeline sem testes automáticos                 | -2 pontos               |
| Professor sem acesso                            | Correção inviabilizada  |
| Entrega fora do padrão PDF                      | -0.5 ponto              |
| Sem script.sql                                  | -1 ponto                |
| Sem código fonte                                | Correção inviabilizada  |
| Sem Dockerfile/docker-compose (se container)    | -4 pontos               |
| Vídeo baixa qualidade                           | -3 pontos               |
| Atraso na entrega                               | -3 pontos/hora (máx 2h) |

---

## 🎓 Integrantes do Grupo

- **Nome**: Eduardo Miguel Forato Monteiro - **RM**: 55871
- **Nome**: Cicero Gabriel Oliveira Serafim - **RM**: 556996
- **Nome**: Murillo Sant'Anna - **RM**: 557183
- **Nome**: [Nome Integrante 4] - **RM**: [RM]

---

**Disciplina**: Cloud Computing - FIAP  
**Projeto**: DimDim API - Sistema de Gestão Financeira  
**Semestre**: 2S25  
**Checkpoint**: 3º - Pipeline CI/CD
