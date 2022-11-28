# Knative Broker for Apache Kafka

Development setup of the Knative Broker for Apache Kafka, using [Strimzi](https://github.com/strimzi/strimzi-kafka-operator/) and the `KRaft` feature gate.

* `00-installer-kind.sh`: Creates a Kind cluster
* `01-strimzi.sh`: Creates a single node Apache Kafka, with KRaft mode
* `02-kn-eventing.sh`: Setups up the bare minimun of Knative Eventing
* `03-kn-broker.sh`: Installs and configures the Knative Broker for Apache Kafka. _NOTE:_ This is just the Kafka-based broker implementation. No other Kafka-based components, like the channel, the source or the sink are enabled.
* `04-kn-example-broker.sh`: Creates a sample broker object

Have fun!