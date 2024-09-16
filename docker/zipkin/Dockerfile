FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu as build

VOLUME /tmp
WORKDIR /

RUN apt-get update && apt-get install -y wget
RUN wget -q -O ai.jar https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.4.12/applicationinsights-agent-3.4.12.jar

FROM openzipkin/zipkin
ADD ./k8s ./k8s
COPY --from=build ./ai.jar /ai.jar
ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions"
ENV -Djava.security.egd=file:/dev/./urandom
ENV JAVA_TOOL_OPTIONS="-javaagent:/ai.jar"

ENV BUILD_VERSION=${VERSION_ARG}
ENV ARTIFACT_NAME=${ARTIFACT_NAME_ARG}
