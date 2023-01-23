ARG ubuntu_vrersion="22.04"

FROM ubuntu:$ubuntu_vrersion AS main

WORKDIR /tmp

RUN set -eux; \
    apt update && apt upgrade; \
    apt install curl zip -y

RUN set -eux; \
    apt-get update && apt-get upgrade; \
    curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list; \
    apt-get update && apt-get install kubectl -y


FROM main AS arm

RUN set -eux; \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    unzip awscliv2.zip; \
    ./aws/install


FROM main AS x86

RUN set -eux; \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    unzip awscliv2.zip; \
    ./aws/install


FROM arm AS arm_release

COPY ./src/auth-rotator.sh /bin/auth-rotator
RUN chmod +x /bin/auth-rotator

FROM x86 AS x86_release

COPY ./src/auth-rotator.sh /bin/auth-rotator
RUN chmod +x /bin/auth-rotator

ENTRYPOINT [ "auth-rotator" ]