docker_build_gzr
==================

Create a [Docker] based environment to build [GZRoms].

This Dockerfile will create a docker container which is based on Ubuntu 18.04.
It will install the "repo" utility and any other build dependencies which are required to compile GZRoms.

The main working directory is a shared folder on the host system, so the Docker container can be removed at any time.

**NOTE:** Remember that GZRoms is a huge project. It will consume a large amount of disk space (~80 GB) and it can easily take hours to build.

### Build System Visualizations

### Source directory
                           BASE_SRC_DIR (e.g /home/premaca/android)
                                 |
                   --------------------------------
                   |                               |
                Gzosp                            Validus

### Output directory
                           OUT_DIR (e.g /home/premaca/android/out)
                                 |
                   --------------------------------
                   |             |                |
                oneplus3      sanders         cheeseburger
                   |
           ---------------
           |             |
        Gzosp         Validus

### CCACHE directory
                           CCACHE_DIR (e.g /home/premaca/.ccache)
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

### How to run/build

**NOTES:**
* You will need to [install Docker][Docker_Installation] to proceed!
* If an image does not exist, ```docker build``` is executed first

```
git clone <TODO>
cd docker_build_gzr
./run.sh
```

The `run.sh` script accepts the following switches:

| Switch | Alternative | Description  |
|---|---|---|
| `-u` | `--enable-usb` | Runs the container in privileged mode (this way you can use adb right from the container) |
| `-r` | `--rebuild` | Force rebuild the image from scratch |
| `-ws` | `--with-su` | Sets the WITH_SU environment variable to true (your builds will include the su binary) |

The container uses "screen" to run the shell. This means that you will be able to open additional shells using [screen keyboard shortcuts][Screen_Shortcuts].

### ADB in the container
If you're on Linux and want to use adb from within the container running with `-u` might not be enough. Make sure you have the [Android udev rules](https://github.com/M0Rf30/android-udev-rules/blob/master/51-android.rules) installed on your host system so you can access your device without needing superuser permissions.

### How to build GZRoms for your device

```
<FIXME>
```

