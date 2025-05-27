#!/bin/bash
source ./docker_params
VSCODE_COMMIT_HASH=$(code --version | sed -n '2p')
echo $VSCODE_COMMIT_HASH

#build the image
docker build \
    --file Dockerfile\
    --tag $image_name:$image_tag \
    --build-arg VSCODE_COMMIT_HASH=$VSCODE_COMMIT_HASH \
    .\