#!/bin/bash

echo -n "Backup name: "
read filename

sudo docker cp $filename.zip gitea_database:/tmp/dump.zip
sudo docker-compose exec gitea_db apt update -y
sudo docker-compose exec gitea_db apt install -y unzip
sudo docker-compose exec -w /tmp/ gitea_db mkdir dump
sudo docker-compose exec -w /tmp/ gitea_db unzip dump.zip -d dump/
sudo docker-compose exec -w /tmp/dump/ gitea_db bash -c 'psql -d $POSTGRES_DB -U $POSTGRES_USER -f gitea-db.sql'
sudo docker-compose exec -w /tmp/ gitea_db rm dump.zip
sudo docker-compose exec -w /tmp/ gitea_db rm -rf dump/
sudo docker cp $filename.zip gitea:/app/gitea/dump.zip
sudo docker-compose exec -w /app/gitea/ gitea mkdir dump
sudo docker-compose exec -w /app/gitea/ gitea unzip dump.zip -d dump/
#sudo docker-compose exec -w /app/gitea/dump/ gitea cp app.ini /data/gitea/conf/app.ini
sudo docker-compose exec -w /app/gitea/dump/ gitea cp -R data/. /data/gitea
sudo docker-compose exec -w /app/gitea/dump/ gitea cp -R repos/. /data/git/gitea-repositories/
sudo docker-compose exec -w /app/gitea/dump/ gitea cp -R repos/. /data/git/repositories
sudo docker-compose exec -w /app/gitea/dump/ gitea chown -R git:git /data/gitea/conf/app.ini /data /data/git/repositories
sudo docker-compose exec -w /app/gitea/ gitea rm dump.zip
sudo docker-compose exec -w /app/gitea/ gitea rm -rf dump/
sudo docker-compose restart
