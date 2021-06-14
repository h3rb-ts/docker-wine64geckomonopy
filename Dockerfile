FROM ubuntu:focal

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV WINEDEBUG fixme-all,warn+cursor
ENV WINEPREFIX /root/prefix64
ENV WINEARCH win64
ENV WINE_DOWNLOAD_PATH=~/.cache/wine

RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get -y install python2 python-is-python2 xvfb x11vnc xdotool wget tar supervisor net-tools fluxbox gnupg2 patch && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates cabextract git gosu gpg-agent p7zip pulseaudio pulseaudio-utils \
    libc6-dev-i386 libodbc1 libodbc1:i386 libodbc1 libsqliteodbc vim sqlite3 fvwm tzdata unzip wget	winbind \
        xvfb xvkbd python3 nano bash curl python3 python3-pip dos2unix gdal-bin zenity && \
    export CPLUS_INCLUDE_PATH=/usr/include/gdal && \
    export C_INCLUDE_PATH=/usr/include/gdal && \
    pip3 install --upgrade pip setuptools && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -  && \
    echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' |tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && apt-get -y install winehq-stable winetricks && \
    apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*


# Download Wine's Mono and Gecko -- doesn't detect :(
#RUN mkdir -p /opt/wine-stable/share/wine/mono && \
#    wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono && \
#    mv /opt/wine-stable/share/wine/mono/wine-mono-4.9.4/* /opt/wine-stable/share/wine/mono && \
#    mkdir -p /opt/wine-stable/share/wine/gecko && \
#    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi && \
#    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi 

# Download Wine's Mono and Gecko
RUN mkdir -p $WINE_DOWNLOAD_PATH/mono && \
    wget -O --progress=bar:force:noscroll $WINE_DOWNLOAD_PATH/mono/wine-mono-4.9.4.msi https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-4.9.4.msi && \
    mkdir -p $WINE_DOWNLOAD_PATH/gecko && \
    wget -O --progress=bar:force:noscroll $WINE_DOWNLOAD_PATH/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi && \
    wget -O --progress=bar:force:noscroll $WINE_DOWNLOAD_PATH/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi && \
    echo "Downloaded Mono and Gecko to $WINE_DOWNLOAD_PATH"
    
ENV DISPLAY :0

# Install novnc - but expose on dev copy only
WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html && \
    wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.9.0 /root/novnc/utils/websockify
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && chmod +x winetricks
