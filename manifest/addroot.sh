#!/bin/bash

if [ $1 == 'all' ];
then

oc set sa deployment/redis openvidu
oc set sa deployment/app openvidu
oc set sa deployment/coturn openvidu
oc set sa deployment/kurento openvidu
oc set sa deployment/openvidu-server openvidu
else

oc set sa deployment/$1 openvidu

fi
