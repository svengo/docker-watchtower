# Build image

FROM golang:latest as watchtower

RUN \
  cd $GOPATH/src && \
  mkdir --parents github.com/v2tec && \
  cd github.com/v2tec && \
  git clone https://github.com/v2tec/watchtower.git && \
  cd watchtower && \
  go get -u github.com/Masterminds/glide && \
  glide install %&& \
  CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' . && \
  go test


# Alpine

FROM alpine:latest as alpine
RUN apk add --no-cache \
    ca-certificates \
    tzdata


# watchtower image

FROM scratch
LABEL "com.centurylinklabs.watchtower"="true"

# copy files from other containers
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=alpine /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=watchtower /go/src/github.com/v2tec/watchtower/watchtower /

ENTRYPOINT ["/watchtower"]
