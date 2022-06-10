ARG RUNTIME_BASE_IMAGE=gcr.io/distroless/cc-debian11
ARG MASSA_VERSION=TEST.11.1

FROM alpine:3.15 as massa-binaries

LABEL maintainer="Florian Lopes <florian.lopes@outlook.com>"

ARG MASSA_VERSION
ARG MASSA_RELEASE_BINARY=massa_${MASSA_VERSION}_release_linux.tar.gz
ARG MASSA_RELEASE_URL="https://github.com/massalabs/massa/releases/download/${MASSA_VERSION}/${MASSA_RELEASE_BINARY}"

ENV MASSA_VERSION=${MASSA_VERSION} \
    MASSA_HOME="/massa"
ENV MASSA_NODE_HOME="${MASSA_HOME}/massa-node" \
    MASSA_CLIENT_HOME="${MASSA_HOME}/massa-client"

RUN mkdir ${MASSA_HOME} && \
    wget -q ${MASSA_RELEASE_URL} && \
    tar -xvf ${MASSA_RELEASE_BINARY} -C ${MASSA_HOME} --strip-components 1 && \
    rm -rf ${MASSA_RELEASE_BINARY} && \
    chmod +x ${MASSA_NODE_HOME}/massa-node ${MASSA_CLIENT_HOME}/massa-client

FROM ${RUNTIME_BASE_IMAGE} as massa-node

LABEL maintainer="Florian Lopes <florian.lopes@outlook.com>"

ARG MASSA_VERSION

ENV MASSA_NODE_HOME="/massa-node"
ENV MASSA_VERSION=${MASSA_VERSION}

COPY --chown=1000:1000 --from=massa-binaries /massa/massa-node ${MASSA_NODE_HOME}

USER 1000

WORKDIR ${MASSA_NODE_HOME}

VOLUME ${MASSA_NODE_HOME}/config

EXPOSE 31244 31245

ENTRYPOINT ["/massa-node/massa-node"]

FROM ${RUNTIME_BASE_IMAGE} as massa-client

LABEL maintainer="Florian Lopes <florian.lopes@outlook.com>"

ARG MASSA_VERSION

ENV MASSA_CLIENT_HOME="/massa-client"
ENV MASSA_VERSION=${MASSA_VERSION}

COPY --chown=1000:1000 --from=massa-binaries /massa/massa-client ${MASSA_CLIENT_HOME}

USER 1000

WORKDIR ${MASSA_CLIENT_HOME}

VOLUME ${MASSA_CLIENT_HOME}/config

ENTRYPOINT ["/massa-client/massa-client"]
