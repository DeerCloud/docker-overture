FROM golang:alpine AS builder

LABEL maintainer="metowolf <i@i-meto.com>"

ARG VERSION=1.4

RUN apk upgrade \
    && apk add \
      gcc \
      git \
      musl-dev \
      upx \
    && go get -d -v github.com/shawn1m/overture/main \
    && mkdir build \
    && cd build \
    && wget https://github.com/shawn1m/overture/archive/v${VERSION}.tar.gz \
    && tar xzvf v${VERSION}.tar.gz \
    && cd overture-${VERSION}/main \
    && pwd \
    && go build -ldflags "-s -w" \
    && upx main \
    && mv main /usr/local/bin/overture


FROM alpine:3.9

LABEL maintainer="metowolf <i@i-meto.com>"

EXPOSE 53/udp

COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
COPY etc /etc/overture/

RUN apk add --no-cache ca-certificates

CMD ["overture", "-c", "/etc/overture/config.json"]
ENTRYPOINT ["docker-entrypoint.sh"]
