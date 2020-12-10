FROM centos:7

ARG YUM_FLAGS_COMMON="-y"
ARG YUM_FLAGS_PERSISTENT="${YUM_FLAGS_COMMON}"

RUN set -eux && \	
    yum ${YUM_FLAGS_PERSISTENT} install epel-release && \
    yum ${YUM_FLAGS_PERSISTENT} install zeromq python3-pip && \
    yum ${YUM_FLAGS_PERSISTENT} clean all && \
    rm -rf /var/cache/yum/ && \
    pip3 install vpoller supervisor

EXPOSE 10123/TCP
EXPOSE 10124/TCP
EXPOSE 9999/TCP
EXPOSE 10000/TCP

# VOLUME ["/var/lib/vconnector"]

WORKDIR /etc/vpoller/
ADD supervisor /etc/supervisor/
ADD *.sh /
RUN chmod 0766 /*.sh


ENTRYPOINT ["/run_vpoller_component.sh"]
CMD ["aio"]