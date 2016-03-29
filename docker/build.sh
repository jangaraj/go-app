#!/bin/bash
export GIT_REVISION=aaaaa
export BUILD_DATE=$(date +%Y-%m-%d)
export LD_FLAGS="-X main.gitRevision=${GIT_REVISION} -X main.buildDate=${BUILD_DATE}"
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):$(which docker) -ti google/golang CGO_ENABLED=0 GOOS=linux go build -a -ldflags  