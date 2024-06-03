FROM ubuntu:jammy

RUN \ 
    apt-get update -y && \ 
    apt-get upgrade -y && \ 
    apt-get install opendkim opendkim-tools -y && \
    apt-get install libopendbx1-mysql libopendbx1 -y && \
    apt-get install rsyslog -y && \
    apt-get install supervisor -y && \
    apt-get install gettext-base -y && \ 
    apt-get clean -y

# ENV OPENDKIM_DB_SERVER=127.0.0.1
# ENV OPENDKIM_DB_NAME=opendkim
# ENV OPENDKIM_DB_USER=opendkim
# ENV OPENDKIM_DB_PASS= password
# ENV TZ {$TZ:-UTC}

COPY conf/opendkim.conf /etc/opendkim.conf.template
# RUN chmod +w /etc/opendkim.conf

# Supervisor
COPY conf/supervisord.conf /etc/supervisor.conf
COPY supervisor/ /etc/supervisor/
RUN chmod +x /etc/supervisor/*.sh

COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8891

CMD ["/entrypoint.sh"]