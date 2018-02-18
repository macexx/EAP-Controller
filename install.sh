#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings config will still be run as root
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home


# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh


#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Install Dependencies
apt-get -qq update
apt-get -qy install software-properties-common wget net-tools


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Initiate config directory
mkdir -p /config


# Setup Ddirectories
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash

# Create Directories

mkdir -p /config/logs
mkdir -p /config/data
mkdir -p /config/keystore

# Checking if previous configuration exists

if [ -d "/config/data/map" ]; then
  echo "Config exists, importing previous configuration!"
  rm -r /opt/tplink/EAPController/data
  rm -r /opt/tplink/EAPController/logs
  rm -r /opt/tplink/EAPController/keystore
  ln -sf /config/data /opt/tplink/EAPController/data
  ln -sf /config/logs /opt/tplink/EAPController/logs
  ln -sf /config/keystore /opt/tplink/EAPController/keystore
else
  echo "Copying configuration from install directory to host!"
  mv /opt/tplink/EAPController/data /config
  mv /opt/tplink/EAPController/logs /config
  mv /opt/tplink/EAPController/keystore /config
  ln -sf /config/data /opt/tplink/EAPController/data
  ln -sf /config/logs /opt/tplink/EAPController/logs
  ln -sf /config/keystore /opt/tplink/EAPController/keystore
fi
EOT


# Start upgrade of base system and start eap
cat <<'EOT' > /etc/my_init.d/01_start.sh
#!/bin/bash
echo "Upgrading local packages(Security) - This might take awhile(first run takes some extra time)"
apt-get update -qq && apt-get upgrade -yqq
echo "Upgrade Done...."
/etc/init.d/tpeap start
EOT

chmod -R +x /etc/my_init.d/


#########################################
##             INTALLATION             ##
#########################################

cd /tmp
wget http://static.tp-link.com/resources/software/EAP_Controller_v2.5.3_linux_x64.tar.gz
tar zxvf EAP_Controller_v2.5.3_linux_x64.tar.gz
cd EAP_Controller_v2.5.3_linux_x64
echo yes | ./install.sh

