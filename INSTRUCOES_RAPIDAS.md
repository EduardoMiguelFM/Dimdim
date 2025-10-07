# ⚡ Instruções Rápidas - DimDim API

## 🚨 IMPORTANTE: Configure o banco de dados primeiro!

A aplicação **NÃO FUNCIONA** sem um banco de dados configurado.

## 🚀 Passos Rápidos

### 1. **Configurar Banco de Dados** (OBRIGATÓRIO)
Escolha uma opção:

#### Opção A: H2 (Mais Rápido - Apenas Testes)
Edite `src/main/resources/application.properties`:
```properties
# Substitua as configurações do SQL Server por:
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect
```

#### Opção B: SQL Server Local
1. Instale SQL Server Express
2. Crie banco: `CREATE DATABASE dimdim_db;`
3. Execute o script `database/ddl_tabelas.sql`
4. Configure `application.properties` com suas credenciais

#### Opção C: Azure SQL Server
1. Crie recursos no Azure (veja `CONFIGURACAO_BANCO.md`)
2. Execute o script `database/ddl_tabelas.sql`
3. Configure `application.properties` com credenciais Azure

### 2. **Executar Aplicação**
```bash
./gradlew bootRun
```

### 3. **Testar API**
```bash
# Testar se está funcionando
curl http://localhost:8080/api/usuarios

# Criar usuário
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@email.com","cpf":"12345678901"}'

# Criar transação
curl -X POST http://localhost:8080/api/transacoes \
  -H "Content-Type: application/json" \
  -d '{"valor":500.00,"tipo":"DEPOSITO","descricao":"Depósito inicial","usuarioId":1}'
```

## ✅ Verificar se está funcionando

1. **Aplicação inicia sem erros** ✅
2. **Endpoint `/api/usuarios` responde** ✅
3. **Pode criar usuário via POST** ✅
4. **Pode criar transação via POST** ✅

## 🐛 Se não funcionar

1. **Verifique os logs** da aplicação
2. **Confirme se o banco está configurado** corretamente
3. **Teste a conexão** com o banco
4. **Consulte** `CONFIGURACAO_BANCO.md` para mais detalhes

## 🎯 Próximos Passos

1. ✅ Configure o banco de dados
2. ✅ Teste a aplicação localmente
3. ✅ Faça o deploy no Azure
4. ✅ Grave o vídeo demonstrando

---

**💡 Dica**: Para testes rápidos, use H2. Para produção, use SQL Server.
