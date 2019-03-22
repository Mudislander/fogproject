#!/bin/sh
## Database user and password must be included in the variables DB_USER, DB_PASS and DB_NAME
DB_HOSTNAME=`echo $DB_PORT | cut -f3 -d/ | cut -f1 -d:`
DB_PORT_INT=`echo $DB_PORT | cut -f3 -d:`
DB_HOST_INT=${DB_HOSTNAME:-"localhost"}
DB_NAME_INT=${DB_NAME:-"fog"}
DB_USER_INT=${DB_USER:-"root"}
DB_ROOT_INT=${DB_ROOT:-"root"}
DB_PASS_INT=${DB_PASS:-""}

# Change database access info
sed -i "s/define('DATABASE_HOST', 'localhost');/define('DATABASE_HOST', '$DB_HOSTNAME');/g" /var/www/fog/lib/fog/config.class.php
sed -i "s/define('DATABASE_NAME', 'fog');/define('DATABASE_NAME', '$DB_NAME_INT');/g" /var/www/fog/lib/fog/config.class.php
sed -i "s/define('DATABASE_USERNAME', 'root');/define('DATABASE_USERNAME', '$DB_USER_INT');/g" /var/www/fog/lib/fog/config.class.php
sed -i "s/define('DATABASE_PASSWORD', '');/define('DATABASE_PASSWORD', '$DB_PASS_INT');/g" /var/www/fog/lib/fog/config.class.php

# Try to get IP Address and active network interface on the specific subnet
if [ -n "$EXTIP" ]; then
  ACTIVE_ETH_TMP=`ip addr show | grep $EXTIP | awk -- '{ print $7 }'`
  ACTIVE_ETH=${ACTIVE_ETH_TMP:-"eth0"}
else
  ACTIVE_ETH=`ip route get 1.1.1.1 | awk -- '{ print $5 }'`
  export EXTIP=`ip addr show $ACTIVE_ETH | grep inet\ | awk -- '{print $2 }' | cut -f1 -d/`
fi
export ACTIVE_ETH

# Set Apache2 ports.conf to listen on this IP address only
ACTUAL_IP=`ip addr show dev $ACTIVE_ETH | grep inet\ | awk -- '{print $2 }' | cut -f1 -d/`
sed -i 5s/Listen.*/Listen\ $ACTUAL_IP:80/g /etc/apache2/ports.conf
sed -i 8s/Listen.*/Listen\ $ACTUAL_IP:443/g /etc/apache2/ports.conf
sed -i 12s/Listen.*/Listen\ $ACTUAL_IP:443/g /etc/apache2/ports.conf


touch /opt/fog/.fogsettings

# Touch .mntcheck files before we get kicked out because the client does not see the file and thinks NFS cannot be mounted
chown fog:fog /images -R
if [ ! -d /images/dev ]; then
  mkdir /images/dev
fi
touch /images/.mntcheck
touch /images/dev/.mntcheck

# Populate /tftpboot if it is mounted as external volume
tar xzvf /tmp/tftpboot-content.tar.gz -C /
rm /tmp/*
python3 /usr/local/bin/fixChain.py

#Start services
if [ "$DB_HOSTNAME" = "" ]; then
  /etc/init.d/mysql start
fi
/etc/init.d/rpcbind start
/etc/init.d/vsftpd start
/etc/init.d/tftpd-hpa start
/etc/init.d/nfs-kernel-server start
/etc/init.d/php7.2-fpm start

# Check if database exists
DB_EXISTS=`mysql -h $DB_HOST_INT -u $DB_USER_INT -p$DB_PASS_INT --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME_INT'"`
if [ ! -n "$DB_EXISTS" ]; then
  if [ -n "$DB_ROOTPASS" ]; then 
    mysql -h $DB_HOST_INT -u root -p$DB_ROOTPASS -e "CREATE DATABASE $DB_NAME_INT;"
    mysql -h $DB_HOST_INT -u root -p$DB_ROOTPASS -e "GRANT ALL PRIVILEGES ON $DB_NAME_INT.* TO '$DB_USER_INT'@'%' IDENTIFIED BY '$DB_PASS' WITH GRANT OPTION;"
    mysql -h $DB_HOST_INT -u root -p$DB_ROOTPASS -e "GRANT CREATE USER ON *.* TO $DB_USER_INT WITH GRANT OPTION;"
  else
    mysql -h $DB_HOST_INT -u root -e "CREATE DATABASE $DB_NAME_INT;"
    mysql -h $DB_HOST_INT -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME_INT.* TO '$DB_USER_INT'@'%' IDENTIFIED BY '$DB_PASS' WITH GRANT OPTION;"
    mysql -h $DB_HOST_INT -u root -e "GRANT CREATE USER ON *.* TO $DB_USER_INT WITH GRANT OPTION;"
  fi
fi
/usr/sbin/apachectl -D FOREGROUND
