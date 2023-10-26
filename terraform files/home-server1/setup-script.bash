#!/bin/bash

# folder structure
configpaths=/home-server/configs
mediapaths=/home-server/media
startupcomposes=/home-server/composes

$configpaths
$mediapaths



sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# to download github files
sudo apt-get install subversion -y

# create folder structure for config saves
sudo mkdir /home-server
sudo mkdir $configpaths
sudo mkdir $mediapaths

# download composes from github
sudo svn export https://github.com/arieluchka/home-server-azure/trunk/composes $startupcomposes


# JELLYFIN
# jellyfin folder creation

sudo mkdir $configpaths/jellyfin
sudo mkdir $configpaths/jellyfin/config
sudo mkdir $configpaths/jellyfin/cache
sudo mkdir $mediapaths/jellyfin/
sudo mkdir $mediapaths/jellyfin/media
sudo mkdir $mediapaths/jellyfin/media/shows
sudo mkdir $mediapaths/jellyfin/media/movies

# compose up
sudo docker compose -f $startupcomposes/jellyfin/docker-compose.yaml up -d

# QBITTORRENT
sudo mkdir $mediapaths/qbittorrent
sudo mkdir $mediapaths/qbittorrent/downloads

sudo mkdir $configpaths/qbittorrent
sudo mkdir $configpaths/qbittorrent/configs

# compose up
sudo docker compose -f $startupcomposes/qbittorrent/docker-compose.yaml up -d

# SONARR
sudo mkdir /home-server/configs/sonarr
sudo mkdir /home-server/configs/sonarr/config

sudo docker compose -f $startupcomposes/sonarr/docker-compose.yaml up -d


# PROWLARR

sudo mkdir /home-server/configs/prowlarr

# compose up
sudo docker compose -f $startupcomposes/prowlarr/docker-compose.yaml up -d

# JELLYSEER

sudo mkdir $configpaths/jellyseer

sudo docker compose -f $startupcomposes/jellyseer/docker-compose.yaml up -d


