FROM atlassian/confluence:latest

USER root
COPY certs/rootCA.pem /tmp/rootCA.pem
RUN keytool -importcert \
    -alias authelia-ca \
    -file /tmp/rootCA.pem \
    -cacerts \
    -storepass changeit \
    -noprompt \
    && rm /tmp/rootCA.pem
USER confluence
