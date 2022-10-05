#!/bin/bash

docker --version

if ! type aws
then
    sudo apt-get -y -qq update
    sudo apt-get -y -qq install --no-install-recommends unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

aws configure list
export ECR=987685672616.dkr.ecr.us-east-1.amazonaws.com
export REPO=misra
aws ecr get-login-password --region us-east-1|docker login --username AWS --password-stdin $ECR

for image in $(aws ecr list-images --repository-name $REPO | \
    grep imageTag | \
    awk '{print $2}' | \
    sed 's/"//g'); do

    docker pull $ECR/$REPO:$image
done
