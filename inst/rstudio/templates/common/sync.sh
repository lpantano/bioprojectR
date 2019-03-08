# Lorena Pantano
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
# set -v
# set -x
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
msg="sync local|remote nodry|dry"

LOCAL=data
REMOTE=orchtransf:hbc/PIs/name_last_name/project/


if [ $# -eq 0 ]; then
    echo $msg
    echo "DEBUG with bash -x -v ${BASH_SOURCE} ${@:1}"
    exit 1
fi

if [[ $1 == "local" ]]; then
      echo "origin will be ${LOCAL}"
      ORIGIN=${LOCAL}
      SERVER=${REMOTE}
elif [[ $1 == "remote" ]]; then
  echo "origin will be ${REMOTE}"
  ORIGIN=${REMOTE}
  SERVER=${LOCAL}
fi

echo "${ORIGIN} -> ${SERVER}"

if [[ $2 == "nodry" ]]; then
  rsync -abviuzP ${ORIGIN} ${SERVER}
elif [[ $2 == "dry" ]]; then
  rsync -abviuzPn ${ORIGIN} ${SERVER}
fi
