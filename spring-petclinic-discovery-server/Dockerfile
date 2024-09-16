# build using "docker build ./ -t $ARTIFACT_NAME --build-arg VERSION=1.2.3.4"
FROM mcr.microsoft.com/openjdk/jdk:17-mariner as runtime

ENV BUILD_VERSION=${VERSION_ARG}
ENV ARTIFACT_NAME=${ARTIFACT_NAME_ARG}
ENV PORT=8761

WORKDIR /

ADD ./${ARTIFACT_NAME_ARG}-${VERSION_ARG}.jar /${ARTIFACT_NAME_ARG}-${VERSION_ARG}.jar
ADD ./ai.jar /ai.jar

EXPOSE 8761 8778 9779

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-javaagent:/ai.jar","-jar","/${ARTIFACT_NAME_ARG}-${VERSION_ARG}.jar"]