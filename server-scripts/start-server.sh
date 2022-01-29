#/bin/bash

MC_DIR="::::TEMPLATE:MC_DIR::::"

jolokia_auth="::::TEMPLATE:JOLOKIA_AUTH::::"

agent_arg="-javaagent:$MC_DIR/jolokia-jvm-::::TEMPLATE:JOLOKIA_VERSION::::.jar"
agent_arg="${agent_arg}=port=::::TEMPLATE:JOLOKIA_PORT::::"
agent_arg="${agent_arg},host=::::TEMPLATE:JOLOKIA_HOST::::"

if [ -n "$jolokia_auth" ]
then
  agent_arg="${agent_arg},user=::::TEMPLATE:JOLOKIA_USER::::"
  agent_arg="${agent_arg},password=::TEMPLATE:JOLOKIA_PASSWORD::::"
fi

while :
do
	java "$agent_arg" -Xmx::::TEMPLATE:HEAP_MAX:::: -Xms::::TEMPLATE:HEAP_START:::: -jar minecraft-server.jar nogui
	command="$(cat mc-supervisor-command)"
	if [ "$command" = "exit" ]
	then
		echo "Got supervisor stop command; exiting"
		break
	else
		echo "Detected non-supervisor exit; restarting server..."
	fi
done

