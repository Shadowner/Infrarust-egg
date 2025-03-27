FROM debian:12-slim

RUN adduser --disabled-password --home /home/container container

USER container
ENV USER=container HOME=/home/container

COPY infrarust /bin/infrarust

WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
