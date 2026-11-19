# ---------- Etapa 1: build com Maven ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# baixa as dependências primeiro para aproveitar o cache de camadas
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src
RUN mvn -q -B -DskipTests package && cp target/alagalerta-api-*.jar app.jar

# ---------- Etapa 2: imagem final só com o JRE ----------
FROM eclipse-temurin:21-jre-alpine

# usuário sem privilégios: a aplicação não roda como root
RUN addgroup -S alagalerta && adduser -S -G alagalerta -h /app alagalerta

WORKDIR /app
COPY --from=build --chown=alagalerta:alagalerta /build/app.jar app.jar

ENV SPRING_PROFILES_ACTIVE=postgres \
    PORT=8080 \
    JAVA_OPTS="-Xms256m -Xmx512m"

EXPOSE 8080

USER alagalerta

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
