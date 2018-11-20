FROM alpine

ARG PROJECT=
ARG VERSION=
ARG GIT_SHA=

LABEL PROJECT="${PROJECT}"

ARG KEEPALIVED_VERSION=2.0.10

ARG KEEPALIVED_URL=\
http://www.keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz

RUN apk upgrade --no-cache --update && \
    apk add --no-cache \
        ipset \
        libnl3 \
        openssl \
        iptables \
        libnfnetlink && \
    apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        musl-dev \
        ipset-dev \
        libnl3-dev \
        openssl-dev \
        iptables-dev \
        libnfnetlink-dev && \
    wget -O- "${KEEPALIVED_URL}" | tar -xz && \
    cd "keepalived-${KEEPALIVED_VERSION}" && \
    ./configure && \
    make -j4 && \
    make install && \
    cd ../ && \
    rm -rf "keepalived-${KEEPALIVED_VERSION}" && \
    apk del .build-deps && \
    echo "${VERSION} (git-${GIT_SHA})" > /version

ENTRYPOINT ["keepalived"]
