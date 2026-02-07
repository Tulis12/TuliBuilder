FROM eclipse-temurin:21-jdk AS builder

ARG MINECRAFT_VERSION
ARG ENABLE_FLAG=false

RUN echo $MINECRAFT_VERSION

RUN mkdir /code /buildTools
RUN apt-get update
RUN apt-get install -y maven openjdk-21-jdk wget git

WORKDIR /buildTools
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev $MINECRAFT_VERSION

WORKDIR /code

FROM eclipse-temurin:21-alpine

COPY --from=builder /root/.m2/repository/org/spigotmc/spigot-api /root/.m2/repository/org/spigotmc/spigot-api
RUN apk add --no-cache maven

RUN mkdir /code
WORKDIR /code
ENTRYPOINT ["mvn", "package"]