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

cp commands/mc-system-start.sh $cmdpath/mc-system-start.sh

cp commands/mc-system-stop.sh $cmdpath/mc-system-stop.sh
sed -i -e 's/::::TEMPLATE:MC_DIR::::/'"$installdir"'/g' "$cmdpath/mc-system-stop.sh"

cp server-scripts/mc-system-refresher.sh $installdir/mc-system-refresher.sh
cp server-scripts/start-server.sh $installdir/start-server.sh

