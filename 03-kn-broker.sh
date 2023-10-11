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

eventing_kafka_broker_version="v1.11.6"

function header_text {
  echo "$header$*$reset"
}

header_text "Using Knative Eventing Kafka-Broker Version:  ${eventing_kafka_broker_version}"

header_text "Setting up Knative Kafka Broker"

kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-${eventing_kafka_broker_version}/eventing-kafka-controller.yaml
kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-${eventing_kafka_broker_version}/eventing-kafka-broker.yaml

sleep 1

kubectl patch deployment \
  kafka-controller \
  --namespace knative-eventing \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
  "--disable-controllers=sink-controller,source-controller,channel-controller"
]}]'

header_text "Waiting for Knative Kafka Broker to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing

## Setting the default configuration for Kafka-based broker:
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-broker-config
  namespace: knative-eventing
data:
  default.topic.partitions: "10"
  default.topic.replication.factor: "1"
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
EOF

## Setting the Kafka broker as default:
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
EOF

