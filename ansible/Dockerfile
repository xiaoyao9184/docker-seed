ARG ANSIBLE_VERSION=2.9.27

FROM alpine:3.16

ARG ANSIBLE_VERSION=2.9.27
ARG SEED_VERSION=dev

RUN apk add --update --no-cache sudo bash py-pip openssl docker-cli docker-compose

RUN pip install --upgrade pip docker jsondiff pyyaml
RUN pip install ansible==${ANSIBLE_VERSION}
RUN mkdir -p /etc/ansible \
    && echo 'localhost' > /etc/ansible/hosts

RUN ansible-galaxy collection install community.docker

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-deploy.sh /docker-deploy.sh
COPY playbook.yml /playbook.yml

WORKDIR /workspace

USER root

ENV SEED_ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV SEED_MAIN_VERSION=${SEED_VERSION}

ENTRYPOINT bash /docker-entrypoint.sh

VOLUME /workspace