#FROM python:2.7.17-alpine3.10
FROM frolvlad/alpine-glibc:alpine-3.12

ENV ANSIBLE_VERSION=2.8.5

RUN echo "=== INSTALLING SYS DEPS" && \
    apk update && \
    apk add --no-cache \
        git \
        openssh-client \
        openssl \
        rsync \
        sshpass \
        which \
        ca-certificates \
        py-pip \
        python3-dev \
        gettext && \
    apk --update add --virtual \
        builddeps \
        libffi-dev \
        openssl-dev \
        build-base && \
    \
    echo "=== INSTALLING PIP DEPS" && \
    pip install --upgrade \
        pip \
        cffi && \
    pip install \
        ansible==$ANSIBLE_VERSION \
        botocore \
        boto \
        openshift \
        glibc \
        boto3 && \
    \
    echo "=== Cleanup this mess ===" \
    apk upgrade && \
    apk del builddeps && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /etc/ansible \
 && echo 'localhost' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

RUN wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz -O /tmp/oc.tar.gz && \
    cd /tmp && tar -zxvf oc.tar.gz && \
    chmod +x /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit/oc && \
    mv /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin && rm -rf /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit /tmp/oc.tar.gz
