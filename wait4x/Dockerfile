ARG WAIT4X_VERSION=2.5.0

FROM atkrad/wait4x:${WAIT4X_VERSION}

ARG WAIT4X_VERSION=2.5.0
ARG SEED_VERSION=dev

RUN apk add --no-cache bash docker-cli

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-deploy.sh /docker-deploy.sh

WORKDIR /workspace

USER root

ENV SEED_WAIT4X_VERSION=${WAIT4X_VERSION}
ENV SEED_MAIN_VERSION=${SEED_VERSION}

ENTRYPOINT bash /docker-entrypoint.sh

VOLUME /workspace