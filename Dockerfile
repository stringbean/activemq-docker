FROM eclipse-temurin:11

ARG ACTIVEMQ_VERSION=5.16.3

# download activemq & extract to /opt/apache-activemq-{version}
RUN curl -sL "https://www.apache.org/dyn/closer.cgi?filename=/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz&action=download" | tar -zx -C /opt
RUN ln -s /opt/apache-activemq-${ACTIVEMQ_VERSION} /opt/apache-activemq

RUN groupadd -r activemq && useradd -l -r -g activemq activemq

# create data dir
RUN mkdir -p /var/lib/data/activemq && chown -R activemq:activemq /var/lib/data/activemq
RUN mkdir -p /var/tmp/activemq && chown -R activemq:activemq /var/tmp/activemq

# update jetty config to listen on all interfaces
RUN sed -i.bak -e 's/127\.0\.0\.1/0.0.0.0/g' /opt/apache-activemq/conf/jetty.xml

USER activemq
COPY entrypoint /

# admin web interface
EXPOSE 8161
# openwire
EXPOSE 61616
# amqp
EXPOSE 5672
# stomp
EXPOSE 6163
# mqtt
EXPOSE 1883

VOLUME [ "/var/lib/data/activemq", "/var/tmp/activemq" ]

ENTRYPOINT [ "/entrypoint" ]
