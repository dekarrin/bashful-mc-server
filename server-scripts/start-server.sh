#/bin/bash

while :
do
	java -Xmx::::TEMPLATE:HEAP_MAX:::: -Xms::::TEMPLATE:HEAP_START:::: -jar minecraft-server.jar nogui
	command="$(cat mc-supervisor-command)"
	if [ "$command" = "exit" ]
	then
		echo "Got supervisor stop command; exiting"
		break
	else
		echo "Detected non-supervisor exit; restarting server..."
	fi
done

