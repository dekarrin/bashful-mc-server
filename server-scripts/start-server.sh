#/bin/bash

while :
do
	java -Xmx2560M -Xms2560M -jar minecraft-server.jar nogui
	command="$(cat mc-supervisor-command)"
	if [ "$command" = "exit" ]
	then
		echo "Got supervisor stop command; exiting"
		break
	else
		echo "Detected non-supervisor exit; restarting server..."
	fi
done

