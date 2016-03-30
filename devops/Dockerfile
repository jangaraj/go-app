FROM google/golang

RUN \
  echo 'Building binary for small Docker image' && \
  export GIT_REVISION=aaaaa && \
  export BUILD_DATE=$(date +%Y-%m-%d) && \
  export LD_FLAGS="-s -X main.gitRevision=${GIT_REVISION} -X main.buildDate=${BUILD_DATE}" && \
  CGO_ENABLED=0 go get -a -ldflags "${LD_FLAGS}" github.com/jangaraj/go-app && \
  mkdir build && \
  cp /go/src/github.com/jangaraj/go-app/Dockerfile / && \
  cp /go/bin/go-app /main                                  
CMD echo 'only for docker build'