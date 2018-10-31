#!/bin/bash

# Script to start both Minecraft server process and periodic restart

SERVER_SESSION=mcserver
RESTARTER_SESSION=mcrefresher
MC_DIR="::::TEMPLATE:MC_DIR::::"

if [ -f "$MC_DIR/.mc-system-lock" ]
then
	echo "Minecraft server is already running." >&2
	exit 1
fi

echo "$SERVER_SESSION" > "$MC_DIR/mc-system-server-session"
echo "$RESTARTER_SESSION" > "$MC_DIR/mc-system-restarter-session"
echo "" > "$MC_DIR/mc-supervisor-command"

screen -dmS $SERVER_SESSION
screen -dmS $RESTARTER_SESSION

screen -S $SERVER_SESSION -X stuff 'cd "'$MC_DIR'" && ./start-server.sh
'

screen -S $RESTARTER_SESSION -X stuff 'cd "'$MC_DIR'" && ./mc-system-refresher.sh
#'

echo "running" >> "$MC_DIR/.mc-system-lock"

echo "Waiting 20 seconds for server to be up..."
sleep 20
echo "Started Minecraft server in screen session '$SERVER_SESSION'"
echo "Refresher running in screen session '$RESTARTER_SESSION'"

