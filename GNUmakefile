TEST?=./...
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)
default: build

build:
	go build .

test:
	 go test ./...

testacc:
	KAFKA_BOOTSTRAP_SERVER=localhost:9092 \
	KAFKA_CA_CERT=../secrets/snakeoil-ca-1.crt \
	KAFKA_CLIENT_CERT=../secrets/kafkacat-ca1-signed.pem \
	KAFKA_CLIENT_KEY=../secrets/kafkacat-raw-private-key-passphrase.pem \
	KAFKA_CLIENT_KEY_PASSPHRASE=confluent \
	KAFKA_SKIP_VERIFY=false \
	KAFKA_ENABLE_TLS=true \
	TF_LOG=DEBUG \
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 9m -count=1

.PHONY: build test testacc

version = 0.2.10-custom-topic-type
provider_path = registry.terraform.io/mongey/kafka/$(version)/linux_amd64/

install_linux_local:
	go build -o terraform-provider-kafka_$(version)

	mkdir -p ~/.terraform.d/plugins/$(provider_path)
	cp terraform-provider-kafka_$(version) ~/.terraform.d/plugins/$(provider_path)
