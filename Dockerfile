FROM jlesage/baseimage-gui:debian-11-v4

ENV APP_NAME="iDRAC 6"  \
    IDRAC_PORT=443      \
    DISPLAY_WIDTH=801   \
    DISPLAY_HEIGHT=621

RUN apt-get update && \
    apt-get install -y locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8

RUN APP_ICON_URL=https://raw.githubusercontent.com/Re4zOon/docker-idrac6/03146e132df761552a76786c6412b5c9d15a99c7/icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

COPY keycode-hack.c /keycode-hack.c

COPY jdk7.tar.gz /tmp

RUN cd /tmp && \
    tar -xzf jdk7.tar.gz && \
    mkdir /opt/java -p && \
    mv /tmp/jdk1.7.0_60/* /opt/java
    
ENV PATH="${PATH}:/opt/java/bin"

RUN echo $PATH && \
    dpkg --add-architecture armhf && \
    apt-get update && apt-get install libc6:armhf -y && \
    java -version

RUN apt-get update && \
    apt-get install -y wget software-properties-common libx11-dev gcc xdotool && \
    gcc -o /keycode-hack.so /keycode-hack.c -shared -s -ldl -fPIC && \
    apt-get remove -y gcc software-properties-common

RUN apt-get autoremove -y

RUN apt-get install -y libxext6:armhf libxrender1:armhf libxtst6:armhf

RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /keycode-hack.c

RUN mkdir /app && \
    chown ${USER_ID}:${GROUP_ID} /app

RUN perl -i -pe 's/^(\h*jdk\.tls\.disabledAlgorithms\h*=\h*)([\w.\h<>\n\\,]*)(TLSv1[,\n\h]\h*)/$1$2/m' /opt/java/jre/lib/security/java.security

COPY startapp.sh /startapp.sh
COPY mountiso.sh /mountiso.sh

WORKDIR /app
