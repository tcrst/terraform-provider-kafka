// terraform {
//   required_providers {
//     kafka = {
//       source = "/home/tcrst/workwork/devground/terraform-provider-kafka/examples/terraform-provider-kafka"
//       version = "v0.2.10"
//     }
//   }
// }

terraform {
  required_providers {
    kafka = {
      source = "mongey/kafka"
      version = "0.2.10-custom-topic-type"
    }
  }
}


provider "kafka" {
  bootstrap_servers = ["localhost:9092"]

  ca_cert     = file("../secrets/snakeoil-ca-1.crt")
  client_cert = file("../secrets/kafkacat-ca1-signed.pem")
  client_key  = file("../secrets/kafkacat-raw-private-key.pem")
  tls_enabled = true
  skip_tls_verify = true
}

# Make sure we don't lock down ourself on first run of terraform.
# First grant ourself admin permissions, then add ACL for topic.
resource "kafka_acl" "global" {
  resource_name       = "*"
  resource_type       = "Topic"
  acl_principal       = "User:*"
  acl_host            = "*"
  acl_operation       = "All"
  acl_permission_type = "Allow"
}

resource "kafka_topic" "syslog" {
  name               = "syslog"
  replication_factor = 1
  partitions         = 4
  type               = "striped"

  config = {
    "segment.ms"   = "4000"
    "retention.ms" = "86400000"
  }

  depends_on = [kafka_acl.global]
}

resource "kafka_acl" "test" {
  resource_name       = "syslog"
  resource_type       = "Topic"
  acl_principal       = "User:Alice"
  acl_host            = "*"
  acl_operation       = "Write"
  acl_permission_type = "Deny"

  depends_on = [kafka_acl.global]
}
