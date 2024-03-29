ARG ANSIBLE_VERSION=6.2.0

FROM alpine:3.16

ARG ANSIBLE_VERSION=6.2.0
ARG SEED_VERSION=dev

RUN apk add --update --no-cache \
    sudo bash \
    py-pip openssh openssl rsync git \
    docker-cli docker-compose

# jmespath for json_query filter
# jsondiff pyyaml for community.docker
# lxml for community.general
# psycopg2 for community.postgresql
RUN pip install --upgrade pip docker \
    docker-compose \
    jmespath \
    jsondiff pyyaml \
    lxml \
    psycopg2-binary
RUN pip install ansible==${ANSIBLE_VERSION}
RUN mkdir -p /etc/ansible \
    && echo 'localhost' > /etc/ansible/hosts

RUN ansible-galaxy collection install community.docker \
    && ansible-galaxy collection install community.general \
    && ansible-galaxy role install gekmihesg.openwrt \
    && ansible-galaxy collection install imp1sh.ansible_openwrt

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-deploy.sh /docker-deploy.sh
COPY playbook.yml /playbook.yml

WORKDIR /workspace

USER root

ENV SEED_ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV SEED_MAIN_VERSION=${SEED_VERSION}

ENTRYPOINT bash /docker-entrypoint.sh

VOLUME /workspace