#!/bin/bash

set -ex

if ! type aws
then
    sudo apt-get -y -qq update
    sudo apt-get -y -qq install --no-install-recommends unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
fi

rm -rf fvp-dockerfiles
git clone https://git.trustedfirmware.org/ci/fvp-dockerfiles.git
cd fvp-dockerfiles
git log -1

aws configure list
ECR=987685672616.dkr.ecr.us-east-1.amazonaws.com
aws s3 cp --recursive s3://trustedfirmware-fvp/ .
aws ecr get-login-password --region us-east-1|docker login --username AWS --password-stdin $ECR


for tarball in F*.tgz
do
    tag=$(./create-model-tag.sh $tarball)
    mkdir -p $tag
    cp setup-sshd stdout-flush-wrapper*.sh $tag/
    mv $tarball $tag/
    ./create-model-dockerfile.sh $tarball $tag
    (
        set -ex
        cd $tag
        docker build --tag $ECR/fvp:$tag .
        echo "Docker image created" && \
        echo "Docker image name: fvp:$${tag}"
        docker push $ECR/fvp:$tag
    )

done

