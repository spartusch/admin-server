FROM gradle:4.10-jdk10-slim

ADD settings.gradle .
ADD build.gradle .
ADD src src
RUN gradle build

FROM openjdk:10-jre-slim
ENV SERVER_PORT=18000

COPY --from=0 /home/gradle/build/libs/*.jar .
EXPOSE $SERVER_PORT
ENTRYPOINT exec java $JAVA_OPTS -Dserver.port=$SERVER_PORT -jar /*.jar
