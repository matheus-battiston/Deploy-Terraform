# Estágio de construção
FROM maven:3.8.3-openjdk-17-slim AS build
WORKDIR /app
COPY src /app/src
COPY pom.xml /app
RUN mvn -f /app/pom.xml clean package -DskipTests

# Estágio de execução
FROM openjdk:17-slim
WORKDIR /app
COPY --from=build /app/target/account-0.0.1-SNAPSHOT.jar /app/account-0.0.1.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/account-0.0.1.jar"]
