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
[ -n "$heap_start" ] || heap_start=2560

read -p "Maximum heap size (default: $heap_start)? " heap_max
[ -n "$heap_max" ] || heap_max="$heap_start"

# default is 6 hours
read -p "Auto-restart interval in minutes (default: 360)? " restart_interval
[ -n "$restart_interval" ] || restart_interval=360

read -p "Auto-restart warn time in seconds (default: 60)? " restart_warn
[ -n "$restart_warn" ] || restart_warn=60

read -p "Server start wait time in seconds (default: 100)? " start_wait_time
[ -n "$start_wait_time" ] || start_wait_time=100

cp commands/mc-system-start.sh $cmdpath/mc-system-start.sh
sed -i -e 's/::::TEMPLATE:MC_DIR::::/'"$installdir"'/g' "$cmdpath/mc-system-start.sh"

cp commands/mc-system-stop.sh $cmdpath/mc-system-stop.sh
sed -i -e 's/::::TEMPLATE:MC_DIR::::/'"$installdir"'/g' "$cmdpath/mc-system-stop.sh"

cp server-scripts/mc-system-refresher.sh $installdir/mc-system-refresher.sh
sed -i -e 's/::::TEMPLATE:MC_DIR::::/'"$installdir"'/g' "$installdir/mc-system-refresher.sh"
sed -i -e 's/::::TEMPLATE:RESTART_MINS::::/'"$restart_interval"'/g' "$installdir/mc-system-refresher.sh"
sed -i -e 's/::::TEMPLATE:RESTART_WARN::::/'"$restart_warn"'/g' "$installdir/mc-system-refresher.sh"
sed -i -e 's/::::TEMPLATE:START_WAIT::::/'"$start_wait_time"'/g' "$installdir/mc-system-refresher.sh"


cp server-scripts/start-server.sh $installdir/start-server.sh
sed -i -e 's/::::TEMPLATE:HEAP_MAX::::/'"$heap_max"'/g' "$installdir/start-server.sh"
sed -i -e 's/::::TEMPLATE:HEAP_START::::/'"$heap_start"'/g' "$installdir/start-server.sh"
