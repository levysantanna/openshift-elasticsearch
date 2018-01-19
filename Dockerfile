FROM rhel7:latest

EXPOSE 9200 9300

ENV INSTALLDIR /opt/elasticsearch
ENV ELASTIC_HOME $INSTALLDIR
ENV ES_HOME $INSTALLDIR
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${INSTALLDIR}/bin 

# ENV ES_HEAP_SIZE 8g 

USER 0

RUN yum install -y tar java-1.8.0-openjdk-headless net-tools telnet; yum clean all; rm -rf /var/cache/yum

RUN mkdir -p ${INSTALLDIR} && mkdir -p ${INSTALLDIR}/logs/ && \
    curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${VERSION}.tar.gz | tar xzf - -C /opt && \
    ln -s ${INSTALLDIR}-${ES_VERSION} ${INSTALLDIR} &&\
    chmod +x ${INSTALLDIR}/bin/elasticsearch 

RUN useradd elastic && \
    chown -R elastic ${INSTALLDIR}

USER elastic

# COPY configurations files
ONBUILD COPY config/ ${INSTALLDIR}/config/

# COPY plugins and install all
ONBUILD COPY plugins/* ${INSTALLDIR}/plugins/
ONBUILD COPY install-plugins.sh ${INSTALLDIR}/bin/
ONBUILD RUN ${INSTALLDIR}/bin/install-plugins.sh

# Start Elasticsearch
CMD ["elasticsearch"] 
