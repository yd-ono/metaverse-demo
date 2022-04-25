# vr-webrtc-demo
# VRSpace
oc create sa vrspace
cat Dockerfile | oc new-build --dockerfile=- --to=vrspace
oc new-app vrspace:latest

## root権限付与(商用環境にはお薦めできません...)
oc adm policy add-scc-to-user anyuid -z vrspace
oc set sa deployment/vrspace vrspace

# OpenVIDU
oc new-app -e CERTIFICATE_TYPE=letsencrypt -e HTTPS_PORT=443 -e OPENVIDU_SECRET=vrtest123 -e DOMAIN_OR_PUBLIC_IP=openvidu-openvidu.apps.p27eai7o.eastus.aroapp.io openvidu/openvidu-server-kms:2.17.0

oc create sa openvidu
oc adm policy add-scc-to-user myanyuid -z openvidu 
oc set sa deployment/openvidu-server openvidu 
oc set sa statefulset/kurento openvidu 

## HTTPS対応が必要
$ oc create -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml


$ oc get pods
NAME                              READY   STATUS    RESTARTS   AGE
openshift-acme-54496d7cc7-6lhzm   1/1     Running   0          21h
openshift-acme-54496d7cc7-pmf9v   1/1     Running   0          21h

$ oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme
kubernetes.io/tls-acme: "true"
