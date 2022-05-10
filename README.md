# OpenShiftでVRspaceとOpenVidu 

オープンソースのメタバースアプリケーションである[vrspace](https://www.vrspace.org/)をOpenShiftへdeployします。
vrspaceの詳細は[こちら](https://redmine.vrspace.org/projects/vrspace-org/wiki)のRedmineをご参照ください。

## 1. LET's Encrypt

```
oc new-project letsencrypt
oc create -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml
oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme
```

## OpenVIDU

```
export OPENVIDU_USERNAME=<任意のアカウント名>
export OPENVIDU_SERVER_SECRET=<任意のパスワード>

oc new-project openvidu
oc create sa openvidu
oc adm policy add-scc-to-user anyuid -z openvidu 
gomplate -f manifest/openvidu/redis-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/coturn-deployment.yaml | envsubst | oc apply -f -
```


```
export TURNIP=`oc get svc coturn-udp -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
export MAILADDR=<your mail address>
export BASE_DOMAIN=<your base domain>
export STUN_LIST=`echo $TURNIP:3489 | base64`
export TURN_LIST=`echo ${OPENVIDU_USERNAME}:${OPENVIDU_SERVER_SECRET}@$TURNIP:3489 | base64`

gomplate -f manifest/openvidu/coturn-deployment.yaml | envsubst | oc apply -f -
```

```
gomplate -f manifest/openvidu/kms-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/loopback-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/openvidu-server-deployment.yaml | envsubst | oc apply -f -

gomplate -f manifest/openvidu/loopback-route.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/openvidu-server-route.yaml | envsubst | oc apply -f -
```

## VRSpace

```
export VRSPACE_SERVER_URL=<vrspaceのサーバURL>
oc new-project vrspace
oc create sa vrspace
oc adm policy add-scc-to-user privileged -z vrspace
cat manifest/vrspace/Dockerfile | oc new-build --dockerfile=- --to=vrspace
oc new-app vrspace:latest
oc set sa deployment/vrspace vrspace
```

```
cat manifest/vrspace/vrspace-route.yaml | envsubst | oc apply -f -
```

access to https://https://vrspace-vrspace.${BASE_DOMAIN}/avatar-selection.html
