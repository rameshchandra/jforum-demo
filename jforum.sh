#!/bin/bash -x

## Run jforum

THISDIR=$(cd $(dirname $0); pwd)
ROOT=$(dirname $THISDIR)

TOMCAT_VERSION=apache-tomcat-6.0.36
export CATALINA_HOME=$ROOT/$TOMCAT_VERSION
export CATALINA_PID=$CATALINA_HOME/tomcat.pid

CATALINA_SH=$CATALINA_HOME/bin/catalina.sh

if [ X"$OS" = X"Windows_NT" ]; then
    TOMCAT_TGZ=$THISDIR/${TOMCAT_VERSION}-windows-x64.zip
else
    TOMCAT_TGZ=$THISDIR/${TOMCAT_VERSION}.tar.gz
fi

TOMCAT_PORT=8100
setup_tomcat() {
    if [ ! -d $CATALINA_HOME ]; then
        if [ X"$OS" = X"Windows_NT" ]; then
            (cd $ROOT; unzip $TOMCAT_TGZ) || exit 1
        else
            (cd $ROOT; tar -zxf $TOMCAT_TGZ) || exit 1
        fi
        
        ## change tomcat port
        sed -i'' -e "s/8080/$TOMCAT_PORT/g" $CATALINA_HOME/conf/server.xml

        ## setup admin privileges
        cat > $CATALINA_HOME/conf/tomcat-users.xml <<EOF
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <role rolename="manager-gui"/>
  <user username="admin" password="admin" roles="manager-gui"/>
</tomcat-users>
EOF

    fi
}

stop_tomcat() {
    $CATALINA_SH stop
    ps -aefl | grep java | grep catalina | awk '{print $4}' | xargs kill
    rm -f $CATALINA_PID
}

WEBAPPSDIR=$CATALINA_HOME/webapps/
JFORUM_SRCDIR=$ROOT/jforum2-googlecode/
JFORUM_APPDIR=$WEBAPPSDIR/jforum/
JFORUM_CONFIG=$THISDIR/jforum-initial-db
JFORUM_CFGBAK=$THISDIR/jforum-db

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
    cp $THISDIR/jforum-wars/jforum_v1.war $WEBAPPSDIR/jforum.war
    mkdir $JFORUM_APPDIR
    (cd $JFORUM_APPDIR; unzip $WEBAPPSDIR/jforum.war) || exit 1
}

AGENT_PORT=8200

if [ X"$OS" = X"Windows_NT" ]; then
    AGENT_JAR="`echo $ROOT/agent/agent-bootstrap-0.0.1-SNAPSHOT.jar | sed -e 's#^/c/#C:/#'`"
else
    AGENT_JAR=$ROOT/agent/agent-bootstrap-0.0.1-SNAPSHOT.jar
fi

setup_nerati_agent() {
    ## script to load agent jar and configure agent port
    cat > $CATALINA_HOME/bin/setenv.sh <<EOF
#!/bin/bash

CATALINA_OPTS="$CATALINA_OPTS -Dcom.nerati.agent.port=$AGENT_PORT -javaagent:$AGENT_JAR"
EOF
    chmod +x $CATALINA_HOME/bin/setenv.sh
}

restore_jforum_cfg() {
    SRCDIR=$JFORUM_CONFIG
    if [ -d $JFORUM_CFGBAK ]; then
        SRCDIR=$JFORUM_CFGBAK
    fi
    
    cp $SRCDIR/hsqldb/* $JFORUM_APPDIR/WEB-INF/config/database/hsqldb/
    cp $SRCDIR/* $JFORUM_APPDIR/WEB-INF/config/
}

setup_tomcat
stop_tomcat
setup_nerati_agent
backup_jforum_cfg
deploy_jforum
restore_jforum_cfg
$CATALINA_SH run     ## to run in foreground
#$CATALINA_SH start  ## to run in background