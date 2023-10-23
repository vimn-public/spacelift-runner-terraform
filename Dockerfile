FROM golang:1.17-alpine as ssm-builder

ARG VERSION=1.2.497.0

RUN set -ex && apk add --no-cache make git gcc libc-dev curl bash zip && \
  curl -sLO https://github.com/aws/session-manager-plugin/archive/${VERSION}.tar.gz && \
  mkdir -p /go/src/github.com && \
  tar xzf ${VERSION}.tar.gz && \
  mv session-manager-plugin-${VERSION} /go/src/github.com/session-manager-plugin && \
  cd /go/src/github.com/session-manager-plugin && \
  make release

FROM public.ecr.aws/spacelift/runner-terraform:latest

WORKDIR /tmp

COPY --from=ssm-builder /go/src/github.com/session-manager-plugin/bin/linux_amd64_plugin/session-manager-plugin /usr/local/bin/
ADD files/before_init /usr/local/bin
ADD files/state-credentials.tf /usr
ADD files/proxy /usr/local/bin

RUN mkdir ~/.ssh && \
  echo "Host *" > ~/.ssh/config && \
  echo "  StrictHostKeyChecking no" >> ~/.ssh/config && \
  echo "  ServerAliveInterval 180" >> ~/.ssh/config && \
  echo "  ServerAliveCountMax 1800" >> ~/.ssh/config && \
  echo "  UserKnownHostsFile=/dev/null" >> ~/.ssh/config && \
  chmod 700 ~/.ssh && \
  chmod 600 ~/.ssh/config