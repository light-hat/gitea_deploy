#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import boto3
import botocore
import logging
import argparse


console_logger = logging.StreamHandler()

logging.basicConfig(handlers=(console_logger,), 
    format='[%(asctime)s | %(levelname)s]: %(message)s', 
    datefmt='%m.%d.%Y %H:%M:%S',
    level=logging.INFO)

session = boto3.session.Session()

BUCKET = 'area51-git-backup'


if __name__ == '__main__':
    
    s3 = session.client(
        service_name='s3',
        endpoint_url='https://storage.yandexcloud.net'
    )

    parser = argparse.ArgumentParser(description="Automated backup and restore Gitea with Yandex Cloud S3.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-u', '--upload', help="New backup name. Zip-file name equals S3 key of backup.")
    group.add_argument('-d', '--download', help="Backup key in S3")
    args = parser.parse_args()

    if args.upload:
        logging.info(f"Uploading backup: {args.upload}")
        
        try:
            s3.upload_file(f"{args.upload}.zip", BUCKET, args.upload)
        
        except:
            logging.critical(f"No backup file {args.upload}.zip")
            exit(1)

        logging.info("OK")

    elif args.download:
        logging.info(f"Downloading backup: {args.download}")
        
        try:
            s3.download_file(BUCKET, args.download, f"{args.download}.zip")

        except botocore.exceptions.NoCredentialsError:
            logging.critical("Backup not found in storage.")
            exit(1)
        
        logging.info("OK")
