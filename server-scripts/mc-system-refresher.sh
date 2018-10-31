#!/bin/bash

MC_DIR="::::TEMPLATE:MC_DIR::::"
SERVER_SESSION=$(cat "$MC_DIR/mc-system-server-session")

RESTART_MINS="::::TEMPLATE:RESTART_MINS::::"
RESTART_WARN_SECS="::::TEMPLATE:RESTART_WARN::::"
WAIT_FOR_START="::::TEMPLATE:START_WAIT::::"

# DONT TOUCH VARS UNDER THIS

RESTART_SECS=$(expr "$RESTART_MINS" \* 60)
SLEEP_WARN_TIME=$(expr $RESTART_SECS - $RESTART_WARN_SECS)

echo "[$(date)] Waiting $WAIT_FOR_START seconds for server to be up..."
sleep $WAIT_FOR_START
echo "[$(date)] Started refresh loop"

while :
do
	sleep $SLEEP_WARN_TIME
	echo "[$(date)] Warning of restart"
	screen -S $SERVER_SESSION -X stuff '
/say Server going down for refresh in '$RESTART_WARN_SECS' seconds; reconnect afterwards
'
	sleep $RESTART_WARN_SECS
	echo "[$(date)] Saving and restarting"
	screen -S $SERVER_SESSION -X stuff '
/say Refreshing server...
/save-all
/stop
'
done
