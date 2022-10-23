#!/usr/bin/env bash

LOCAL_DIR='./dist/app'
REMOTE_DIR="/var/www/angular-shop"

LOCAL_NGINX_CONF_FILE='./nginx/nginx.conf'
REMOTE_NGINX_CONF_FILE='/etc/nginx/nginx.conf'

prepareRemoteDir() {
    if ssh task3-aws "[ ! -d $1 ]"; then
        echo "Target folder was not found on remote. Creating..."
        ssh -t task3-aws "sudo bash -c 'mkdir -p $1 && chown -R ubuntu: $1'"
    else
        echo "Target folder was found on remote. Cleaning..."
        ssh task3-aws "rm -r $1/*"
    fi
}

prepareRemoteFile() {
    if ssh task3-aws "[ -f $1 ]"; then
        echo "Target file $1 was found on remote. Deleting..."
        ssh task3-aws "rm $1"
    fi
}

copyNginxConfToRemote() {
    prepareRemoteFile $REMOTE_NGINX_CONF_FILE
    echo "Copying $LOCAL_NGINX_CONF_FILE to $REMOTE_NGINX_CONF_FILE..."
    scp -C $LOCAL_NGINX_CONF_FILE task3-aws:$REMOTE_NGINX_CONF_FILE
}

copyBuildToRemote() {
    prepareRemoteDir $REMOTE_DIR
    echo "Copying $LOCAL_DIR/* to $REMOTE_DIR..."
    scp -CrO $LOCAL_DIR/* task3-aws:$REMOTE_DIR
}

restartNginxOnRemote() {
    ssh -t task3-aws "sudo systemctl restart nginx"
}

yarn install --frozen-lockfile --check-files

sh ./quality-check.sh
sh ./build-client.sh --configuration production

copyNginxConfToRemote
copyBuildToRemote
restartNginxOnRemote
