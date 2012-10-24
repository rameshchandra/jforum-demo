#!/bin/bash -x

ROOT=$(dirname $(readlink -f $0))

export CATALINA_HOME=$ROOT/apache-tomcat-6.0.36
export CATALINA_PID=$CATALINA_HOME/tomcat.pid

CATALINA_SH=$CATALINA_HOME/bin/catalina.sh

stop_tomcat() {
    $CATALINA_SH stop
    ps -aefl | grep java | grep catalina | awk '{print $4}' | xargs kill
    rm -f $CATALINA_PID
}

WEBAPPSDIR=$ROOT/apache-tomcat-6.0.36/webapps/
JFORUM_SRCDIR=$ROOT/jforum2-read-only/
JFORUM_APPDIR=$WEBAPPSDIR/jforum/
JFORUM_CONFIG=$ROOT/config
JFORUM_CFGBAK=$ROOT/config.bak

backup_jforum_cfg() {
    rm -rf $JFORUM_CFGBAK
    if [ -d $JFORUM_APPDIR ]; then
	mkdir -p $JFORUM_CFGBAK/hsqldb 
	cp $JFORUM_APPDIR/WEB-INF/config/database/hsqldb/* $JFORUM_CFGBAK/hsqldb/
	cp $JFORUM_APPDIR/WEB-INF/config/* $JFORUM_CFGBAK/
    fi
}

deploy_jforum() {
    rm -rf $JFORUM_APPDIR $WEBAPPSDIR/jforum*.war
    cp $JFORUM_SRCDIR/target/jforum.war $WEBAPPSDIR
    mkdir $JFORUM_APPDIR
    (cd $JFORUM_APPDIR; jar -xvf $WEBAPPSDIR/jforum.war;)
}

restore_jforum_cfg() {
    SRCDIR=$JFORUM_CONFIG
    if [ -d $JFORUM_CFGBAK ]; then
	SRCDIR=$JFORUM_CFGBAK
    fi
    
    cp $SRCDIR/hsqldb/* $JFORUM_APPDIR/WEB-INF/config/database/hsqldb/
    cp $SRCDIR/* $JFORUM_APPDIR/WEB-INF/config/
}

stop_tomcat
backup_jforum_cfg
deploy_jforum
restore_jforum_cfg
$CATALINA_SH start