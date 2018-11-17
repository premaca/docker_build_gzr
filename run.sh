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
BUILD_VARIANT=OFFICIAL
# +-----------------------------------------------+
# BUILD TYPE VARIABLES
# +-----------------------------------------------+
CONTAINER=gzr
BASE_SRC_DIR=/shared/Android
CCACHE_DIR=/shared/Android/CCACHE
if [[ $BUILD_TYPE == "gzosp" ]]; then
    BUILD_DIR=Gzosp # inside BASE_SRC_DIR
    OUT_DIR=$BASE_SRC_DIR/out
    REPO_URL="https://github.com/GZOSP/manifest.git"
    REPO_BRANCH="9.0"
elif [[ $BUILD_TYPE == "validus" ]]; then
    BUILD_DIR=Val # inside BASE_SRC_DIR
    OUT_DIR=$BASE_SRC_DIR/out
    REPO_URL="https://github.com/ValidusOS/manifest.git"
    REPO_BRANCH="9.0"
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

command -v docker >/dev/null \
        || { echo "command 'docker' not found."; exit 1; }

# Build image if needed
if [[ $FORCE_BUILD = 1 ]] || ! docker inspect $REPOSITORY:$REPO_BRANCH &>/dev/null; then

        docker build \
            --pull \
            -t $REPOSITORY:$REPO_BRANCH \
            --build-arg hostuid=$(id -u) \
            --build-arg hostgid=$(id -g) \
            --build-arg ccache_size=$CCACHE_SIZE \
            --build-arg make_jobs=$MAKE_JOBS \
            --build-arg out_dir=$OUT_DIR \
            --build-arg build_type=$BUILD_TYPE \
            --build-arg build_dir=$BUILD_DIR \
            --build-arg repo_url=$REPO_URL \
            --build-arg repo_branch=$REPO_BRANCH \
            --build-arg build_variant=$BUILD_VARIANT \
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
    docker run $PRIVILEGED -v $BASE_SRC_DIR:$CONTAINER_HOME/android:Z -v $OUT_DIR:$CONTAINER_HOME/out:Z -v $CCACHE_DIR:/srv/ccache:Z -i -t $ENVIRONMENT --name $CONTAINER $REPOSITORY:$REPO_BRANCH
fi

exit $?
