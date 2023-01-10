FROM jlesage/baseimage-gui:debian-11-v4

ENV APP_NAME="iDRAC 6"  \
    IDRAC_PORT=443      \
    DISPLAY_WIDTH=801   \
    DISPLAY_HEIGHT=621

COPY keycode-hack.c /keycode-hack.c

COPY jdk7.tar.gz /tmp

RUN cd /tmp && \
    tar -xzf jdk7.tar.gz && \
    mkdir /opt/java -p && \
    /tmp/jdk1.7.0_60/* /opt/java && \
    echo PATH="/opt/java/bin:$PATH" | tee -a $HOME/.bashrc
    
RUN dpkg --add-architecture armhf && \
    apt-get update && apt-get install libc6:armhf -y && \
    java -version

RUN apt-get update && \
    apt-get install -y wget software-properties-common libx11-dev gcc xdotool && \
    gcc -o /keycode-hack.so /keycode-hack.c -shared -s -ldl -fPIC && \
    apt-get remove -y gcc software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /keycode-hack.c

RUN mkdir /app && \
    chown ${USER_ID}:${GROUP_ID} /app

RUN perl -i -pe 's/^(\h*jdk\.tls\.disabledAlgorithms\h*=\h*)([\w.\h<>\n\\,]*)(TLSv1[,\n\h]\h*)/$1$2/m' /usr/lib/jvm/zulu-7-amd64/jre/lib/security/java.security

COPY startapp.sh /startapp.sh
COPY mountiso.sh /mountiso.sh

WORKDIR /app
