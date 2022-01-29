#!/bin/bash

if [ $# -lt 2 ]
then
	cmd="$(basename $0)"
	echo "syntax:  $cmd [cmd-path] [mc-install-dir]" >&2
	exit 1
fi

cmdpath="$1"
if [ ! -d "$cmdpath" ]
then
	echo "not a directory: '$cmdpath'" >&2
	exit 2
fi


installdir="$2"

if [ ! -d "$installdir" ]
then
	echo "not a directory: '$installdir'" >&2
	exit 2
fi


read -p "Starting heap size (default: 2560M)? " heap_start
[ -n "$heap_start" ] || heap_start=2560M

read -p "Maximum heap size (default: $heap_start)? " heap_max
[ -n "$heap_max" ] || heap_max="$heap_start"

# default is 6 hours
read -p "Auto-restart interval in minutes (default: 360)? " restart_interval
[ -n "$restart_interval" ] || restart_interval=360

read -p "Auto-restart warn time in seconds (default: 60)? " restart_warn
[ -n "$restart_warn" ] || restart_warn=60

read -p "Server start wait time in seconds (default: 100)? " start_wait_time
[ -n "$start_wait_time" ] || start_wait_time=100

read -p "Current world name (default: world)? " world_name
[ -n "$world_name" ] || world_name="world"

echo "Setting up Jolokia for JVM metrics collection..."
read -p "Jolokia version (default: 1.7.1)?" jolokia_version
[ -n "$jolokia_version" ] || jolokia_version=1.7.1

read -p "Jolokia port (default: 8778)? " jolokia_port
[ -n "$jolokia_port" ] || jolokia_port=8778

read -p "Jolokia bind address (default: localhost)? " jolokia_host
[ -n "$jolokia_host" ] || jolokia_host=localhost

read -p "Enable Jolokia auth (Y/N, default: N)? " jolokia_auth
if [ "$jolokia_auth" = "Y" -o "$jolokia_auth" = "y" ]
then
  jolokia_auth=1
else
  jolokia_auth=""
fi

jolokia_user=user
jolokia_pass=changeme
if [ -n "$jolokia_auth" ]
then
  read -p "Jolokia JMX username (default: user)? " jolokia_user
  read -p "Jolokia JMX password (default: changeme)? " jolkia_pass
fi

escidir="$(echo $installdir | sed 's/\//\\\//g')"

curl -LO "https://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/${jolokia_version}/jolokia-jvm-${jolokia_version}.jar"

cp commands/mc-system-start.sh $cmdpath/mc-system-start.sh
sed -i -e "s/::::TEMPLATE:MC_DIR::::/$escidir/g" "$cmdpath/mc-system-start.sh"

cp commands/mc-system-stop.sh $cmdpath/mc-system-stop.sh
sed -i -e "s/::::TEMPLATE:MC_DIR::::/$escidir/g" "$cmdpath/mc-system-stop.sh"

cp server-scripts/mc-system-refresher.sh $installdir/mc-system-refresher.sh
sed -i -e "s/::::TEMPLATE:MC_DIR::::/$escidir/g" "$installdir/mc-system-refresher.sh"
sed -i -e "s/::::TEMPLATE:RESTART_MINS::::/$restart_interval/g" "$installdir/mc-system-refresher.sh"
sed -i -e "s/::::TEMPLATE:RESTART_WARN::::/$restart_warn/g" "$installdir/mc-system-refresher.sh"
sed -i -e "s/::::TEMPLATE:START_WAIT::::/$start_wait_time/g" "$installdir/mc-system-refresher.sh"
sed -i -e "s/::::TEMPLATE:CUR_WORLD::::/$world_name/g" "$installdir/mc-system-refresher.sh"

cp server-scripts/start-server.sh $installdir/start-server.sh
sed -i -e "s/::::TEMPLATE:HEAP_MAX::::/$heap_max/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:HEAP_START::::/$heap_start/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_VERSION::::/$jolokia_version/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_AUTH::::/$jolokia_auth/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_PORT::::/$jolokia_port/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_HOST::::/$jolokia_host/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_USER::::/$jolokia_user/g" "$installdir/start-server.sh"
sed -i -e "s/::::TEMPLATE:JOLOKIA_PASSWORD::::/$jolokia_pass/g" "$installdir/start-server.sh"

