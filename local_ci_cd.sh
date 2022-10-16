#!/usr/bin/env bash

LOCAL_DOCKER_DIR="./dockers"
REMOTE_DOCKER_DIR="/var/dockers/example-monorepo"

prepareRemoteDir() {
    if ssh mint-vm "[ ! -d $1 ]"; then
        echo "Target folder was not found on remote. Creating..."
        ssh -t mint-vm "sudo bash -c 'mkdir -p $1 && chown -R sshuser: $1'"
    else
        echo "Target folder was found on remote. Cleaning..."
        ssh mint-vm "rm -r $1/*"
    fi
}

copyDockerToRemote() {
    prepareRemoteDir $REMOTE_DOCKER_DIR
    echo "Copying..."
    scp -CrO $LOCAL_DOCKER_DIR/* mint-vm:$REMOTE_DOCKER_DIR
}

yarn install --frozen-lockfile --check-files
yarn build
cd $LOCAL_DOCKER_DIR
sh ./prepare-docker-files.sh
cd ../

copyDockerToRemote