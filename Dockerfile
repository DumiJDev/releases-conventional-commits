# ==============================================================================
# Etapa 1: Build (Compilação e empacotamento da aplicação)
# ==============================================================================
# Nota: Substitua o 'eclipse-temurin' ou use imagens oficiais que forneçam o JDK 25.
FROM eclipse-temurin:25-jdk-jammy AS builder

WORKDIR /build

# 1. Copia apenas os ficheiros de configuração do Maven/Gradle para aproveitar o cache do Docker
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# 2. Descarrega as dependências sem compilar o código fonte (otimização de cache)
RUN ./mvnw dependency:go-offline -B

# 3. Copia o código fonte e gera o ficheiro JAR da aplicação
COPY src src
RUN ./mvnw clean package -DskipTests

# ==============================================================================
# Etapa 2: Runtime (Ambiente de execução final e otimizado)
# ==============================================================================
# Nota: Para o Java 25, a própria documentação da Spring recomenda imagens normais 
# e o uso de AOT caches para otimizar a inicialização em contentores.
FROM eclipse-temurin:25-jre-jammy AS runner

# Criação de um utilizador sem privilégios de root por motivos de segurança
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

WORKDIR /app

# Define a porta padrão do Spring Boot
EXPOSE 8080

# Copia apenas o ficheiro JAR final gerado na primeira etapa
COPY --from=builder /build/target/*.jar app.jar

# Configurações recomendadas para execução em contentor (memória dinâmica)
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
