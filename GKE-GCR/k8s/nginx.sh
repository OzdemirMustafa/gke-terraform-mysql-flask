#!/usr/bin/env bash

helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm install nginx stable/nginx-ingress  \
    --set rbac.create=true

printf "IP of nginx: "kubectl get svc nginx-nginx-ingress-controller -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
echo ""