#!/bin/bash
set +e

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

# Type of vPoller component
# Possible values: [aio]
vpoller_type=$1

# Default proxy frontend port
VPOLLER_PROXY_FRONTEND_PORT=${VPOLLER_PROXY_FRONTEND_PORT:-"10123"}

# Default proxy backend port
VPOLLER_PROXY_BACKEND_PORT=${VPOLLER_PROXY_BACKEND_PORT:-"10124"}

# Default proxy management port
VPOLLER_PROXY_MGMT_PORT=${VPOLLER_PROXY_MGMT_PORT:-"9999"}

# Default worker management port
VPOLLER_WORKER_MGMT_PORT=${VPOLLER_WORKER_MGMT_PORT:-"10000"}

# Default worker helpers
VPOLLER_WORKER_HELPERS=${VPOLLER_WORKER_HELPERS:-"vpoller.helpers.zabbix, vpoller.helpers.czabbix"}

# Default worker helpers
VPOLLER_WORKER_TASKS=${VPOLLER_WORKER_TASKS:-"vpoller.vsphere.tasks"}

# Default worker proxy hostname
VPOLLER_WORKER_PROXYHOSTNAME=${VPOLLER_WORKER_PROXYHOSTNAME:-"localhost"}

# Default cache enabled
VPOLLER_CACHE_ENABLED=${VPOLLER_CACHE_ENABLED:-"True"}

# Default cache maxsize
VPOLLER_CACHE_MAXSIZE=${VPOLLER_CACHE_MAXSIZE:-"0"}

# Default cache ttl
VPOLLER_CACHE_TTL=${VPOLLER_CACHE_TTL:-"3600"}

# Default cache housekeeping time
VPOLLER_CACHE_HOUSEKEEPING=${VPOLLER_CACHE_HOUSEKEEPING:-"480"}

# Default worker concurrency
VPOLLER_WORKER_CONCURRENCY=${VPOLLER_WORKER_CONCURRENCY:-"4"}

DEFAULT_CONFIG=$(cat <<-END
[proxy]
frontend     = tcp://*:${VPOLLER_PROXY_FRONTEND_PORT}
backend      = tcp://*:${VPOLLER_PROXY_BACKEND_PORT}
mgmt         = tcp://*:${VPOLLER_PROXY_MGMT_PORT}

[worker]
db           = /var/lib/vconnector/vconnector.db
proxy        = tcp://${VPOLLER_WORKER_PROXYHOSTNAME}:${VPOLLER_PROXY_BACKEND_PORT}
mgmt         = tcp://*:${VPOLLER_WORKER_MGMT_PORT}
helpers      = ${VPOLLER_WORKER_HELPERS}
tasks        = ${VPOLLER_WORKER_TASKS}

[cache]
enabled      = ${VPOLLER_CACHE_ENABLED}
maxsize      = ${VPOLLER_CACHE_MAXSIZE}
ttl          = ${VPOLLER_CACHE_TTL}
housekeeping = ${VPOLLER_CACHE_HOUSEKEEPING}
END
)

##################################################

echo "########################################################"

if [ ! -n "$vpoller_type" ]; then
    echo "**** Type of vPoller component is not specified"
    exit 1
elif [ "$vpoller_type" == "aio" ]; then
    echo "************* Config for vPoller All-in-One *************"
    echo "$DEFAULT_CONFIG" > /etc/vpoller/vpoller.conf
    cat /etc/vpoller/vpoller.conf
else
    echo "*** No known vPoller component type was specified"
fi

if [ ! -d /var/lib/vconnector ]; then
    mkdir /var/lib/vconnector
fi

if [ ! -f /var/lib/vconnector/vconnector.db ]; then
    echo "*** no db file found - initiating one"
    vconnector-cli --debug init
else
    echo "*** found db file, re-initiating"
    rm -f /var/lib/vconnector/vconnector.db
    vconnector-cli --debug init
fi

if [ ! -f /var/lib/vconnector/hosts.file ]; then
    echo "*** no hosts file found"
else
    echo "*** found hosts file - importing"
    /import-hostsfile.sh
fi

if [ ! -z ${VPOLLER_VC_HOST_01} ]; then
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_01} -U ${VPOLLER_VC_USERNAME_01} -P ${VPOLLER_VC_PASSWORD_01} add
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_01} enable
fi
if [ ! -z ${VPOLLER_VC_HOST_02} ]; then
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_02} -U ${VPOLLER_VC_USERNAME_02} -P ${VPOLLER_VC_PASSWORD_02} add
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_02} enable
fi
if [ ! -z ${VPOLLER_VC_HOST_03} ]; then
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_03} -U ${VPOLLER_VC_USERNAME_03} -P ${VPOLLER_VC_PASSWORD_03} add
    vconnector-cli --debug -H ${VPOLLER_VC_HOST_03} enable
fi
vconnector-cli --debug get

echo "########################################################"

echo "** Executing supervisord"
exec supervisord -c /etc/supervisor/supervisord.conf
