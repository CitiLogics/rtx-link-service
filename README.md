# rtx-link-service
This repository contains the docker-compose file  and setup scripts to initialize the cloud backend for RTX:LINK

## Guide

```
git clone https://github.com/CitiLogics/rtx-link-service.git
cd rtx-link-service
./install-compose.sh
docker-compose up -d
./influx-init.sh -u rootUser -p rootPass
```
