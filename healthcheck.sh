#!/bin/bash

# VCHOST=$(cat "/var/lib/vconnector/hosts.file" | grep -oP '^[^;]+')
vpoller-client -m about -V $VPOLLER_VC_HOST | grep -c '"success": 0'
