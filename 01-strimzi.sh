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

strimzi_version="0.36.1"

function header_text {
  echo "$header$*$reset"
}

header_text "Using Strimzi Version:                  ${strimzi_version}"

header_text "Strimzi install"
kubectl create namespace kafka
curl -L "https://github.com/strimzi/strimzi-kafka-operator/releases/download/${strimzi_version}/strimzi-cluster-operator-${strimzi_version}.yaml" \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl -n kafka create -f -

sleep 1

header_text "Setting Strimzi for KRaft mode (Zookeeper-less Apache Kafka)"
kubectl -n kafka set env deployment/strimzi-cluster-operator STRIMZI_FEATURE_GATES=+UseStrimziPodSets,+UseKRaft

sleep 2

# Wait for the CRD we need to actually be active
kubectl wait crd --timeout=-1s kafkas.kafka.strimzi.io --for=condition=Established

header_text "Applying Strimzi Cluster file"
cat <<-EOF | kubectl -n kafka apply -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 3.5.1
    replicas: 1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
      inter.broker.protocol.version: "3.5"
    storage:
      type: jbod
      volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
# With KRaft not relevant:
  zookeeper:
    replicas: 1
    storage:
      type: persistent-claim
      size: 100Gi
      deleteClaim: false
EOF

header_text "Waiting for Strimzi to become ready"
kubectl wait kafka --all --timeout=-1s --for=condition=Ready -n kafka
