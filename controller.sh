#!/bin/bash -x

## Run the controller

THISDIR=$(cd $(dirname $0); pwd)
ROOT=$(dirname $THISDIR)

CTRL_DIR=$ROOT/controller
DIST=distribution-0.0.1-SNAPSHOT

rm -rf $CTRL_DIR
mkdir -p $CTRL_DIR

if [ X"$OS" = X"Windows_NT" ]; then
    (cd $CTRL_DIR; unzip $ROOT/../filterer/controller/distribution/target/$DIST.zip)
else
    (cd $CTRL_DIR; tar -zxf $ROOT/../filterer/controller/distribution/target/$DIST.tar.gz)
fi

cp -r $ROOT/../filterer-web-client/mockserver/src/static/ $CTRL_DIR/$DIST/

cd $CTRL_DIR/$DIST/
java -Dcom.nerati.filter.controller.statics.externalDir=$CTRL_DIR/$DIST/static -jar bin/felix.jar
