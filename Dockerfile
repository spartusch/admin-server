FROM adoptopenjdk:11-jre-hotspot
EXPOSE 8080
COPY build/libs/*.jar .
ENTRYPOINT java $JAVA_OPTS -Dserver.port=8080 -jar /*.jar
