#!/bin/sh

## start docker-fog 

FOG_DIR="/srv/fog"

SERVER_IP="192.168.200.1"
FOG_DIR=/srv/fog

docker run -id \
-p $SERVER_IP:212:212/udp \
-p $SERVER_IP:9098:9098 \
-p $SERVER_IP:21:21 \
-p $SERVER_IP:80:80 \
-p $SERVER_IP:69:69/udp \
-p $SERVER_IP:8099:8099 \
-p $SERVER_IP:2049:2049 \
-p $SERVER_IP:2049:2049/udp \
-p $SERVER_IP:111:111 \
-p $SERVER_IP:111:111/udp \
-p $SERVER_IP:4045:4045/udp \
-p $SERVER_IP:4045:4045 \
-p $SERVER_IP:34463:34463/udp \
-p $SERVER_IP:34463:34463 \
-p $SERVER_IP:32765:32765 \
-p $SERVER_IP:32765:32765/udp \
-p $SERVER_IP:32767:32767 \
-p $SERVER_IP:32767:32767/udp \
-e DB_NAME="fog" \
-e DB_USER="fogusr" \
-e DB_PASS="f0gp455t4" \
-e DB_ROOTPASS="" \
-e EXTIP="192.168.200.1" \
--privileged --security-opt apparmor=eddie303-fogproject -e WEB_HOST_PORT=80 --name=fog \
-v $FOG_DIR:/transfer -v $FOG_DIR/opt:/opt/fog -v $FOG_DIR/images:/images -v /tftpboot:/tftpboot eddie303/fogproject

