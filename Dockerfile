FROM debian:stable-slim

ARG HUGO_VERSION

ENV BASE_URL="https://github.com/gohugoio/hugo/releases/download"
ENV TAR_FILE="hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz"

ADD ${BASE_URL}/v${HUGO_VERSION}/${TAR_FILE} /tmp/

RUN tar -zxvf /tmp/${TAR_FILE} && \
    mv hugo /usr/bin/hugo && \
    chmod +x /usr/bin/hugo && \
    rm -f /tmp/${TAR_FILE} && \
    useradd hugo

COPY Dockerfile /

WORKDIR /build

USER hugo

ENTRYPOINT ["hugo"]
CMD ["--help"]