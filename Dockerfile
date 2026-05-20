FROM maven:3.9-eclipse-temurin-17 AS build

ARG HADOOP_VERSION=rel/release-3.4.1

RUN git clone --depth=1 --branch "${HADOOP_VERSION}" \
    https://github.com/apache/hadoop.git /hadoop

WORKDIR /hadoop
RUN mvn -pl hadoop-tools/hadoop-aws -am install -DskipTests -q --no-transfer-progress
RUN mvn -pl hadoop-tools/hadoop-aws test-compile -q --no-transfer-progress


FROM maven:3.9-eclipse-temurin-17

COPY --from=build /hadoop /hadoop
COPY --from=build /root/.m2 /root/.m2

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /hadoop
ENTRYPOINT ["/entrypoint.sh"]
