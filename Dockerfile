FROM postgres:9.6-alpine
MAINTAINER xingjiudong <xing.jiudong@trans-cosmos.com.cn>

RUN apk update && apk add dcron

ADD dump.sh /dump.sh
RUN chmod +x /dump.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump

ENTRYPOINT ["/start.sh"]
CMD [""]
