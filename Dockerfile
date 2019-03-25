# Builds a docker image for TP-Link´s  EAP Controller
From phusion/baseimage:latest
MAINTAINER Mace Capri <macecapri@gmail.com>


###############################################
##           ENVIRONMENTAL CONFIG            ##
###############################################
# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

###############################################
##   INTALL ENVIORMENT, INSTALL OPENVPN      ##
###############################################
COPY install.sh /tmp/
RUN chmod +x /tmp/install.sh && sleep 1 && /tmp/install.sh && rm /tmp/install.sh
RUN \
        ln -fs /usr/share/zoneinfo/America/Vancouver /etc/localtime && \
        dpkg-reconfigure -f noninteractive tzdata


###############################################
##             PORTS AND VOLUMES             ##
###############################################

#expose 8088/tcp
VOLUME /config
