#!/bin/bash

# folder structure
configpaths=/home-server/configs
mediapaths=/home-server/media
startupcomposes=/home-server/composes
upload=yes


# MOUNT CLOUD SAVE
################
sudo mkdir /mnt/home-server-save
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/homeserverarieluchka.cred" ]; then
    sudo bash -c 'echo "username=homeserverarieluchka" >> /etc/smbcredentials/homeserverarieluchka.cred'
    sudo bash -c 'echo "password=M1o0Gxu4mnA8rD+jQiQNQ1szL0w6FOyzgWcGU/K9p2WJ2BBitvG18oBmJ1QS+RlC9Y3Wg+YoDsJR+AStgcU3ow==" >> /etc/smbcredentials/homeserverarieluchka.cred'
fi
sudo chmod 600 /etc/smbcredentials/homeserverarieluchka.cred

sudo bash -c 'echo "//homeserverarieluchka.file.core.windows.net/home-server /mnt/home-server-save cifs nofail,credentials=/etc/smbcredentials/homeserverarieluchka.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //homeserverarieluchka.file.core.windows.net/home-server /mnt/home-server-save -o credentials=/etc/smbcredentials/homeserverarieluchka.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
################


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

# create users and groups
sudo groupadd -g 1200 media-server
sudo useradd -U -u 1201 sonarr
sudo useradd -U -u 1202 radarr
sudo useradd -U -u 1203 qbit
sudo useradd -U -u 1204 jellyfin
sudo useradd -U -u 1205 jellyseerr
sudo useradd -U -u 1206 prowlarr

#add services to same group
gpasswd -M sonarr,radarr,qbit,jellyfin,jellyseerr,prowlarr media-server



# create folder structure for config saves
sudo mkdir /home-server
sudo mkdir $configpaths
sudo mkdir $mediapaths

# download composes from github
sudo svn export https://github.com/arieluchka/home-server-azure/trunk/composes $startupcomposes


if [ $upload = yes ]
then
    sudo cp -r -f /mnt/home-server-save/configs /home-server
fi





# JELLYFIN
# jellyfin folder creation
sudo mkdir $configpaths/jellyfin
sudo mkdir $configpaths/jellyfin/config
sudo mkdir $configpaths/jellyfin/cache
sudo chown -R jellyfin:jellyfin $configpaths/jellyfin
sudo chmod -R 770 $configpaths/jellyfin

sudo mkdir $mediapaths/jellyfin/
sudo mkdir $mediapaths/jellyfin/media
sudo mkdir $mediapaths/jellyfin/media/shows
sudo mkdir $mediapaths/jellyfin/media/movies
sudo chown -R jellyfin:media-server $mediapaths/jellyfin/
sudo chmod -R 774 $mediapaths/jellyfin/

sudo docker compose -f $startupcomposes/jellyfin/docker-compose.yaml up -d


# QBITTORRENT
sudo mkdir $mediapaths/qbittorrent
sudo mkdir $mediapaths/qbittorrent/downloads
sudo chown -R qbit:media-server $mediapaths/qbittorrent/
sudo chmod -R 774 $mediapaths/qbittorrent/

sudo mkdir $configpaths/qbittorrent
sudo mkdir $configpaths/qbittorrent/configs
sudo chown -R qbit:qbit $configpaths/qbittorrent
sudo chmod -R 770 $configpaths/qbittorrent

sudo docker compose -f $startupcomposes/qbittorrent/docker-compose.yaml up -d


# SONARR
sudo mkdir $configpaths/sonarr
sudo mkdir $configpaths/sonarr/config
sudo chown -R sonarr:sonarr $configpaths/sonarr
sudo chmod -R 770 $configpaths/sonarr

sudo docker compose -f $startupcomposes/sonarr/docker-compose.yaml up -d

# RADARR
sudo mkdir $configpaths/radarr
sudo mkdir $configpaths/radarr/config
sudo chown -R radarr:radarr $configpaths/radarr
sudo chmod -R 770 $configpaths/radarr

sudo docker compose -f $startupcomposes/radarr/docker-compose.yaml up -d


# PROWLARR
sudo mkdir $configpaths/prowlarr
sudo chown -R prowlarr:prowlarr $configpaths/prowlarr
sudo chmod -R 770 $configpaths/prowlarr

sudo docker compose -f $startupcomposes/prowlarr/docker-compose.yaml up -d


# JELLYSEERR
sudo mkdir $configpaths/jellyseerr
sudo chown -R jellyseerr:jellyseerr $configpaths/jellyseerr
sudo chmod -R 770 $configpaths/jellyseerr

sudo docker compose -f $startupcomposes/jellyseerr/docker-compose.yaml up -d



# change ownership to media



# change ownership to configs





# crontab to save configs
# echo "0,15,30,45 * * * * cp -r -f /home-server/configs /mnt/home-server-save" | sudo crontab -u root -
