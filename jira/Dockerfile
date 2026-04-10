FROM atlassian/jira-software:9.12

USER root

COPY certs/rootCA.pem /usr/local/share/ca-certificates/rootCA.crt

RUN update-ca-certificates \
    && (keytool -importcert -noprompt -trustcacerts \
        -alias local-rootca \
        -file /usr/local/share/ca-certificates/rootCA.crt \
        -keystore /etc/ssl/certs/java/cacerts \
        -storepass changeit \
        || keytool -importcert -noprompt -trustcacerts \
        -alias local-rootca \
        -file /usr/local/share/ca-certificates/rootCA.crt \
        -keystore "${JAVA_HOME}/lib/security/cacerts" \
        -storepass changeit) \
    || true

USER jira
