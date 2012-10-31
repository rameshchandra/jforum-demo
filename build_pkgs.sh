#!/bin/bash -x

THISDIR=$(cd $(dirname $0); pwd)
ROOT=$(dirname $THISDIR)

## if necessary clone filterer and filterer-web-client repos
for repo in filterer filterer-web-client; do
    if [ ! -d $ROOT/$repo ]; then
        (cd $ROOT; git clone git@github.com:nerati/$repo) || exit 1
    fi
done

## build filterer packages
(cd $ROOT/filterer; git pull; mvn clean package -Dmaven.test.skip=true) || exit 1

## main branch of filterer-web-client is webclient
(cd $ROOT/filterer-web-client; git checkout webclient; git pull) || exit 1

