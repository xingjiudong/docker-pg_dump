FROM postgres:9.6-alpine
MAINTAINER xingjiudong <xing.jiudong@trans-cosmos.com.cn>

ENV CONFD_VERSION 0.11.0 

RUN set -x && apk add --update --no-cache dcron 
RUN wget https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 \
    && chmod +x confd-${CONFD_VERSION}-linux-amd64 \
    && mv confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd

ADD confd /etc/confd

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump

ENTRYPOINT ["/start.sh"]
CMD [""]
