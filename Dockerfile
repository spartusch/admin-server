FROM adoptopenjdk:11-jdk-hotspot as builder
WORKDIR /application
# Set up gradle
COPY gradlew .
COPY gradle gradle
RUN chmod +x gradlew
# Copy source
COPY settings.gradle .
COPY build.gradle .
COPY src src
# Build
RUN ./gradlew --no-daemon bootJar

FROM adoptopenjdk:11-jre-hotspot
EXPOSE 8080
WORKDIR /application
COPY --from=builder /application/build/libs/*.jar .
ENTRYPOINT /application/*.jar --server.port=8080
