FROM alpine:latest as builder
# Install JDK
RUN apk add --no-cache openjdk17-jdk
# Set up project
WORKDIR /application
# Set up gradle
COPY gradlew .
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew --version
# Copy source
COPY settings.gradle .
COPY build.gradle .
COPY gradle.lockfile .
COPY src src
# Build
RUN ./gradlew --no-daemon bootJar

FROM alpine:latest
EXPOSE 8080
ENV server.port 8080
RUN apk add --no-cache openjdk17-jre-headless
RUN addgroup -S spring && adduser -S spring -G spring
WORKDIR /application
USER spring:spring
COPY --from=builder /application/build/libs/*.jar .
ENTRYPOINT java -jar /application/*.jar
