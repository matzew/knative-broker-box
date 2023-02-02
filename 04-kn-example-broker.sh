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

function header_text {
  echo "$header$*$reset"
}

header_text "Setting up Example Knative Broker"

## Setting the Kafka broker as default:
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-demo-kafka-broker
spec: {}
EOF

## Setting a debug logger:
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: log-receiver
spec:
  selector:
    app: log-receiver
  ports:
    - port: 80
      protocol: TCP
      targetPort: log-receiver
      name: http
---
apiVersion: v1
kind: Pod
metadata:
  name: log-receiver
  labels:
    app: log-receiver
spec:
  containers:
  - name: log-receiver
    image: quay.io/openshift-knative/knative-eventing-sources-event-display
    imagePullPolicy: Always
    ports:
    - containerPort: 8080
      protocol: TCP
      name: log-receiver

EOF

## Setting a debug trigger (all events):
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: log-trigger
spec:
  broker: my-demo-kafka-broker
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: log-receiver
EOF

sleep 3

kubectl get brokers.eventing.knative.dev
kubectl get triggers.eventing.knative.dev
