#!/bin/bash

MC_DIR="::::TEMPLATE:MC_DIR::::"
SERVER_SESSION=$(cat "$MC_DIR/mc-system-server-session")
CUR_WORLD="::::TEMPLATE:CUR_WORLD::::"

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
	echo "[$(date)] Waiting 10 seconds for server to be stopped..."
	sleep 10
	echo "[$(date)] Backing up current world..."
	mkdir -p "$MC_DIR/backups"
	cd "$MC_DIR" && tar czf backups/"$CUR_WORLD"-$(date +"%Y-%m-%d_%H-%M-%M").tar.gz "$CUR_WORLD"/
	echo "[$(date)] Done with backup, waiting 5 secs before restart..."
	sleep 5
	echo "[$(date)] Waiting period ended"
	if [ -f "$MC_DIR/on-refresh.sh" ]
	then
		echo "[$(date)] Refresh hooks present; executing $MC_DIR/on-refresh.sh"
		"$MC_DIR/on-refresh.sh"
		echo "[$(date)] Done running refresh hooks"
	else
		echo "[$(date)] Refresh hooks file on-refresh.sh not present, so no hooks to run"
	fi
	echo "[$(date)] Restarting server..."
done
