#!/bin/bash
export TAG=v1
docker build --rm=true -t jangaraj/go-build:binary github.com/jangaraj/go-build
docker run --rm=true -ti -v $PWD:/tmp jangaraj/go-build:binary cp /main /tmp
docker run --rm=true -ti -v $PWD:/tmp jangaraj/go-build:binary cp /Dockerfile /tmp/Dockerfile-app
docker build --rm=true -t jangaraj/go-app:$TAG -f Dockerfile-app .
docker images | grep jangaraj/go-app
docker push jangaraj/go-app:$TAG || true  

# clean space
rm -rf main
rm -rf Dockerfile-app
docker rmi -f jangaraj/go-build:binary 
