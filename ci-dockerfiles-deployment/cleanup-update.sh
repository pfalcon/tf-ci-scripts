#!/bin/bash -e

for image in $(docker images|grep trustedfirmware|grep -v none|awk '{ print $1":"$2}');
do
    echo update: $image:
    if ! docker pull $image
    then
        echo could not fetch image from dockerhub, delete
        docker rmi $image||true
    fi
done

echo cleaning up
docker system prune -f
