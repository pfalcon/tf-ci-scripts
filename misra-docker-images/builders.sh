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

cd misra-dockerfiles

aws configure list
export ECR=987685672616.dkr.ecr.us-east-1.amazonaws.com
# we are expecting private files to be kept in the dockerfiles/*
# subdirs with a matching name for the image
aws s3 cp --recursive s3://trustedfirmware-misra/dockerfiles/ .
find .
aws ecr get-login-password --region us-east-1|docker login --username AWS --password-stdin $ECR


was_error=0

for image in ./*
do
    tag=$(basename $image)
    test -d $image  && test -f $image/build.sh && \
    (
        echo "=== Building image: misra:${tag} ==="
        set -ex
        touch /tmp/dckr-img-err
        cd $image
        ./build.sh
        echo "Uploading image: misra:${tag}"
        docker push $ECR/misra:$tag
        rm -f /tmp/dckr-img-err
    )

    if [ -f /tmp/dckr-img-err ]; then
        was_error=1
        echo "ERROR building image: misra:${tag}"
    fi
done

if [ "$was_error" == "1" ]; then
    echo "---------------------------------"
    echo "At least one image FAILED to build successfully. See the log above for ERRORs."
    exit 1
fi
