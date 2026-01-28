FROM eclipse-temurin:21-jdk AS builder

ARG MINECRAFT_VERSION
ARG ENABLE_FLAG=false

RUN echo $MINECRAFT_VERSION

RUN mkdir /code /buildTools
RUN apt-get update && apt-get install -y maven openjdk-21-jdk wget git

WORKDIR /buildTools
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev $MINECRAFT_VERSION
RUN wget -O maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz

WORKDIR /code

FROM eclipse-temurin:21-alpine

# Kopiowanie spigot-api repozytorium
COPY --from=builder /root/.m2/repository/org/spigotmc/spigot-api /root/.m2/repository/org/spigotmc/spigot-api
COPY --from=builder /buildTools/maven.tar.gz /root/maven.tar.gz

RUN tar -xzf /root/maven.tar.gz -C /root/ && rm /root/maven.tar.gz

RUN mkdir /code
WORKDIR /code
ENTRYPOINT ["/root/apache-maven-3.9.12/bin/mvn", "package"]