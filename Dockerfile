# Build environment for GZRoms

FROM ubuntu:18.04
MAINTAINER Prema Chand Alugu <premaca@gmail.com>

ARG ccache_size
ARG make_jobs
ARG out_dir
ARG build_type
ARG build_dir
ARG repo_url
ARG repo_branch

ENV \
# Build environments
    CCACHE_SIZE=$ccache_size \
    CCACHE_DIR=/srv/ccache \
    USE_CCACHE=1 \
    CCACHE_COMPRESS=1 \
    MAKE_JOBS=$make_jobs \
    OUT_DIR=$out_dir \
    BUILD_TYPE=$build_type \
    BUILD_DIR=$build_dir \
    REP_URL=$repo_url \
    REP_BRANCH=$repo_branch \
# Extra include PATH, it may not include /usr/local/(s)bin on some systems
    PATH=$PATH:/usr/local/bin/

# Update sources for bionic
RUN printf "deb http://cz.archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list

RUN sed -i 's/main$/main universe/' /etc/apt/sources.list \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
# Install build dependencies
      bison \
      build-essential \
      curl \
      flex \
      git-core \
      gnupg \
      gperf \
      libesd0-dev \
      liblz4-tool \
      libncurses5-dev \
      libsdl1.2-dev \
      libwxgtk3.0-dev \
      libxml2 \
      libxml2-utils \
      lzop \
      openjdk-8-jdk \
      pngcrush \
      schedtool \
      squashfs-tools \
      xsltproc \
      zip \
      zlib1g-dev \
# For 64-bit systems
      g++-multilib \
      gcc-multilib \
      lib32ncurses5-dev \
      lib32readline6-dev \
      lib32z1-dev \
# Install additional packages which are useful for building Android
      android-tools-adb \
      android-tools-fastboot \
      bash-completion \
      bc \
      bsdmainutils \
      ccache \
      file \
      imagemagick \
      libssl-dev \
      nano \
      python \
      rsync \
      screen \
      sudo \
      tig \
      vim \
      wget \
      yasm \
 && rm -rf /var/lib/apt/lists/*

ARG hostuid=1000
ARG hostgid=1000

RUN \
    groupadd --gid $hostgid --force build && \
    useradd --gid $hostgid --uid $hostuid --non-unique build && \
    rsync -a /etc/skel/ /home/build/

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
 && chmod a+x /usr/local/bin/repo

# Add sudo permission
RUN echo "build ALL=NOPASSWD: ALL" > /etc/sudoers.d/build

ADD startup.sh /home/build/startup.sh
RUN chmod a+x /home/build/startup.sh

COPY screenrc /home/build/.screenrc
COPY bashrc /home/build/bashrc
COPY build_me.sh /home/build/build_me.sh

# Fix ownership
RUN chown -R build:build /home/build

VOLUME /home/build/android
VOLUME /home/build/out
VOLUME /srv/ccache

USER build
WORKDIR /home/build

CMD /home/build/startup.sh
