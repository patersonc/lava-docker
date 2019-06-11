#!/bin/bash

# NOTE: for this script to work, lavacli credentials need to be set up in ~/.conf/lavacli.yaml

LAVA_DIR="$(cd "$(dirname "$0")"; pwd)"
BACKUPS_DIR="${LAVA_DIR}/backups"
SLAVE="$(cat boards.yaml | grep name | grep lab-cip | cut -d : -f 2 | sed -e 's/^[[:space:]]*//')"
ARG="$1"

print_help() {
	cat<<-EOF

	USAGE:
	        ./stop.sh [ARG]
	ARGs:
		master	stop master container
		slave	stop slave container
		all	stop both master and slave containers

	EOF
	exit 1
}

case "${ARG}" in
	master)
		HOST="lava.ciplatform.org"
		# first backup
		echo "Running backup first"
		./backup.sh
		echo "[OK]"
		;;
	slave)
		HOST="$(cat boards.yaml | grep host | grep lab-cip | cut -d : -f 2 | sed -e 's/^[[:space:]]*//')"
		echo "Setting LAVA worker to maintenance"
		lavacli workers maintenance ${SLAVE}
		echo "[OK]"
		;;
	all)
		HOST="lava.ciplatform.org"
		echo "Setting LAVA worker to maintenance"
		lavacli workers maintenance ${SLAVE}
		echo "[OK]"
		# first backup
		echo "Running backup first"
		./backup.sh
		echo "[OK]"
		;;
	*)
		print_help
		;;
esac


echo "Press any key to continue"
read aw

# now running docker-compose
echo "taking down old instance"
pushd ${LAVA_DIR}/output/${HOST}/
docker-compose down
echo "[OK]"
echo "Press any key to continue"
read aw

# go back to main directory
popd

# backup output dir
echo "Backup output directory"
if [ ! -d ${BACKUPS_DIR} ];then
	mkdir -p ${BACKUPS_DIR}
fi
mv output "${BACKUPS_DIR}"/output-$(date +%Y%m%d_%H%M)
echo "[OK]"

echo "Press any key to continue"
read aw

echo "$0 Done"

