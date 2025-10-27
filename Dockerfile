# Dockerfile para DimDim API
# Checkpoint 3 - Cloud Computing FIAP

# Estágio 1: Build
FROM gradle:7.6-jdk17 AS build

WORKDIR /app

# Copiar arquivos de configuração do Gradle
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

# Copiar código fonte
COPY src ./src

# Build da aplicação
RUN gradle clean build -x test

# Estágio 2: Runtime
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copiar JAR do estágio de build
COPY --from=build /app/build/libs/*.jar app.jar

# Expor porta
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Variáveis de ambiente
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Comando para iniciar a aplicação
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

