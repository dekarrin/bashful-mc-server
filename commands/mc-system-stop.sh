#!/bin/bash

# Accepts warning time; defaults to 10 if none given

MC_DIR=/home/dekarrin/minecraft
SERVER_SESSION=$(cat "$MC_DIR/mc-system-server-session")
RESTARTER_SESSION=$(cat "$MC_DIR/mc-system-restarter-session")

if [ $# -gt 0 ]
then
	case "$1" in
		[0-9]|[0-9][0-9]|[0-9][0-9][0-9])
			WARN_TIME=$1
			;;
		*)
			echo "'$1' is not a valid warn time; must be between 0 and 999" >&2
			exit 2
			;;
	esac
			
else
	WARN_TIME=10
fi

if [ ! -f "$MC_DIR/.mc-system-lock" ]
then
	echo "Minecraft server not currently running" >&2
	exit 1
fi


echo "stop" > "$MC_DIR/mc-supervisor-command"

screen -S $RESTARTER_SESSION -X quit

echo "Waiting for clean down of supervisor..."
sleep 5

screen -S $SERVER_SESSION -X stuff '
/say External shutdown command given. Shutting down in '$WARN_TIME' seconds...
'
echo "Warned server; waiting $WARN_TIME seconds..."
sleep $WARN_TIME

screen -S $SERVER_SESSION -X stuff '
/say Now shutting down...
'
sleep 5
screen -S $SERVER_SESSION -X stuff '
/save-all
/stop
'

echo "Waiting 15 seconds for save all to complete..."
sleep 15
screen -S $SERVER_SESSION -X quit

rm "$MC_DIR/.mc-system-lock"

