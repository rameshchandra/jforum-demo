#!/bin/bash -x

## checkout jforum repo from google code

ROOT=$(cd $(dirname $0); pwd)
ROOT=$(dirname $ROOT)

cd $ROOT
svn checkout http://jforum2.googlecode.com/svn/trunk/ jforum2-googlecode
