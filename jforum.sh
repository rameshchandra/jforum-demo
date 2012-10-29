#!/bin/bash -x

## Run jforum

ROOT=$(cd $(dirname $0); pwd)
ROOT=$(dirname $ROOT)

export CATALINA_HOME=$ROOT/apache-tomcat-6.0.36
export CATALINA_PID=$CATALINA_HOME/tomcat.pid

CATALINA_SH=$CATALINA_HOME/bin/catalina.sh

TOMCAT_TGZ=${CATALINA_HOME}.tar.gz
TOMCAT_PORT=8100
setup_tomcat() {
    if [ ! -d $CATALINA_HOME ]; then
	tar -C $ROOT -zxf $TOMCAT_TGZ || exit 1
	
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

AGENT_PORT=8200
AGENT_JAR=$ROOT/agent/agent-bootstrap-0.0.1-SNAPSHOT.jar

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