#!/bin/bash -x

## Run the controller

ROOT=$(cd $(dirname $0); pwd)
ROOT=$(dirname $ROOT)

CTRL_DIR=$ROOT/controller
DIST=distribution-0.0.1-SNAPSHOT

rm -rf $CTRL_DIR
mkdir -p $CTRL_DIR
cp $ROOT/../filterer/controller/distribution/target/$DIST.tar.gz $CTRL_DIR
tar -C $CTRL_DIR -zxf $CTRL_DIR/$DIST.tar.gz
cp -r $ROOT/../filterer-web-client/mockserver/src/static/ $CTRL_DIR/$DIST/

cd $CTRL_DIR/$DIST/
java -Dcom.nerati.filter.controller.statics.externalDir=$CTRL_DIR/$DIST/static -jar bin/felix.jar

