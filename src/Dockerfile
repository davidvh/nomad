FROM debian

RUN apt-get update && apt-get install -y openssh-client ansible git curl dnsutils python3-pip sshpass rsync
RUN ansible-galaxy collection install community.general
RUN curl -sLS https://get.hashi-up.dev | sh

RUN hashi-up nomad get --dest /usr/local/bin/

COPY ./ansible /ansible
COPY ./scripts /scripts
COPY ./nomad /nomad

RUN apt-get install dos2unix -y
RUN find /scripts /ansible -type f -print0 | xargs -0 dos2unix
RUN chmod +x /scripts/*

WORKDIR /

CMD [ "/scripts/help" ]
