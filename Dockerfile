FROM ubuntu:latest
MAINTAINER Eduard Istvan Sas <eduard.istvan.sas@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ADD docker-entrypoint.sh /usr/local/bin/
ADD fixChain.py /usr/local/bin
ADD respond.txt /tmp

RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Bucharest /etc/localtime \
 && echo "Europe/Bucharest" > /etc/timezone \
 && apt-get update \
 && apt-get -y dist-upgrade \
 && apt-get update \
 && apt-get install -y iproute2 git \
# && ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld \
 && cd /tmp \
 && git clone https://github.com/fogproject/fogproject.git fog/ \
 && cd fog/bin \
 && export LANG=C.UTF-8 \
 && cat /tmp/respond.txt | bash ./installfog.sh -X \
 && sed -i s/"manage-gids"/"manage-gids -p 32765"/g /etc/default/nfs-kernel-server \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && tar czvf /tmp/tftpboot-content.tar.gz /tftpboot/*

# Apache musthave env vars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 21/tcp 80/tcp 111/tcp 2049/tcp 4045/tcp 8099/tcp 9098/tcp 34463/tcp 69/udp 111/udp 212/udp 2049/udp 4045/udp 34463/udp

CMD ["/usr/local/bin/docker-entrypoint.sh"]

