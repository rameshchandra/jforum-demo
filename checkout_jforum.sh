#!/bin/bash -x

## checkout jforum repo from google code

THISDIR=$(cd $(dirname $0); pwd)
ROOT=$(dirname $THISDIR)

cd $ROOT
svn checkout http://jforum2.googlecode.com/svn/trunk/ jforum2-googlecode
