FROM gradle:7.6.1-jdk17 AS build
WORKDIR /app
COPY . .
RUN gradle build --no-daemon -x test

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY backend-0.0.1-SNAPSHOT.jar app.jar
RUN apt-get update && apt-get install -y curl

RUN addgroup --system javauser && adduser --system --no-create-home --ingroup javauser javauser
RUN chown -R javauser:javauser /app
USER javauser
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
