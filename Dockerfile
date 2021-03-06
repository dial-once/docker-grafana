FROM alpine:edge
MAINTAINER Jonathan Muller <jmuller@dial-once.com>

ENV GRAFANA_VERSION 3.0.0-beta71462173753

#add glibc to docker container
RUN apk --no-cache --virtual libc-deps add wget ca-certificates && \
    wget -q -O /etc/apk/keys/andyshinn.rsa.pub https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/andyshinn.rsa.pub && \
    wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-2.23-r1.apk && \
    apk add glibc-2.23-r1.apk && \
    rm glibc-2.23-r1.apk && \
    apk del libc-deps

#python + pip for envtpl
RUN apk --no-cache add python curl && \
    apk --virtual envtpl-deps add --update py-pip python-dev curl && \
    curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python - --version=20.9.0 && \
    pip install envtpl && \
    apk del envtpl-deps

#grafana
RUN apk --virtual build-deps add wget ca-certificates && \
    update-ca-certificates && \
    wget https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VERSION}.linux-x64.tar.gz && \
    tar -xzf grafana-${GRAFANA_VERSION}.linux-x64.tar.gz && \
    cd grafana-${GRAFANA_VERSION} && \
    mv ./bin/grafana-server /bin/ && \
    chmod 777 /bin/grafana-server && \
    mkdir -p /etc/grafana /var/lib/grafana/plugins /var/log/grafana /usr/share/grafana && \
    mv ./public /usr/share/grafana/public && \
    mv ./conf /usr/share/grafana/conf && \
    cd .. && \
    rm -rf grafana-${GRAFANA_VERSION} && \
    apk del build-deps

VOLUME ["/var/lib/grafana", "/var/lib/grafana/plugins", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

ENV INFLUXDB_HOST localhost
ENV INFLUXDB_PORT 8086
ENV INFLUXDB_PROTO http
ENV INFLUXDB_USER grafana
ENV INFLUXDB_PASS changeme
ENV GRAFANA_USER admin
ENV GRAFANA_PASS changeme

COPY ./grafana.ini /usr/share/grafana/conf/defaults.ini.tpl
COPY ./config-influxdb.js /etc/grafana/config-influxdb.js.tpl
COPY ./config-elasticsearch.js /etc/grafana/config-elasticsearch.js.tpl
COPY ./run.sh /run.sh

CMD ["/run.sh"]
