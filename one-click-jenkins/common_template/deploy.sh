#!/bin/bash
# author: zhixiang pan

usage() { printf "%s" "\
Usage: 
  Deploy jenkins server in eks
  Need kubectl installed and admin permisson on current cluster
Parameters:
    --namespace  <namespace>
    --efs  <efs id>
    --cert <path to tls cert file>
    --key  <path to tls key file>
"
exit 1
}

get_args() {
    while [[ "$1" ]]; do 
    case $1 in 
        "--namespace") namespace="$2";;
        "--efs") efs="$2";;
        "--cert") cert="$2";;
        "--key") key="$2";;
        "--help") usage;;
    esac
    shift
    done
}

deploy() {
  export NAMESPACE="$namespace"
  export EFS="$efs"
  export CERT="$cert"
  export KEY="$key"
  envsubst <ns.template> ./ns.yaml
  envsubst <storageclass.template> ./storageclass.yaml
  envsubst <pv.template> ./pv.yaml
  envsubst <pvc.template> ./pvc.yaml
  envsubst <rbac.template> ./rbac.yaml
  envsubst <deployment.template> ./deployment.yaml
  envsubst <hpa.template> ./hpa.yaml
  envsubst <service-clusterip.template> ./service-clusterip.yaml
  envsubst <ingress.template> ./ingress.yaml

  printf "Creating resource...\n"
  kubectl apply -f ns.yaml
  kubectl apply -f storageclass.yaml
  kubectl apply -f pv.yaml
  kubectl apply -f pvc.yaml
  kubectl apply -f rbac.yaml
  kubectl apply -f deployment.yaml
  kubectl apply -f service-clusterip.yaml
  kubectl create secret tls $NAMESPACE-tls -n $NAMESPACE --cert=$CERT --key=$KEY
  kubectl apply -f ingress.yaml
  kubectl apply -f hpa.yaml

  printf "Deleteing yaml files...\n"
  rm -f *.yaml
}

main() {
    if [[ -z "$1" ]]; then 
        usage 
    fi
    get_args "$@"
    deploy
}

main "$@"