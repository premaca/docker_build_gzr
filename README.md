DOCKER to automate building GZRoms
==================================

Create a [Docker](https://www.docker.com) based environment to build GZRoms; [GZOSP](https://github.com/GZOSP), [VALIDUS](https://github.com/ValidusOs).

This Dockerfile will create a docker container which is based on Ubuntu 18.04.
It will install the "repo" utility and any other build dependencies which are required to compile GZRoms.

The main working directory is a shared folder on the host system, so the Docker container can be removed at any time.

**NOTE:** Remember that GZRoms is a huge project. Each ROM will consume a large amount of disk space (~80 GB) and it can easily take hours to build.

### WHY Docker?

- Independent of HOST OS distribution, Docker uses 'UBUNTU 18.04'
- Requires 'bash' support on HOST OS and nothing more
- Tested on MacOS, Linux variants
- Users can change HOST OS distributions freely
    * Supports advanced users who might preserve build repos via mount points on same or different partitions
    * Docker uses 'bind mount points' which shares file system with Host OS

#### Few handy docker commands, for HOST OS
```
docker images [-a]
    - lists down [all] docker images
docker rmi
    - removes docker image. e.g docker rmi gzr
docker ps -a
    - lists down all the docker containers currently running
docker stop
    - stops the container. e.g docker stop gzr
docker attach
    - attaches to the running container
```


### How to build docker container

**NOTES:**
* You will need to [install Docker](https://www.docker.com/get-started) to proceed!
* If an image does not exist, ```docker build``` is executed first

```
git clone https://github.com/GZOSP/docker_build_gzr
cd docker_build_gzr
./run.sh

[NOTE:] Always recommended to use './run.sh' to attach/start the existing image container
```

The `run.sh` script accepts the following switches:

| Switch | Alternative | Description  |
|---|---|---|
| `-u` | `--enable-usb` | Runs the container in privileged mode (this way you can use adb right from the container) |
| `-r` | `--rebuild` | Force rebuild the image from scratch |

The container uses "screen" to run the shell. This means that you will be able to open additional shells using [screen keyboard shortcuts][Screen_Shortcuts].

#### ADB in the container
If you're on Linux and want to use adb from within the container running with `-u` might not be enough. Make sure you have the [Android udev rules](https://github.com/M0Rf30/android-udev-rules/blob/master/51-android.rules) installed on your host system so you can access your device without needing superuser permissions.

### How to build GZRoms for your device

```
-> You should be inside Docker at /home/build
./build_me.sh -d <device_name> [clean] [sync]
ARGS -
    - -d <device_name> : Device code name to build for. e.g. oneplus3
    - clean : Builds clean, removes the OUT directory for this device
    - sync : Syncs repository
```
### BEFORE EVERYTHING ELSE - Setup Ecosystem for your builds
#### Building GZOSP
-> You should be inside Docker at /home/build
```
Edit "run.sh" with desired values.

CCACHE_SIZE     - ccache size to be used. Default: 50G
MAKE_JOBS       - make jobs, depends on your host system cores. Default : 8
BUILD_TYPE      - gzosp. Default : gzosp
BUILD_VARIANT   - Set the variant. Default : OFFICIAL
BASE_SRC_DIR    - Base source directory, where GZOSP repo needs to be initialized
CCACHE_DIR      - ccache directory
BUILD_DIR       - Inner directory of BASE_SRC_DIR where GZOSP source is checkedout. Default : Gzosp
OUT_DIR         - Output directory for build artifacts. Default : $BASE_SRC_DIR/out
REPO_URL        - URL repo for GZOSP manifest. Default : "https://github.com/GZOSP/manifest.git"
REPO_BRANCH     - Branch of GZOSP repo manifest. Default : "9.0"
```

#### Building VALIDUS
-> You should be inside Docker at /home/build
```
Edit "run.sh" with desired values.

CCACHE_SIZE     - ccache size to be used. Default: 50G
MAKE_JOBS       - make jobs, depends on your host system cores. Default : 8
BUILD_TYPE      - validus. Default : gzosp
BUILD_VARIANT   - Set the variant. Default : OFFICIAL
BASE_SRC_DIR    - Base source directory, where VALIDUS repo needs to be initialized
CCACHE_DIR      - ccache directory
BUILD_DIR       - Inner directory of BASE_SRC_DIR where VALIDUS source is checkedout. Default : Val
OUT_DIR         - Output directory for build artifacts. Default : $BASE_SRC_DIR/out
REPO_URL        - URL repo for GZOSP manifest. Default : "https://github.com/ValidusOS/manifest.git"
REPO_BRANCH     - Branch of GZOSP repo manifest. Default : "9.0"
```

#### Setup GIT details for REPO SYNC and management
```
-> You should be inside Docker
git config --global user.email "yourmailid@domain.com"
git config --global user.name "Your Name"
```

#### I'm Noob, Never built
```
- Setup the Ecosystem as explained above
- Make sure you have enough disk space required
- Execute "./build_me.sh -d <device_name> sync"
    * This would checkout the GZOSP/VALIDUS manifest and syncs device repos
    * If the device is not Officially supported, you should setup local manifest
    * If the device is officially supported, and device dependencies not setup, contact the maintainer or raise issue in GZOSP page.
```

#### I'm already building. How to automate
```
- Assume your source code is at /home/user/Gzosp
- Setup the Ecosystem as explained above
- Execute "./build_me.sh -d <device_name> sync"
    * This would sync the GZOSP/VALIDUS for any new changes
```

#### Clean builds, ccache
```
- While executing "build_me.sh" use, "clean" as argument
    * e.g "./build_me.sh -d oneplus3 sync clean
- ccache is stored independently for each device and repo. This is so that if you want to clean ccache afresh for a device,
  it will not disturb other device ccache
    * While executing "build_me.sh" use, "nocache" as argument
    * e.g "./build_me.sh -d oneplus3 nocache
```

### Build System Visualizations

#### Source directory
                           BASE_SRC_DIR
                                 |
                   --------------------------------
                   |                               |
                Gzosp                            Validus

#### Output directory
                           OUT_DIR
                                 |
                   --------------------------------
                   |             |                |
                oneplus3      sanders         cheeseburger
                   |
           ---------------
           |             |
        Gzosp         Validus
    ------------
          |
     target/out/...

#### CCACHE directory
                           CCACHE_DIR
                                 |
                   --------------------------------
                   |             |                |
                oneplus3      sanders         cheeseburger
                   |
           ---------------
           |             |
        Gzosp         Validus
    ------------
          |
     CCACHE DATA


