FROM debian

RUN apt-get update && apt-get install -y openssh-client ansible git curl dnsutils python3-pip sshpass rsync

RUN ansible-galaxy collection install gluster.gluster

COPY ./ansible /ansible
COPY ./scripts /scripts

RUN chmod +x /scripts/*

RUN curl -sLS https://get.hashi-up.dev | sh

WORKDIR /

CMD [ "/scripts/help" ]
