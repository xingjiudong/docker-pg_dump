#!/bin/bash
source ./env.config

#sed -r "s/@PROJECT_NAME@/${PROJECT_NAME}/g" /etc/confd/templates/haproxy.cfg.tmpl.in > /etc/confd/templates/haproxy.cfg.tmpl 

confd -onetime -backend etcd -node http://${ETCD_CLIENT_IP}:2379 --prefix="${PROJECT_NAME}"
