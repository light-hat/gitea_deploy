#!/bin/bash

echo -n "New backup name: "
read filename
USER=$(whoami)

sudo docker-compose exec -u git -w /app/gitea/ gitea bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini --file dump.zip'
sudo docker cp gitea:/app/gitea/dump.zip $filename.zip
sudo docker-compose exec -u git -w /app/gitea/ gitea rm dump.zip
sudo chown $USER:$USER $filename.zip
