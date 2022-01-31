#!/sbin/openrc-run

# set up env vars
TARGET_FILE=/usr/local/bin/melodybot/JMusicBot-0.36-All.jar
CONFIG=/usr/local/etc/melodybot/config.txt

# specific to openrc
pidfile="/var/run/${RC_SVCNAME}.pid"
# and since we're running a Java process that doesn't know anything about daemonizing...
command_background=true
command="/usr/bin/java"
command_args="-Dnogui=true -Dconfig.file=${CONFIG} -jar ${TARGET_FILE}"


depend () {
  provide melodybot
}