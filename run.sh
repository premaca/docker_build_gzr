#!/usr/bin/env bash

set -euo pipefail

cd $(dirname $0)

#@@@@@@@@@@@@@@@@@ SET THE BELOW VALUES PER NEEDS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# COMMON VARIABLES
CCACHE_SIZE=50G
MAKE_JOBS=8
# +-----------------------------------------------+
# BUILD TYPE - gzosp/validus
BUILD_TYPE=gzosp
# +-----------------------------------------------+
# BUILD TYPE VARIABLES
# +-----------------------------------------------+
if [[ $BUILD_TYPE == "gzosp" ]]; then
    CONTAINER=gzosp
    TAG=9.0
    SOURCE_DIR=/shared/Android/Gzosp
    OUT_DIR=$SOURCE_DIR/out
    CCACHE_DIR=/shared/Android/.gzcc
elif [[ $BUILD_TYPE == "validus" ]]; then
    CONTAINER=validus
    TAG=9.0
    SOURCE_DIR=/shared/Android/Val
    OUT_DIR=$SOURCE_DIR/out
    CCACHE_DIR=/shared/Android/.valcc
else
    echo "BUILD_TYPE must be set."; exit 1;
fi
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


CONTAINER_HOME=/home/build
REPOSITORY=docker_build_gzr
FORCE_BUILD=0
PRIVILEGED=
ENVIRONMENT=

while [[ $# > 0 ]]; do
	key="$1"
	case $key in
		-r|--rebuild)
			FORCE_BUILD=1
			;;
		-u|--enable-usb)
			PRIVILEGED="--privileged -v /dev/bus/usb:/dev/bus/usb"
			;;
		-ws|--with-su)
			ENVIRONMENT="-e WITH_SU=true"
			;;
		*)
			shift # past argument or value
			;;
	esac
	shift
done

# Create shared folders
# Although Docker would create non-existing directories on the fly,
# we need to have them owned by the user (and not root), to be able
# to write in them, which is a necessity for startup.sh
mkdir -p $SOURCE_DIR
mkdir -p $CCACHE_DIR
mkdir -p $OUT_DIR

command -v docker >/dev/null \
	|| { echo "command 'docker' not found."; exit 1; }

# Build image if needed
if [[ $FORCE_BUILD = 1 ]] || ! docker inspect $REPOSITORY:$TAG &>/dev/null; then

	docker build \
		--pull \
		-t $REPOSITORY:$TAG \
		--build-arg hostuid=$(id -u) \
		--build-arg hostgid=$(id -g) \
		--build-arg ccache_size=$CCACHE_SIZE \
		--build-arg make_jobs=$MAKE_JOBS \
		--build-arg out_dir=$OUT_DIR \
		--build-arg build_type=$BUILD_TYPE \
		.

	# After successful build, delete existing containers
	if docker inspect $CONTAINER &>/dev/null; then
		docker rm $CONTAINER >/dev/null
	fi
fi

# With the given name $CONTAINER, reconnect to running container, start
# an existing/stopped container or run a new one if one does not exist.
IS_RUNNING=$(docker inspect -f '{{.State.Running}}' $CONTAINER 2>/dev/null) || true
if [[ $IS_RUNNING == "true" ]]; then
	docker attach $CONTAINER
elif [[ $IS_RUNNING == "false" ]]; then
	docker start -i $CONTAINER
else
	docker run $PRIVILEGED -v $SOURCE_DIR:$CONTAINER_HOME/android:Z -v $OUT_DIR:$CONTAINER_HOME/out:Z -v $CCACHE_DIR:/srv/ccache:Z -i -t $ENVIRONMENT --name $CONTAINER $REPOSITORY:$TAG
fi

exit $?
