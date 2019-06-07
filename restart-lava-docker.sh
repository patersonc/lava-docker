#!/bin/bash

STOP_START_SCRIPTS_DIR="$(cd "$(dirname "$0")"; pwd)"
ARG="$1"

print_help() {
	cat<<-EOF

	USAGE:
	        ./restart_lava_docker.sh [ARG]
	ARGs:
		master	restart master container
		slave	restart slave container
		all	restart both master and slave containers

	EOF
	exit 1
}

if [ "${ARG}" != "master" ] && [ "${ARG}" != "slave" ] && [ "${ARG}" != "all" ];then
	print_help
fi

${STOP_START_SCRIPTS_DIR}/stop.sh "${ARG}"
${STOP_START_SCRIPTS_DIR}/start.sh "${ARG}"

