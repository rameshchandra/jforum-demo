#!/bin/bash -x

## Copy agent jar files from build dir and create exclusion file for
## jforum

ROOT=$(dirname $(readlink -f $0))
ROOT=$(dirname $ROOT)

mkdir -p $ROOT/agent
cp -f $ROOT/../filterer/agent/bootstrap/target/agent-bootstrap-0.0.1-SNAPSHOT.jar $ROOT/agent
cp -f $ROOT/../filterer/agent/main/target/agent-main-0.0.1-SNAPSHOT.jar $ROOT/agent
cat >> $ROOT/agent/excludedClasses.txt <<EOF
java
javax
sun
com.sun
nerati
com.nerati
org.apache
org.xml
org.w3c
org.jcp
org.hsqldb
org.quartz
EOF
