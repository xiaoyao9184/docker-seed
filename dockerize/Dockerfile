ARG DOCKERIZE_VERSION=0.16.0

FROM powerman/dockerize:${DOCKERIZE_VERSION}

ARG DOCKERIZE_VERSION=0.16.0
ARG SEED_VERSION=dev

RUN apk add --no-cache bash docker-cli

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-deploy.sh /docker-deploy.sh

WORKDIR /workspace

USER root

ENV SEED_DOCKERIZE_VERSION=${DOCKERIZE_VERSION}
ENV SEED_MAIN_VERSION=${SEED_VERSION}

ENTRYPOINT bash /docker-entrypoint.sh

VOLUME /workspace