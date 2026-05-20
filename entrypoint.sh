#!/bin/bash
set -e

: "${S3_ENDPOINT:?S3_ENDPOINT is required}"
: "${S3_ACCESS_KEY:?S3_ACCESS_KEY is required}"
: "${S3_SECRET_KEY:?S3_SECRET_KEY is required}"
S3_BUCKET="${S3_BUCKET:-hadoop-s3a-test}"

if [[ "$S3_ENDPOINT" == https://* ]]; then
    SSL_ENABLED=true
else
    SSL_ENABLED=false
fi

cat > /hadoop/hadoop-tools/hadoop-aws/src/test/resources/auth-keys.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property>
    <name>test.fs.s3a.name</name>
    <value>s3a://${S3_BUCKET}/</value>
  </property>
  <property>
    <name>fs.contract.test.fs.s3a</name>
    <value>s3a://${S3_BUCKET}/</value>
  </property>
  <property>
    <name>fs.s3a.access.key</name>
    <value>${S3_ACCESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${S3_SECRET_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${S3_ENDPOINT}</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>
  <property>
    <name>fs.s3a.connection.ssl.enabled</name>
    <value>${SSL_ENABLED}</value>
  </property>
  <property>
    <name>test.fs.s3a.encryption.enabled</name>
    <value>false</value>
  </property>
  <property>
    <name>test.fs.s3a.sts.enabled</name>
    <value>false</value>
  </property>
  <property>
    <name>test.fs.s3a.create.storage.class.enabled</name>
    <value>false</value>
  </property>
  <property>
    <name>test.fs.s3a.performance.enabled</name>
    <value>false</value>
  </property>
  <property>
    <name>fs.s3a.scale.test.csvfile</name>
    <value> </value>
  </property>
</configuration>
EOF

MVN_ARGS="-pl hadoop-tools/hadoop-aws verify -Dtest=nothing -Dmaven.test.failure.ignore=false --no-transfer-progress"

if [ -n "${IT_TEST:-}" ]; then
    MVN_ARGS="$MVN_ARGS -Dit.test=${IT_TEST}"
fi

exec mvn $MVN_ARGS
