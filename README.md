# Knative Broker for Apache Kafka

Development setup of the Knative Broker for Apache Kafka, using [Strimzi](https://github.com/strimzi/strimzi-kafka-operator/) and the `KRaft` feature gate.

* `00-installer-kind.sh`: Creates a Kind cluster
* `01-strimzi.sh`: Creates a single node Apache Kafka, with KRaft mode
* `02-kn-eventing.sh`: Setups up the bare minimum of Knative Eventing
* `03-kn-broker.sh`: Installs and configures the Knative Broker for Apache Kafka. _NOTE:_ This is just the Kafka-based broker implementation. No other Kafka-based components, like the channel, the source or the sink are enabled.
* `04-kn-example-broker.sh`: Creates a sample broker object

Have fun!

## Sending CloudEvents to the Broker

With `curl` you can easily send a CloudEvent to the broker.


The broker is accessible via the `kafka-broker-ingress` service in the `knative-eventing` namespace, and for simplicity we can enable `port-forward` to access it via `localhost`:

```
kubectl -n knative-eventing port-forward service/kafka-broker-ingress 8080:80
```

Now perform a `curl`:

```
curl -v -X POST \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-myextension: super-duper-ce-extension"  \
    -H "ce-id: 123-abc"  \
    -d '{"message":"Hello World"}' \
    http://localhost:8080/default/my-demo-kafka-broker
```
