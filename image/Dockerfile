FROM debian

RUN echo 1.0>/imageversion

RUN apt-get update && apt-get install -y openssh-client ansible git curl dnsutils

COPY ./scripts /homelab_scripts

RUN chmod +x /homelab_scripts/run && chmod +x /homelab_scripts/setup

RUN /homelab_scripts/setup

WORKDIR /

CMD [ "/homelab_scripts/run" ]
