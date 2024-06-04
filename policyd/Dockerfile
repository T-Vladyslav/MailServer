FROM ubuntu:jammy

RUN \ 
    apt-get update -y && \ 
    apt-get upgrade -y && \ 
    apt-get install perl -y && \
    apt-get install cpanminus -y && \ 
    apt-get install libdbi-perl -y && \
    apt-get install libdbd-mysql-perl -y && \
    apt-get install build-essential -y && \  
    apt-get install gettext-base -y && \
    apt-get install netcat -y && \
    apt-get clean -y

# ENV POLICYD_DB_SERVER=127.0.0.1
# ENV POLICYD_DB_NAME=policyd
# ENV POLICYD_DB_USER=policyd
# ENV POLICYD_DB_PASS=$POLICYD_DB_PASS

ADD pkg/cluebringer-v2.0.14.tar.gz /
COPY conf/cluebringer.conf /etc/cluebringer.conf.template

COPY src/perl_modules.txt /perl_modules.txt
RUN cpanm < perl_modules.txt

COPY src/entrypoin.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY pkg/wait-for /wait-for
RUN chmod +x /wait-for

EXPOSE 10031

CMD ["/entrypoint.sh"]