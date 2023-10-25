#!/bin/bash






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
sudo mkdir /home-server/configs
sudo mkdir /home-server/large-media

# download composes from github
sudo svn export https://github.com/arieluchka/home-server-azure/trunk/composes /home-server/composes


# JELLYFIN
# jellyfin folder creation

sudo mkdir /home-server/configs/jellyfin
sudo mkdir /home-server/configs/jellyfin/config
sudo mkdir /home-server/configs/jellyfin/cache
sudo mkdir /home-server/large-media/jellyfin/
sudo mkdir /home-server/large-media/jellyfin/media
sudo mkdir /home-server/large-media/jellyfin/media/shows
sudo mkdir /home-server/large-media/jellyfin/media/movies

# compose up
sudo docker compose -f /home-server/large-media/jellyfin/docker-compose.yaml up -d

# qbittorrent
sudo mkdir /home-server/large-media/qbittorrent
sudo mkdir /home-server/configs/qbittorrent

sudo mkdir /home-server/large-media/qbittorrent/downloads
sudo mkdir /home-server/configs/qbittorrent/configs

# compose up
sudo docker compose -f /home-server/large-media/qbittorrent/docker-compose.yaml up -d

# SONARR

sudo mkdir /home-server/configs/sonarr
sudo mkdir /home-server/configs/sonarr/config

sudo docker compose -f /home-server/large-media/sonarr/docker-compose.yaml up -d


# PROWLARR

sudo mkdir /home-server/configs/prowlarr

# compose up
sudo docker compose -f /home-server/large-media/prowlarr/docker-compose.yaml up -d





