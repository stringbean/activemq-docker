#################### BUILDER IMAGE ####################
FROM eclipse-temurin:17-alpine AS builder

ARG ACTIVEMQ_VERSION=5.16.3

ENV ACTIVEMQ_HOME="/opt/apache-activemq-$ACTIVEMQ_VERSION"

RUN apk update && apk add curl binutils

# download activemq & extract to /opt/apache-activemq-{version}
RUN curl -sL "https://www.apache.org/dyn/closer.cgi?filename=/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz&action=download" | tar -zx -C /opt

# build minimal JRE
RUN jlink --no-header-files \
  --no-man-pages \
  --compress=2 \
  --strip-debug \
  --vm server \
  --add-modules $(jdeps -q --print-module-deps --ignore-missing-deps $ACTIVEMQ_HOME/activemq-all-$ACTIVEMQ_VERSION.jar) \
  --output /opt/java/openjdk-17-jlink

# remove uncesary parts of the distributution
RUN rm -rf $ACTIVEMQ_HOME/activemq-all-$ACTIVEMQ_VERSION.jar \
  $ACTIVEMQ_HOME/docs \
  $ACTIVEMQ_HOME/examples \
  $ACTIVEMQ_HOME/webapps-demo

#################### MAIN IMAGE ####################

FROM alpine

ARG ACTIVEMQ_VERSION=5.16.3

# copy extracted activemq from builder
COPY --from=builder /opt/apache-activemq-$ACTIVEMQ_VERSION  /opt/apache-activemq-$ACTIVEMQ_VERSION
RUN ln -s /opt/apache-activemq-${ACTIVEMQ_VERSION} /opt/apache-activemq

# copy JRE from builder
COPY --from=builder /opt/java/openjdk-17-jlink /opt/java/openjdk-17-jlink

RUN addgroup -S activemq && adduser -G activemq -S -H activemq

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

ENV PATH="/opt/java/openjdk-17-jlink:$PATH"
ENV JAVA_HOME=/opt/java/openjdk-17-jlink

ENTRYPOINT [ "/entrypoint" ]