# OpenShiftでVRspaceとOpenVidu 

オープンソースのメタバースアプリケーションである[vrspace](https://www.vrspace.org/)をOpenShiftへdeployします。
vrspaceの詳細は[こちら](https://redmine.vrspace.org/projects/vrspace-org/wiki)のRedmineをご参照ください。

## 環境
- OpenShift v4.8以降(4.8以前はテストしてません)
- AWSまたはAzure

## 1. LET's Encrypt

```
oc new-project letsencrypt
oc create -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml
oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme
```

## OpenVIDU
ビデオ会議や音声チャットなどを有効にするためにはOpenVIDUの構築が必要です。
まず、以下の環境変数をセットします。

```
export OPENVIDU_USERNAME=<任意のアカウント名>
export OPENVIDU_SERVER_SECRET=<任意のパスワード>
```

```
oc new-project openvidu
oc create sa openvidu
oc adm policy add-scc-to-user anyuid -z openvidu 
```

```
gomplate -f manifest/openvidu/redis-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/coturn-deployment.yaml | envsubst | oc apply -f -
```

DNSレコードが更新されるまで1分ほど待ちます。
続いて以下の環境変数をセットします。

```
export TURN_DOMAIN=`oc get svc coturn -o jsonpath='{.status.loadBalancer.ingress[*].hostname}'`
export TURNIP=`dig $TURN_DOMAIN | grep -v ";" | grep $TURN_DOMAIN  | awk '{print $5}'`
export MAILADDR=<your mail address>
export BASE_DOMAIN=<your base domain>
export STUN_LIST=`echo $TURNIP:3489 | base64`
export TURN_LIST=`echo ${OPENVIDU_USERNAME}:${OPENVIDU_SERVER_SECRET}@$TURNIP:3489 | base64`
```

coturnの`--external-ip`オプションをServiceのExternal IPで更新します。

```
gomplate -f manifest/openvidu/coturn-deployment.yaml | envsubst | oc apply -f -
```

残りのアプリケーションもdeployします。

```
gomplate -f manifest/openvidu/kms-deployment.yaml | envsubst | oc apply -f -
gomplate -f manifest/openvidu/openvidu-server-deployment.yaml | envsubst | oc apply -f -
```

Routeを作成します。

```
gomplate -f manifest/openvidu/openvidu-server-route.yaml | envsubst | oc apply -f -
```


```
export OPENVIDU_SERVER_URL=`oc get route openvidu-server -o jsonpath='{.status.ingress[*].host}'`
```

https://${OPENVIDU_SERVER_URL}へアクセスし、TURNサーバ経由でビデオ配信ができることを確認してください。


## VRSpace

[GitHub](https://github.com/jalmasi/vrspace)をforkしたhttps://github.com/yd-ono/vrspaceベースにDockerでコンテナイメージを作成します。
オリジナルのコードはlocalhostで実行する前提になっており、以下のopenvidu-serverとvrspaceのサーバURLを修正しています。

- vrspace/babylon/video-test.js
  - OPENVIDU_SERVER_URLとOPENVIDU_SERVER_SECRETを修正

- vrspace/babylon/sound-test.js
  - OPENVIDU_SERVER_URLとOPENVIDU_SERVER_SECRETを修正

- vrspace/server/src/main/resources/application.propertiesの
  - `openvidu.publicurl`
  - `openvidu.secret`
  - `sketchfab.redirectUri`
  - `spring.security.oauth2.client.registration.facebook.redirect-uri`
  - `spring.security.oauth2.client.registration.google.redirect-uri`を修正

自分のGitHubへforkした場合は以下の環境変数を変更してください。
```
export VRSPACE_GIT_URL=<forkしたリポジトリのURL>
```

forkしていない場合は、以下の通り環境変数を設定してください。

```
export VRSPACE_GIT_URL=https://github.com/yd-ono/vrspace
```

続いて、以下の環境変数を設定します。

```
export VRSPACE_SERVER_URL=vrspace.${BASE_DOMAIN}
```

```
oc new-project vrspace
oc create sa vrspace
```

```
oc adm policy add-scc-to-user privileged -z vrspace
```

```
gomplate -f manifest/vrspace/Dockerfile | envsubst | oc new-build --dockerfile=- --to=vrspace -
oc new-app vrspace:latest
oc set sa deployment/vrspace vrspace
```

```
cat manifest/vrspace/vrspace-route.yaml | envsubst | oc apply -f -
```

access to https://${VRSPACE_SERVER_URL}/avatar-selection.html
