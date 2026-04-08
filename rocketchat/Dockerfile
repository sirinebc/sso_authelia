FROM registry.rocket.chat/rocketchat/rocket.chat:latest

USER root
COPY certs/rootCA.pem /etc/ssl/certs/mkcert-rootCA.pem
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/mkcert-rootCA.pem
RUN update-ca-certificates
USER rocketchat