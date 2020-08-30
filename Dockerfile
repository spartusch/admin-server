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
RUN adduser --system --group spring
COPY --from=builder /application/build/libs/*.jar .
RUN chown spring:spring /application/*.jar && chmod 544 /application/*.jar
USER spring:spring
ENTRYPOINT /application/*.jar --server.port=8080
