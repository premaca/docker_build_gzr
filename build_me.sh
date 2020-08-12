#!/bin/bash

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#### USAGE:
#### ./get_build.sh -d <device_name> [clean] [sync] [nocache]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#####
### Prepared by:
### Prema Chand Alugu (premaca@gmail.com)
#####
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


#@@@@@@@@@@@@@@@@@@ VARIABLES @@@@@@@@@@@@@@@@@@@@@@@@@@#

## common directories - mounted through docker
BASE_SRC_DIR="$HOME/android"
BASE_OUT_DIR="$HOME/out"
BUILD_DATE=$(date +"%Y%m%d")

#@@@@@@@@@@@@@@@@@@ VARIABLES @@@@@@@@@@@@@@@@@@@@@@@@@@#


#@@@@@@@@@@@@@@@@@@ CONSTANTS @@@@@@@@@@@@@@@@@@@@@@@@@@#

#### Color codes
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
green='\033[0;32m'
nocol='\033[0m'

#### Font codes
bold=$(tput bold)
normal=$(tput sgr0)

## Paramter use to control EXIT when a command fails or not
EXIT_ON_FAIL='YES'

#@@@@@@@@@@@@@@@@@@ CONSTANTS @@@@@@@@@@@@@@@@@@@@@@@@@@#


#@@@@@@@@@@@@@@@@@@ FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@@@#

#### Usage
function show_usage {
    echo -e "$green $bold USAGE: get_build -d <device_name> [clean] [sync] [nocache] $nocol"
}

#### Execute given command, Can EXIT upon fail.
## Use EXIT_ON_FAIL constant to control it
function exec_command {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "********************************" >&2
        echo -e "$red $bold !! FAIL !! executing command $1" >&2 $nocol
        echo "********************************" >&2
        if [ "$EXIT_ON_FAIL" == 'YES' ]; then
        exit
        fi
        return $status
    fi
    return $status
}

#### Sync the repo
function repo_sync {
    exec_command repo init -u ${REP_URL} -b ${REP_BRANCH}
    exec_command repo sync -c -j18 --force-sync --no-clone-bundle --no-tags
}

#### Build it!
function build_me {

    #### start the build status as FAIL
    build_status=1
    #### Any errors while executing the build, ignore to EXIT
    #### Because we need to continue with other builds given if any
    EXIT_ON_FAIL='NO'

    ## INITIALIZE variables now
    SRC_DIR=$BASE_SRC_DIR/${BUILD_TYPE}
    OUT_DIR=$BASE_OUT_DIR/$DEVICE/${BUILD_TYPE}
    CACHE_DIR=${CCACHE_DIR}/$DEVICE/${BUILD_TYPE}

    echo -e "build_me: $bold Build Variables device=$DEVICE SRC_DIR=$SRC_DIR CCACHE_DIR=$CACHE_DIR OUT_DIR=${OUT_DIR} " $nocol

    echo -e "build_me: $bold ... Exporting Common Output directory to $BASE_OUT_DIR/$DEVICE" $nocol
    export OUT_DIR_COMMON_BASE=$BASE_OUT_DIR/$DEVICE

    echo -e "build_me: $bold ... Entering source directory=$SRC_DIR, create if one doesn't exit for sync" $nocol
    exec_command mkdir -p $SRC_DIR
    exec_command cd $SRC_DIR

    ## sync build
    if [ "$SYNC_BUILD" == 'YES' ]; then
        echo -e "build_me: $bold ... Syncing Repository... $SRC_DIR" $nocol
        repo_sync
    fi

    ## set up CCACHE
    echo -e "build_me: $bold ... Setting up ccache to 50G in $CACHE_DIR" $nocol
    exec_command export CCACHE_DIR=$CACHE_DIR
    exec_command ccache -M 50G
    if [ "$CLEAN_CCACHE" == "YES" ]; then
        exec_command export CCACHE_DIR=$CACHE_DIR
        echo -e "build_me: $bold ... Clearing up ccache $CACHE_DIR" $nocol
        exec_command ccache -C
        exec_command ccache -z
    fi

    ## clean build
    if [ "$CLEAN_BUILD" == 'YES' ]; then
        echo -e "build_me: $bold ... Cleaning output directory $OUT_DIR" $nocol
        exec_command rm -rf $OUT_DIR
    fi

    ## lunch the device
    echo -e "build_me: $bold ... Set Environment and Lunch : ${BUILD_TYPE}_$DEVICE-userdebug" $nocol
    exec_command source build/envsetup.sh; lunch ${BUILD_TYPE}_$DEVICE-userdebug

    ## make the device
    make_jobs=`grep processor /proc/cpuinfo | wc -l`
    echo -e "build_me: $bold ... Clean Installs and Execute Make (jobs=$make_jobs)...." $nocol
    exec_command make installclean
    exec_command make -j$make_jobs ${BUILD_TYPE}
    if [ "$?" -ne 0 ]; then
        echo -e "build_me: $bold Build for $DEVICE FAILED !!!!" $nocol
        build_status=1
        EXIT_ON_FAIL='YES'
        return $build_status;
    fi

    ## Check build status
    echo -e "Build completed. Check Zip File: $OUT_DIR/target/product/$DEVICE/[A-Za-z]*-$DEVICE-[A-Za-z0-9]*-$BUILD_DATE-*.zip"
    echo -e "build_me: $bold *******************************************************" $nocol
        exec_command ls ${OUT_DIR}/target/product/$DEVICE/[A-Za-z]*-$DEVICE-[A-Za-z0-9]*-$BUILD_DATE-*.zip
    if [ "$?" -ne 0 ]; then
        echo -e "build_me: $bold Build for $DEVICE FAILED !!!!" $nocol
        echo -e "build_me: $bold *******************************************************" $nocol
        build_status=1
    else
        echo -e "build_me: $bold Build for $DEVICE Built Successfully " $nocol
        echo -e "build_me: $bold *******************************************************" $nocol
        ##### BUILD IS SUCCESSFUL.
        build_status=0
    fi

    EXIT_ON_FAIL='YES'
    return $build_status;
}

#### Control Builds and Statuses
function prepare_builds {

    ### Build it
    echo -e "$bold PREPARING ${BUILD_TYPE} for $DEVICE ....." $nocol
    build_me $DEVICE ${BUILD_TYPE}
    RETURN_VALUE="$?"
    if [ "$RETURN_VALUE" -ne 0 ]; then
        GZ_FAILED='!! FAIL !!'
    else
        GZ_FAILED='Success'
    fi
}

#@@@@@@@@@@@@@@@@@@ FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@@@#


#@@@@@@@@@@@@@@@@@@ MAIN @@@@@@@@@@@@@@@@@@@@@@@@@@#

################## DEFAULTS ###################
DEVICE=""


#### Read the arguments and populate Build Varaibles
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    sync)
    SYNC_BUILD=YES
    #shift # past argument
    ;;
    clean)
    CLEAN_BUILD=YES
    #shift # past argument
    ;;
    nocache)
    CLEAN_CCACHE=YES
    #shift # past argument
    ;;
    -d)
    DEVICE="$2"
    shift # past value
    ;;
    *)
        show_usage
        exit;
    ;;
esac
shift # past argument or value
done

#### Handle the errors and throw USAGE from the command line
if [ "$DEVICE" == "" ]
then echo;
echo -e "**********!!!!!  CHOSE $red $bold DEVICE TYPE $nocol !!!!!**************"
show_usage
exit
fi

#### Print Builds Request from the command line
echo;
echo "***************************************************************"
echo -e "*!*!*! ${bold}DEVICE: $red $bold $DEVICE \t SYNC=$SYNC_BUILD CLEAN=$CLEAN_BUILD !*!*!* $normal"
echo "***************************************************************"
echo;


#### !!! BUILD THEM !!!
prepare_builds

echo; echo;

#### Final Report
echo "***************************************************************"
echo -e "*!*!*! FINAL REPORT !*!*!*"
echo "***************************************************************"
echo -e "*!*!*! ${bold}DEVICE: $red $bold $DEVICE $nocol !*!*!* $normal"
echo -e "*!*!*! BUILDS:   $red[GZ="$GZ_FAILED"]$nocol \t !*!*!*"
echo "***************************************************************"

exit

#@@@@@@@@@@@@@@@@@@ MAIN @@@@@@@@@@@@@@@@@@@@@@@@@@#


#@@@@@@@@@@@@@@@@@@ END @@@@@@@@@@@@@@@@@@@@@@@@@@#
