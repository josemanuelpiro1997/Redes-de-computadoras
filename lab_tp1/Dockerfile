from ubuntu

WORKDIR /home/work

RUN apt-get update

COPY ./config.sh .

ENTRYPOINT ["./config.sh"]