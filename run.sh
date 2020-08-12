#!/usr/bin/env bash

set -euo pipefail

cd $(dirname $0)

CONTAINER=gzr

#@@@@@@@@@@@@@@@@@ SET THE BELOW VALUES PER NEEDS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# +-----------------------------------------------+
# Please give absolute path for better results
BASE_SRC_DIR=$HOME/droid
# +-----------------------------------------------+
# BUILD TYPE - gzosp/validus/lineage
BUILD_TYPE=gzosp
# +-----------------------------------------------+
# Repository Details
REP_URL="https://github.com/GZOSP/manifest.git"
REP_BRANCH="9.0"
# +-----------------------------------------------+
# Possible Exports
CCACHE_DIR=$BASE_SRC_DIR/CCACHE
OUT_DIR=$BASE_SRC_DIR/out
# +-----------------------------------------------+
# Source code
CODE_DIR=$BASE_SRC_DIR/$BUILD_TYPE
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
mkdir -p $BASE_SRC_DIR
mkdir -p $CCACHE_DIR
mkdir -p $OUT_DIR
mkdir -p $CODE_DIR

command -v docker >/dev/null \
        || { echo "command 'docker' not found."; exit 1; }

# Build image if needed
if [[ $FORCE_BUILD = 1 ]] || ! docker inspect $REPOSITORY:$REP_BRANCH &>/dev/null; then

        docker build \
            --pull \
            -t $REPOSITORY:$REP_BRANCH \
            --build-arg hostuid=$(id -u) \
            --build-arg hostgid=$(id -g) \
            --build-arg build_type=$BUILD_TYPE \
            --build-arg repo_url=$REP_URL \
            --build-arg repo_branch=$REP_BRANCH \
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
    docker run $PRIVILEGED -v $BASE_SRC_DIR:$CONTAINER_HOME/android:Z \
                           -v $CODE_DIR:$CONTAINER_HOME/code:Z \
                           -v $OUT_DIR:$CONTAINER_HOME/out:Z \
                           -v $CCACHE_DIR:/srv/ccache:Z \
                           -i -t $ENVIRONMENT --name $CONTAINER $REPOSITORY:$REP_BRANCH
fi

exit $?
