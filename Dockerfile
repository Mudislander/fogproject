FROM ubuntu:16.04
MAINTAINER Guillem Tanyà <gtanya@opentrends.net>

RUN apt update && apt upgrade -y

RUN apt install -y wget iproute2 software-properties-common language-pack-en jq

ENV VERSION=1.5.5

RUN wget https://github.com/FOGProject/fogproject/archive/${VERSION}.tar.gz \
 && tar xvfz ${VERSION}.tar.gz \
 && cd fogproject-${VERSION}/bin \
 && mkdir -p /backup \
 && bash ./installfog.sh  --autoaccept

# remove obsolet pifdiles
#RUN rm -f /var/run/fog/FOG*

# force redirect to FOG root URL from Apache base URL's
COPY assets/index.php /var/www
COPY assets/index.php /var/www/html
RUN rm /var/www/html/index.html


# patch vsftpd init file because start with failure
ADD assets/vsftpd.patch .
RUN patch /etc/init.d/vsftpd vsftpd.patch && rm -f vsftpd.patch

# remove FOG sources
RUN rm -rf /fogproject-* /${VERSION}.tar.gz


# saving default data
RUN mkdir -p /opt/fog/default/
RUN cp -rp /var/lib/mysql /opt/fog/default/
RUN cp -rp /images /opt/fog/default/

RUN touch /INIT
ADD assets/entry.sh .
CMD bash entry.sh






