FROM registry.rocket.chat/rocketchat/rocket.chat:latest

USER root
COPY certs/rootCA.pem /usr/local/share/ca-certificates/rootCA.crt
RUN update-ca-certificates || true
USER rocketchat
