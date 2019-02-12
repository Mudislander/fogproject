#!/bin/bash

rm -f /var/run/fog/FOG*
rm -rf /var/run/mysqld/mysqld.sock.lock

DEFAULT_DATA="/opt/fog/default"
DEFAULT_DATA_MYSQL="${DEFAULT_DATA}/mysql"
DEFAULT_DATA_IMAGES="${DEFAULT_DATA}/images"

MYSQL_DATA="/var/lib/mysql/"
IMAGES_DATA="/images"

if [ -z "$(ls -A /var/lib/mysql)" ]; then
    cp -rp ${DEFAULT_DATA_MYSQL}/* $MYSQL_DATA
fi
if [ -z "$(ls -A /images)" ]; then
    cp -rp ${DEFAULT_DATA_IMAGES}/* $IMAGES_DATA
fi

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chown -R fog:fog /images
chown -R fog:fog /backup

/etc/init.d/rsyslog start


source /opt/fog/.fogsettings

/etc/init.d/mysql start

# search and replace ip
if [ $IP ] && [ "${IP}" !=  "${ipaddress}" ] ; then
  mysqldump -u root fog > dump.sql
  sed -i 's,'${ipaddress}','${IP}',g' /dump.sql \
                                      /tftpboot/default.ipxe \
                                      /var/www/fog/lib/fog/config.class.php \
                                      /var/www/html/fog/lib/fog/config.class.php \
                                      /etc/apache2/sites-enabled/001-fog.conf \
                                      /opt/fog/.fogsettings
  mysql -u root fog < dump.sql && rm -f dump.sql

  ipaddress=$IP
fi

if [ -z $WEBSERVER_HTTP_PORT ] ; then
    WEBSERVER_HTTP_PORT=80
fi

sed -i -E "s/^Listen (.*)/Listen ${WEBSERVER_HTTP_PORT}/" /etc/apache2/ports.conf
sed -i -E "s/^<VirtualHost *:(.*)>/<VirtualHost *:${WEBSERVER_HTTP_PORT}>/" /etc/apache2/sites-enabled/001-fog.conf
sed -i -E "s/chain http(.*)/chain http:\/\/${ipaddress}:${WEBSERVER_HTTP_PORT}\/fog\/service\/ipxe\/boot.php/" /tftpboot/default.ipxe
sed -i -E "s/'WEB_HOST', \"(.*)\"/'WEB_HOST', \"${ipaddress}:${WEBSERVER_HTTP_PORT}\"/" /var/www/fog/lib/fog/config.class.php
mysql -e "UPDATE globalSettings set settingValue='${ipaddress}:${WEBSERVER_HTTP_PORT}' WHERE settingKey='FOG_WEB_HOST'" fog


/etc/init.d/xinetd start
/etc/init.d/php7.1-fpm start
/etc/init.d/apache2 start
#/etc/init.d/nfs-kernel-server start
/etc/init.d/vsftpd start
/etc/init.d/FOGImageReplicator start
/etc/init.d/FOGImageSize start
/etc/init.d/FOGMulticastManager start
/etc/init.d/FOGPingHosts start
/etc/init.d/FOGScheduler start
/etc/init.d/FOGSnapinHash start
/etc/init.d/FOGSnapinReplicator start

if [ -f /INIT ] ; then

  echo ""
  echo "You can now login to the FOG Management Portal using
the information listed below.  The login information
is only if this is the first install.

This can be done by opening a web browser and going to:"
  if [ ${IP} ] ; then
    echo "http://${IP}/fog/management"
  else
    echo "http://${ipaddress}/fog/management"
  fi

  rm -f /INIT
fi


# prevent start&exit containter process
while true; do sleep 1000; done