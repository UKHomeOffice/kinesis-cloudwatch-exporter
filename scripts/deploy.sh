#!/usr/bin/env sh

set +x
set -e

usage()
{
  echo "Usage: accepts one of the following parameters"
  echo ""
  echo "-d --dry-run"
  echo "-i --install"
  echo "-r --rollback"
  echo ""
}

preliminary()
{
  apk update && apk add curl

  echo "---"
  echo "Kube Environment: ${DRONE_DEPLOY_TO}"
  echo "Kube API URL: ${HELM_KUBEAPISERVER}"
  echo "Kube Namespace: ${KUBE_NAMESPACE}"
  echo "---"

  curl -sSo /usr/local/share/ca-certificates/ca-file.crt "https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/${DRONE_DEPLOY_TO}.crt"

  update-ca-certificates
}

case $1 in
    -d | --dry-run ) 

      preliminary
    
      if [ -z "${DRONE_DEPLOY_TO}" ]; then
        helm template \
          ./chart
      else
        helm template \
          ./chart \
          -f environments/${DRONE_DEPLOY_TO}.yaml
      fi
      ;;

    -i | --install )

      preliminary

      helm upgrade ${APPLICATION} \
        ./chart \
        --namespace ${KUBE_NAMESPACE} \
        -f environments/${DRONE_DEPLOY_TO}.yaml \
        --install \
        --debug 
      ;;

    -r | --rollback )

      preliminary

      helm uninstall ${APPLICATION} \
        --namespace ${KUBE_NAMESPACE}
      ;;

    -h | --help )

      usage
      ;;

    * )                     
    
      usage
      echo "You supplied '$1'"
      exit 1
      ;;
esac
