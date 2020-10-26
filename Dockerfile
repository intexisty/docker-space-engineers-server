# Space Engineers Server
# Based on original work by webanck
# https://github.com/webanck/docker-wine-steam
# Adapted from work by marjacob
# https://github.com/marjacob/se-server
# Adapted from work done by chipwolf
# https://github.com/ChipWolf/docker-space-engineers-server

FROM debian:10.6
MAINTAINER Aidan J Culley <culley.aidan@gmail.com> 

# Creating the wine user and setting up dedicated non-root environment.
RUN useradd -u 256 -d /home/wine -m -s /bin/bash wine
ENV HOME /home/wine
WORKDIR /home/wine

# Setting up the wineprefix to force 64 bit architecture.
ENV WINEPREFIX /home/wine/.wine
ENV WINEARCH win64

# Disabling warning messages from wine, comment for debug purpose.
ENV WINEDEBUG -all

# Disable interaction from package installation during the docker image building.
ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
    # Configuring sources
    echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list && \

    # Updating and upgrading
    apt-get update && \
    apt-get install -y gpg-agent && \
    apt-get upgrade -y && \
    apt-get install -y gpg-agent && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B && \
    echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main" >> /etc/apt/sources.list && \
    echo "deb-src http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main" >> /etc/apt/sources.list && \
    apt-get update && \

    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get update &&\
    apt-get -y install apt-fast && \
    apt-fast install -y --no-install-recommends unzip wget gpg-agent apt-transport-https && \

    # Installation of wine, winetricks and temporary xvfb
    apt-fast install -y --install-recommends wine && \
    apt-fast install -y --no-install-recommends winetricks xvfb winbind xauth && \

    # Installation of winetricks tricks as wine user
    su -p -l wine -c winecfg && \
    su -p -l wine -c 'env WINEPREFIX=$HOME/winedotnet winetricks win7' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q corefonts' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q vcrun2013' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q vcrun2017' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q dotnet461' ; \
    su -p -l wine -c 'xvfb-run -a winetricks -q xna40' && \
    su -p -l wine -c 'xvfb-run -a winetricks d3dx9' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q directplay' && \
    
    # Installation of git, build tools, and sigmap
    apt-fast install -y --no-install-recommends build-essential git-core && \
    git clone https://github.com/marjacob/sigmap.git && \
    (cd sigmap && exec make) && \
    install sigmap/bin/sigmap /usr/local/bin/sigmap && \
    rm -rf sigmap/ && \

    # Cleaning up
    apt-fast autoremove -y --purge build-essential git-core && \
    apt-fast autoremove -y --purge software-properties-common && \
    apt-fast autoremove -y --purge wget gpg-agent apt-transport-https && \
    apt-fast autoremove -y --purge xvfb && \
    apt-fast autoremove -y --purge && \
    apt-fast clean -y && \
    rm -rf /home/wine/.cache && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add the dedicated server files
ADD install.sh /install.sh
RUN /install.sh && rm /install.sh

# Launching the server as the wine user.
USER wine
ENTRYPOINT ["/usr/local/bin/sigmap", "-m 15:2", "/usr/local/bin/space-engineers-server", "-noconsole"]
CMD [""]
