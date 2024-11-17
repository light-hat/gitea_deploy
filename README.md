# Dev server

## Setup

Requirements:

```bash
sudo apt update -y && sudo apt install -y docker docker-compose python3 python3-pip vim git
pip3 install boto3
```

Create `~/.aws/` with credentials:

```bash
mkdir ~/.aws/
vim ~/.aws/credentials
vim ~/.aws/config
```

File `credentials`:

```
[default]
  aws_access_key_id = <идентификатор_статического_ключа>
  aws_secret_access_key = <секретный_ключ>

```

File `config`:

```
[default]
  region=ru-central1

```

Clone a repo:

```bash
git clone https://git.area51-lab.ru/architect/dev_server
cd dev_server
```

## Deploy

Create `.env` file:

```yaml
USER_UID=1000
USER_GID=1000
GITEA__database__DB_TYPE=postgres
GITEA__database__HOST=gitea_db
GITEA__database__NAME=gitea
GITEA__database__USER=git3453453463456
GITEA__database__PASSWD=9ew4hyfr97e84trye4tregiytetreir7ftye
GITEA__mailer__ENABLED=true
GITEA__mailer__FROM=area51-lab@yandex.ru
GITEA__mailer__PROTOCOL=smtps
GITEA__mailer__SMTP_ADDR=smtp.yandex.ru
GITEA__mailer__SMTP_PORT=465
GITEA__mailer__USER=area51-lab
GITEA__mailer__PASSWD=shyiacppxexzurax
GITEA__ui__THEMES=gitea,arc-green
GITEA__ui__DEFAULT_THEME=arc-green
```

Create `.env.db` file:

```yaml
POSTGRES_USER=git3453453463456
POSTGRES_PASSWORD=9ew4hyfr97e84trye4tregiytetreir7ftye
POSTGRES_DB=gitea
```

Run:

```bash
sudo docker-compose up -d --build
```

## Reverse proxy

Default nginx config `/etc/nginx/sites-available/default`:

```bash
sudo rm /etc/nginx/sites-available/default
sudo vim /etc/nginx/sites-available/default
```

Set:

```nginx
upstream git {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name git.area51-lab.ru;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;
    ssl_certificate /etc/ssl/mycert.crt;
    ssl_certificate_key /etc/ssl/mykey.key;

    client_body_buffer_size     32k;
    client_header_buffer_size   8k;
    large_client_header_buffers 8 64k;

    client_max_body_size 30g;

    access_log /var/log/nginx/nginx-git-access.log;
    error_log /var/log/nginx/nginx-git-error.log;

    location / {
        proxy_pass http://git;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }
}

```

Restart Nginx:

```bash
sudo systemctl restart nginx
sudo systemctl status nginx
```

## Make backup

Create backup:

```bash
./take_dump.sh
```

Upload it to S3:

```bash
python3 backup.py -u <dump_name>
```

And yes... 

```
Every where write backup name without extension!
```

## Restore backup

Get backup from S3:

```bash
python3 backup.py -d <dump_name>
```

Run a clear stack:

```bash
sudo docker-compose up -d --build
```

Then restore downloaded backup:

```bash
./restore_dump.sh
```

## Cleanup

```bash
rm *.zip
sudo docker-compose down -v
sudo docker system prune -a
sudo rm -rf gitea/ gitea_database/
```
