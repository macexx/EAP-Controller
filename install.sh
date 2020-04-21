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
apt-get -qy install software-properties-common wget net-tools jsvc


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
mkdir -p /config/cert
mkdir -p /config/work

# Checking if previous configuration exists

if [ -d "/config/data/map" ]; then
  echo "Config exists, importing previous configuration!"
  rm -r /opt/tplink/EAPController/data
  rm -r /opt/tplink/EAPController/logs
  rm -r /opt/tplink/EAPController/keystore
  rm -r /opt/tplink/EAPController/work
  ln -sf /config/data /opt/tplink/EAPController/data
  ln -sf /config/logs /opt/tplink/EAPController/logs
  ln -sf /config/keystore /opt/tplink/EAPController/keystore
  ln -sf /config/work /opt/tplink/EAPController/work
else
  echo "Copying configuration from install directory to host!"
  mv /opt/tplink/EAPController/data /config
  mv /opt/tplink/EAPController/logs /config
  mv /opt/tplink/EAPController/keystore /config
  mv /opt/tplink/EAPController/work /config
  ln -sf /config/data /opt/tplink/EAPController/data
  ln -sf /config/logs /opt/tplink/EAPController/logs
  ln -sf /config/keystore /opt/tplink/EAPController/keystore
  ln -sf /config/work /opt/tplink/EAPController/work
fi

# Checking if custom cert is available

if [ -f "/config/cert/mydomain.p12" ]; then
  echo "Custom cert is available, installing..."
  rm /config/keystore/eap.keystore
echo tplink | /opt/tplink/EAPController/jre/bin/keytool -importkeystore -srckeystore /config/cert/mydomain.p12 -srcstoretype PKCS12 -destkeystore /opt/tplink/EAPController/keystore/eap.keystore -deststorepass tplink -deststoretype pkcs12
fi
EOT


# Start upgrade of base system 
cat <<'EOT' > /etc/my_init.d/01_start.sh
#!/bin/bash
echo "Upgrading local packages(Security) - This might take awhile(first run takes some extra time)"
apt-get update -qq
apt-get upgrade -y -o Dpkg::Options::="--force-confdef"
echo "Upgrade Done...."
chown -R root:root /opt/tplink /config
/etc/init.d/tpeap start
EOT

chmod -R +x /etc/my_init.d/




#########################################
##             INTALLATION             ##
#########################################

cd /tmp
wget https://static.tp-link.com/2020/202004/20200409/Omada_Controller_v3.2.9_linux_x64.tar.gz
tar zxvf Omada_Controller_v3.2.9_linux_x64.tar.gz
chown -R root:root /tmp/Omada_Controller_v3.2.9_linux_x64
cd Omada_Controller_v3.2.9_linux_x64
chmod +x install.sh
sed -i '203d' install.sh
echo yes | ./install.sh
rm -R /tmp/Omada_Controller*
