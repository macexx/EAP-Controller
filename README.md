[![logo](https://i0.wp.com/homesecurity1st.co.za/wp-content/uploads/2017/02/TP-LINK_logo-300x130-1.jpg?fit=300%2C130&ssl=1)](https://www.tp-link.com/common/Spotlight/EAP_controller.html)

TP-Link EAP Controller
==========================


EAP Controller - https://www.tp-link.com/common/Spotlight/EAP_controller.html



Running on the latest Phusion release (ubuntu 16.04), with EAP Controller v2.5.3
ONLY X86!!!!!


**Pull image**

```
docker pull ruslanguns/eap-controller-docker
```

**Run container**

```
docker run -d --net="host" --privileged --name=<container name> -v <path for eap config files>:/config -v /etc/localtime:/etc/localtime:ro ruslanguns/eap-controller-docker
```
Please replace all user variables in the above command defined by <> with the correct values.
Use --net="host" or --net="macvlan0"

**Run  Docker Compose**

1. Create a new file called "docker-compose.yml" and fill it with the following information:

```
version: '3'
services:
  app:
    image: ruslanguns/eap-controller-docker
    restart: always
    network_mode: "host"
    ports:
      - "8088:8088"
      - "8043:8043"
      - "29810:29810/udp"
      - "29811:29811"
      - "29812:29812"
      - "29813:29813"
    volumes:
      - config:/config
      - /etc/localtime:/etc/localtime:ro
    
volumes:
    config:
```

2. Start docker-compose
```
docker compose -up -d
```

3. To stop
```
docker compose stop
```
4. To delete (must be stopped first)
```
docker-compose rm
```
then 
```
docker-compose down
```

**Web-UI**

```
http://<host ip>:8088
https://<host ip>:8043
```

**Example**

```
docker run -d --net="host"  --privileged --name=eapcontroller -v /mylocal/directory/fordata:/config -v /etc/localtime:/etc/localtime:ro mace/eap-controller
```


**Additional notes**

* For a custom cert, stop the container and put the cert in "/config/cert" it needs to be named "mydomain.p12" and have the password "tplink"
* The owner of the config directory needs sufficent permissions (UUID 99 / GID 100). (For manual configs, backups etc on the host system)
* Mongodb dosent start if "/config" is mapped to an fuse mount, shfs, mergerfs etc...
* Should be run with network "host" or "macvlan", so it can find the AP´s
* Username and password will be linked to controller (if you restore a backup this will only restore AP,SSID,etc... settings, not the base controller username/pass()EAP limitation)
* Always make an backup of your settings before a new release "EAP controller version"(for a reinstall with same version it´s not necessary)
* If it dosen´t start make sure there is just one controller on the same subnet (EAP limitataion)
* This buils is only X86 with TP-Links budeled binaries

**Change notes** by @macex

* 2018.06.19
Add keystore to config for custom certs

* 2018.02.16
Initial release
