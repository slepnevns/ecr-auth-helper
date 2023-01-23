#!/bin/bash

configjson='{"auths":{"%s":{ "username":"%s","password":"%s","auth":"%s"}}}'

REGISTRY_PASSWORD=$(aws ecr get-login-password --region eu-central-1)
REGISTRY_AUTH=$(echo "$REGISTRY_USERNAME:$REGISTRY_PASSWORD" | openssl base64 -A)

printf "$configjson" "$REGISTRY_NAME" "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" "$REGISTRY_AUTH" > config.json

kubectl delete secret $TARGET_SECRET_NAME --ignore-not-found -n $TARGET_NAMESPACE
kubectl create secret generic $TARGET_SECRET_NAME --from-file=.dockerconfigjson=./config.json --type=kubernetes.io/dockerconfigjson -n $TARGET_NAMESPACE