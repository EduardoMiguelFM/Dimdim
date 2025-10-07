# 📋 Instruções Completas - Projeto DimDim

## ✅ O que foi criado

Seu projeto DimDim está completo e pronto para deploy! Aqui está tudo que foi implementado:

### 🏗️ Estrutura do Projeto

```
API-Java/
├── src/main/java/br/com/fiap/API/Java/
│   ├── entity/
│   │   ├── Usuario.java (Tabela Master)
│   │   └── Transacao.java (Tabela Detail)
│   ├── repository/
│   │   ├── UsuarioRepository.java
│   │   └── TransacaoRepository.java
│   ├── controller/
│   │   ├── UsuarioController.java
│   │   └── TransacaoController.java
│   ├── dto/
│   │   ├── UsuarioDTO.java
│   │   └── TransacaoDTO.java
│   ├── config/
│   │   └── ApplicationInsightsConfig.java
│   └── ApiJavaApplication.java
├── src/main/resources/
│   └── application.properties (configurado para Azure)
├── database/
│   └── ddl_tabelas.sql (DDL completo)
├── scripts/
│   ├── create-resources.sh (Criar recursos Azure)
│   └── deploy-app.sh (Deploy da aplicação)
├── api-examples/
│   └── operacoes-api.json (Exemplos de JSON)
├── build.gradle (com todas as dependências)
├── README.md (documentação completa)
└── INSTRUCOES_PROJETO.md (este arquivo)
```

### 🗄️ Banco de Dados

- **2 tabelas relacionadas**: usuarios (master) e transacoes (detail)
- **Relacionamento**: One-to-Many com FK
- **DDL completo** com índices, triggers e dados de exemplo
- **Views e Stored Procedures** para relatórios

### 🌐 API REST Completa

- **CRUD completo** para Usuários e Transações
- **Validações** de dados de entrada
- **Regras de negócio** (controle de saldo, usuários ativos)
- **Paginação** e filtros avançados
- **CORS** configurado

### ☁️ Azure Ready

- **Application Insights** configurado
- **Azure SQL Server** configurado
- **Scripts CLI** para automação
- **Variáveis de ambiente** configuradas

## 🚀 Passos para Executar

### 1. Baixar Dependências

```bash
./gradlew build
```

### 2. Configurar Banco de Dados

1. Crie um banco SQL Server (local ou Azure)
2. Execute o script: `database/ddl_tabelas.sql`
3. Configure as credenciais em `application.properties`

### 3. Executar Localmente

```bash
./gradlew bootRun
```

Aplicação estará em: `http://localhost:8080`

### 4. Deploy no Azure (3 opções)

#### Opção A: Via IDE (Mais Fácil)

1. Instale plugin Azure no Eclipse/IntelliJ/VSCode
2. Configure Azure CLI: `az login`
3. Clique direito no projeto > "Deploy to Azure"
4. Configure as variáveis de ambiente

#### Opção B: Via Scripts CLI

1. Execute: `./scripts/create-resources.sh` (cria recursos)
2. Execute: `./scripts/deploy-app.sh` (faz deploy)

#### Opção C: Via GitHub Actions

1. Configure secrets no GitHub
2. Push para main branch
3. Deploy automático

## 📊 Testes da API

### Endpoints Principais

- `GET /api/usuarios` - Lista usuários
- `POST /api/usuarios` - Cria usuário
- `GET /api/transacoes` - Lista transações
- `POST /api/transacoes` - Cria transação

### Exemplos de JSON

Veja o arquivo `api-examples/operacoes-api.json` para todos os exemplos.

### Teste Rápido com curl

```bash
# Criar usuário
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@email.com","cpf":"12345678901"}'

# Criar depósito
curl -X POST http://localhost:8080/api/transacoes \
  -H "Content-Type: application/json" \
  -d '{"valor":500.00,"tipo":"DEPOSITO","descricao":"Depósito inicial","usuarioId":1}'
```

## 📋 Checklist para Entrega

### ✅ Arquivos Necessários

- [x] **Código fonte completo** (todas as classes criadas)
- [x] **DDL das tabelas** (`database/ddl_tabelas.sql`)
- [x] **Scripts CLI** (`scripts/create-resources.sh` e `scripts/deploy-app.sh`)
- [x] **How to completo** (`README.md` com instruções detalhadas)
- [x] **Exemplos JSON** (`api-examples/operacoes-api.json`)

### ✅ Funcionalidades

- [x] **2 tabelas relacionadas** (usuarios master, transacoes detail)
- [x] **FK configurada** (transacoes.usuario_id -> usuarios.id)
- [x] **API REST completa** (GET, POST, PUT, DELETE)
- [x] **Validações** de dados
- [x] **Regras de negócio** (controle de saldo)
- [x] **Application Insights** configurado
- [x] **Azure SQL Server** configurado

### ✅ Para o Vídeo

1. **Mostrar criação dos recursos** no portal Azure
2. **Mostrar deploy** da aplicação
3. **Testar cada operação** da API
4. **Mostrar persistência** no banco após cada operação
5. **Mostrar Application Insights** funcionando

### ✅ Para o PDF

- Nome do grupo
- RM e Nome dos integrantes
- Link do GitHub
- Link do vídeo
- Screenshots do processo

## 🎯 Próximos Passos

### 1. Testar Localmente

```bash
# Baixar dependências
./gradlew build

# Executar aplicação
./gradlew bootRun

# Testar endpoints
curl http://localhost:8080/api/usuarios
```

### 2. Criar Recursos Azure

```bash
# Login no Azure
az login

# Criar recursos (ajuste os nomes se necessário)
az group create --name rg-dimdim-fiap --location "Brazil South"
az sql server create --name dimdim-server --resource-group rg-dimdim-fiap --admin-user dimdim_admin --admin-password "DimDim@2024"
az sql db create --name dimdim_db --server dimdim-server --resource-group rg-dimdim-fiap
```

### 3. Deploy da Aplicação

- Use o plugin do IDE ou scripts CLI
- Configure as variáveis de ambiente
- Teste a aplicação na URL do Azure

### 4. Gravar Vídeo

- Mostre criação dos recursos
- Mostre deploy da aplicação
- Teste todas as operações CRUD
- Mostre dados persistindo no banco
- Mostre Application Insights

## 🔧 Configurações Importantes

### Variáveis de Ambiente Azure

```
DB_SERVER=seu-servidor.database.windows.net
DB_NAME=dimdim_db
DB_USERNAME=seu-usuario
DB_PASSWORD=sua-senha
APPINSIGHTS_INSTRUMENTATIONKEY=sua-chave
```

### URLs de Teste

- **Local**: `http://localhost:8080/api/usuarios`
- **Azure**: `https://dimdim-api.azurewebsites.net/api/usuarios`

## 📞 Suporte

Se tiver dúvidas:

1. Consulte o `README.md` completo
2. Verifique os exemplos em `api-examples/operacoes-api.json`
3. Execute os testes locais primeiro
4. Verifique os logs da aplicação

## 🎉 Parabéns!

Seu projeto DimDim está completo e atende todos os requisitos do checkpoint:

- ✅ Aplicação Web Java com Spring Boot
- ✅ 2 tabelas relacionadas (master-detail)
- ✅ Persistência em Azure SQL Server
- ✅ Deploy na nuvem Azure
- ✅ Application Insights configurado
- ✅ API REST completa com CRUD
- ✅ Documentação completa
- ✅ Scripts de automação

**Agora é só testar, fazer deploy e gravar o vídeo!** 🚀
