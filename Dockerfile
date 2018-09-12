#
# Builder
#

FROM golang:alpine as builder
RUN \
  apk add --no-cache \
    alpine-sdk \
    ca-certificates \
    git \
    tzdata && \
  \
  mkdir --parents $GOPATH/src/github.com/v2tec && \
  cd $GOPATH/src/github.com/v2tec && \
  git clone https://github.com/v2tec/watchtower.git && \
  cd watchtower && \
  \
  curl https://glide.sh/get | sh && \
  glide install && \
  \
  CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' . && \
  go test


#
# watchtower
#

FROM scratch

LABEL "com.centurylinklabs.watchtower"="true"

# copy files from other container
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /go/src/github.com/v2tec/watchtower/watchtower /watchtower

ENTRYPOINT ["/watchtower"]
