#!/bin/bash

# VCHOST=$(cat "/var/lib/vconnector/hosts.file" | grep -oP '^[^;]+')

EXITCODE=0
if [ ! -z ${VPOLLER_VC_HOST_01} ]; then
    vpoller-client -m about -V $VPOLLER_VC_HOST_01 | grep -c '"success": 0'
    if [ ! $? -eq 0 ]; then
        EXITCODE=1
    fi
fi
if [ ! -z ${VPOLLER_VC_HOST_02} ]; then
    vpoller-client -m about -V $VPOLLER_VC_HOST_02 | grep -c '"success": 0' 
    if [ ! $? -eq 0 ]; then
        EXITCODE=1
    fi   
fi
if [ ! -z ${VPOLLER_VC_HOST_03} ]; then
    vpoller-client -m about -V $VPOLLER_VC_HOST_03 | grep -c '"success": 0'   
    if [ ! $? -eq 0 ]; then
        EXITCODE=1
    fi 
fi
return $EXITCODE