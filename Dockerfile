FROM debian:stable-slim as download

ARG HUGO_VERSION

ENV BASE_URL="https://github.com/gohugoio/hugo/releases/download"
ENV TAR_FILE="hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz"

ADD ${BASE_URL}/v${HUGO_VERSION}/${TAR_FILE} /tmp/

RUN tar -zxvf /tmp/${TAR_FILE} && \
    mv hugo /usr/bin/hugo && \
    chmod +x /usr/bin/hugo


FROM debian:stable-slim

COPY --from=download /usr/bin/hugo /usr/bin/hugo

COPY Dockerfile /

RUN useradd hugo

WORKDIR /build

USER hugo

ENTRYPOINT ["hugo"]
CMD ["--help"]