#!/bin/bash

do_clone() {
    release_name=${1##*/}
    git submodule add $1
    ( 
        cd $release_name && \
        git checkout $2 && \
        git submodule init && \
        git submodule sync && \
        git submodule update
    )
}

do_clone https://github.com/cloudfoundry-incubator/consul-release v191
do_clone https://github.com/cloudfoundry/nats-release v22
do_clone https://github.com/cloudfoundry/uaa-release v55
do_clone https://github.com/cloudfoundry/statsd-injector-release v1.2.0
do_clone https://github.com/cloudfoundry-incubator/cf-routing-release v0.172.0
do_clone https://github.com/cloudfoundry/capi-release v1.49.0
do_clone https://github.com/cloudfoundry/diego-release v1.35.0
do_clone https://github.com/cloudfoundry/garden-runc-release v1.11.1
do_clone https://github.com/cloudfoundry/cflinuxfs2-release v1.187.0
do_clone https://github.com/cloudfoundry/loggregator-release v101.6
do_clone https://github.com/cloudfoundry/cf-syslog-drain-release v5.1
do_clone https://github.com/cloudfoundry/binary-buildpack-release v1.0.16
do_clone https://github.com/cloudfoundry/go-buildpack-release v1.8.18
do_clone https://github.com/cloudfoundry/java-buildpack-release v4.8
do_clone https://github.com/cloudfoundry/nodejs-buildpack-release v1.6.16
do_clone https://github.com/cloudfoundry/php-buildpack-release v4.3.48
do_clone https://github.com/cloudfoundry/python-buildpack-release v1.6.8
do_clone https://github.com/cloudfoundry/ruby-buildpack-release v1.7.11
do_clone https://github.com/cloudfoundry/staticfile-buildpack-release v1.4.21
do_clone https://github.com/cloudfoundry-community/logsearch-boshrelease v205.0.1


do_clone https://github.com/alphagov/paas-haproxy-release master
do_clone https://github.com/alphagov/paas-datadog-for-cloudfoundry-boshrelease master
do_clone https://github.com/alphagov/paas-ipsec-release master

