FROM jenkins/jenkins

# ajout du plugins casc (config as code) et oic-auth
COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# ajout du certificat root du proxy au keystore de la JVM
USER root
COPY certs/rootCA.pem /tmp/rootCA.pem
RUN keytool -importcert \
    -alias authelia-ca \
    -file /tmp/rootCA.pem \
    -cacerts \
    -storepass changeit \
    -noprompt \
  && rm /tmp/rootCA.pem
USER jenkins