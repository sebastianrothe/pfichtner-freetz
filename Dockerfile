FROM ubuntu:20.04

ARG BUILD_USER=builduser
ENV BUILD_USER=$BUILD_USER
ENV DEBIAN_FRONTEND noninteractive

ARG TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY patch-cnf-autoinstall.patch /tmp
COPY entrypoint.sh /usr/local/bin

# see https://github.com/Freetz-NG/freetz-ng/blob/master/docs/PREREQUISITES.md#ubuntu
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \ 
    apt-get -y install \
        sudo command-not-found vim wget bc \
        rsync kmod execstack sqlite3 libsqlite3-dev libzstd-dev \
        libzstd-dev cmake lib32z1-dev unar imagemagick \
        subversion git ccache gcc g++ binutils autoconf automake \
        autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev \
        zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config sharutils \
        ecj fastjar perl libstring-crc32-perl ruby gawk python \
        bsdmainutils locales \
        libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 \
        lib32ncurses5-dev gcc-multilib lib32stdc++6 libglib2.0-dev \
        libxml2-dev cpio \
        uuid-dev libssl-dev libgnutls28-dev \
        u-boot-tools device-tree-compiler \
        curl netcat \
        # needed by tools/freetz_patch
        patchutils \
        # not necessary for building but uploading via tools/push_firmware
        iproute2 ncftp iputils-ping net-tools \
        # needed by ffritz
        fakeroot squashfs-tools \
        # recommended by make
        busybox

    # need to run again for c-n-f
RUN apt-get -y update && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    useradd -M -G sudo -s `which bash` -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    patch -p0 </tmp/patch-cnf-autoinstall.patch && \
    rm /tmp/patch-cnf-autoinstall.patch && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    # disable sudo hint without having any matching file in $HOME
    sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc
    # do not purge package lists since we need them for autoinstalling via c-n-f
    # rm -rf /var/lib/apt/lists/*

ARG WORKDIR=/workspace
WORKDIR $WORKDIR

USER $BUILD_USER

# freetz-ng
ARG FREETZ_CURRENT_COMMIT_HASH=eaf06dbb153d8ee2eabeedb827f1c8d80e409744
RUN git clone --depth 1 https://github.com/Freetz-NG/freetz-ng
WORKDIR $WORKDIR/freetz-ng
# will only work during runtime because we have to select something in the menu
#RUN make menuconfig

# ffritz
WORKDIR $WORKDIR
ARG BUILD_TARGET=6591
ARG FFRITZ_CURRENT_COMMIT_HASH=8a164ee31a200c10c16735320aa56dd726603339
RUN git clone --branch $BUILD_TARGET --depth 1 https://bitbucket.org/fesc2000/ffritz.git

WORKDIR $WORKDIR/ffritz
RUN cp ./user-oem.patch ./puma7/atom/ && \
    cp ./user-oem.patch ./puma7/arm/ && \
    make
