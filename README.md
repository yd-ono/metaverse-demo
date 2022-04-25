# vr-webrtc-demo
```
az network public-ip create --resource-group $RESOURCEGROUP --name turnpublic --sku Standard --ip-tags Internet  --allocation-method static
```

## 環境変数を設定
```
export TURNIP=<Public IP>
export MAILADDR=yono@redhat.com
export BASE_DOMAIN=apps.ngmxtmgq.eastus.aroapp.io
export STUN_LIST=`echo $TURNIP:3489 | base64`
export TURN_LIST=`echo myopenvidu:vrtest123@$TURNIP:3489 | base64` 
```

## LET's Encrypt

```
oc new-project letsencrypt
oc create -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml
oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme
```

## MetalLB

```
oc new-project metallb-system
oc apply -f manifest/metallb/metallb-subscription.yaml
cat address-pool.yaml | envsubst | oc apply -f -
oc apply -f metallb.yaml
```

## VRSpace

```
oc new-project vrspace
oc create sa vrspace
oc adm policy add-scc-to-user anyuid -z vrspace
cat Dockerfile | oc new-build --dockerfile=- --to=vrspace
oc apply -f manifest/vrspace/vrspace-deployment.yaml
oc apply -f manifest/vrspace/vrspace-route.yaml

# OpenVIDU

```
oc new-project openvidu
oc crete sa openvidu
oc adm policy add-scc-to-user anyuid -z openvidu 
gomplate -f manifest/openvidu/redis-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/coturn-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/kms-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/loopback-secrets.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/loopback-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/loopback-route.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/openvidu-server-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/openvidu-server-route.yaml | envsubst | oc apply -f -
```
