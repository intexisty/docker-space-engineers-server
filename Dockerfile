# Space Engineers Server
# Based on original work by webanck
# https://github.com/webanck/docker-wine-steam
# Adapted from work by marjacob
# https://github.com/marjacob/se-server
# Adapted from work done by chipwolf
# https://github.com/ChipWolf/docker-space-engineers-server

FROM debian
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

    # Updating and upgrading
    apt-get update && \
    apt-get upgrade -y && \

    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y --no-install-recommends unzip wget gpg-agent apt-transport-https && \

    # Add the wine repo
    wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \
    apt-get update && \

    # Installation of wine, winetricks and temporary xvfb
    apt-get install -y --install-recommends winehq-stable && \
    apt-get install -y --no-install-recommends winetricks xvfb && \

    # Installation of winbind to stop ntlm error messages
    apt-get install -y --no-install-recommends winbind && \

    # Installation of winetricks tricks as wine user
    su -p -l wine -c winecfg && \
    su -p -l wine -c 'xvfb-run -a winetricks -q corefonts' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q vcrun2013' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q dotnet20' ; \
    su -p -l wine -c 'xvfb-run -a winetricks -q dotnet461' ; \
    su -p -l wine -c 'xvfb-run -a winetricks -q xna40' && \
    su -p -l wine -c 'xvfb-run -a winetricks d3dx9' && \
    su -p -l wine -c 'xvfb-run -a winetricks -q directplay' && \

    # Installation of git, build tools, and sigmap
    apt-get install -y --no-install-recommends build-essential git-core && \
    git clone https://github.com/marjacob/sigmap.git && \
    (cd sigmap && exec make) && \
    install sigmap/bin/sigmap /usr/local/bin/sigmap && \
    rm -rf sigmap/ && \

    # Cleaning up
    apt-get autoremove -y --purge build-essential git-core && \
    apt-get autoremove -y --purge software-properties-common && \
    apt-get autoremove -y --purge wget gpg-agent apt-transport-https && \
    apt-get autoremove -y --purge xvfb && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /home/wine/.cache && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add the dedicated server files
ADD install.sh /install.sh
RUN /install.sh && rm /install.sh

# Launching the server as the wine user.
USER wine
ENTRYPOINT ["/usr/local/bin/sigmap", "-m 15:2", "/usr/local/bin/space-engineers-server", "-noconsole"]
CMD [""]
