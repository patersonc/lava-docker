#!/bin/bash

LAVA_DIR="$(cd "$(dirname "$0")"; pwd)"
BACKUPS_DIR="${LAVA_DIR}/backups"
SLAVE="$(cat boards.yaml | grep name | grep lab | cut -d : -f 2 | sed -e 's/^[[:space:]]*//')"
ARG="$1"

print_help() {
	cat<<-EOF

	USAGE:
	        ./start.sh [ARG]
	ARGs:
		master	start master container
		slave	start slave container
		all	start both master and slave containers

	EOF
	exit 1
}

if [ "${ARG}" != "master" ] && [ "${ARG}" != "slave" ] && [ "${ARG}" != "all" ];then
	print_help
fi

echo "If you haven't updated the repo yet (boards.yaml) quit now..."
echo "Otherwise press any key to continue"
read aw

# rerunning lavalab-gen.sh
./lavalab-gen.sh
echo "[OK]"

echo "Press any key to continue"
read aw

case "${ARG}" in
	master | all)
		HOST="$(cat boards.yaml | grep " host:" | grep "ciplatform" | cut -d : -f 2 | sed -e 's/^[[:space:]]*//')"
		# restoring backup
		echo "restoring data from latest backup"
		cp $BACKUPS_DIR/backup-latest/* output/${HOST}/master/backup/
		echo "[OK]"
		echo "Press any key to continue"
		read aw
		;;
	slave)
		HOST="$(cat boards.yaml | grep " host:" | grep "lab" | cut -d : -f 2 | sed -e 's/^[[:space:]]*//')"
		;;
esac

# go to new output directory
pushd ${LAVA_DIR}/output/${HOST}/

echo "building and running the new instance"
./deploy.sh
echo "Successfully built the new docker containers"
echo "[OK]"
echo "Press any key to continue"
read aw

popd

case "${ARG}" in
	slave)
		echo "Setting ${SLAVE} status to active"
		lavacli workers update --health ACTIVE ${SLAVE} > /dev/null 2>&1
		echo "[OK]"
		;;
esac

echo "$0 Done"
