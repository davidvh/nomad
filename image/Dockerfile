FROM debian

RUN echo 1.0>/imageversion

RUN apt-get update && apt-get install openssh-client ansible git

COPY ./scripts /homelab_scripts

RUN chmod +x /homelab_scripts/run

WORKDIR /

CMD [ "/homelab_scripts/run" ]
