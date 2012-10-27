#!/bin/bash -x

## checkout jforum repo from google code

ROOT=$(dirname $(readlink -f $0))
ROOT=$(dirname $ROOT)

cd $ROOT
svn checkout http://jforum2.googlecode.com/svn/trunk/ jforum2-googlecode
