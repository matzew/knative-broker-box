#!/usr/bin/env bash

set -e

# Turn colors in this script off by setting the NO_COLOR variable in your
# environment to any value:
#
# $ NO_COLOR=1 test.sh
NO_COLOR=${NO_COLOR:-""}
if [ -z "$NO_COLOR" ]; then
  header=$'\e[1;33m'
  reset=$'\e[0m'
else
  header=''
  reset=''
fi

eventing_version="v1.11.4"
eventing_url=https://github.com/knative/eventing/releases/download/knative-${eventing_version}

function header_text {
  echo "$header$*$reset"
}

header_text "Using Knative Eventing Version:         ${eventing_version}"

header_text "Setting up Knative Eventing CORE"
kubectl apply --filename $eventing_url/eventing-core.yaml

header_text "Waiting for Knative Eventing to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing
