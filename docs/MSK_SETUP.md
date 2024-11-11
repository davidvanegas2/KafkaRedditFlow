# MSK Cluster Setup and CLI Commands

This document provides a step-by-step guide to install Kafka, configure an EC2 instance, and connect to the MSK cluster for producing and consuming data.

## 1. Prerequisites
- **EC2 Instance**: `t2.xlarge` instance running Amazon Linux 2 (or your OS choice).
- **Kafka**: Download and install Kafka on the EC2 instance.

### 2. Install uv on EC2
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 3. Installing Kafka on EC2

```bash
# Update packages
sudo yum update -y

# Install Java (required for Kafka)
sudo yum install java-17-amazon-corretto -y

# Download Kafka
wget https://archive.apache.org/dist/kafka/<version>/kafka_2.13-<version>.tgz
tar -xzf kafka_2.13-<version>.tgz
sudo mv kafka_2.13-3.5.1 /opt/kafka

# Add Kafka to PATH (optional)
echo 'export PATH=$PATH:/opt/kafka/bin' >> ~/.bash_profile
source ~/.bash_profile

# Define KAFKA_HEAP_OPTS
export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"

# Validate installation
kafka-topics.sh --version
```

### 4. Configuring MSK Connection
Create a properties file (e.g., `client.properties`) with the MSK cluster details and SSL settings.

```properties
# client.properties
security.protocol=SSL
```

### 5. Produce data to MSK
Run the python module to produce data to the MSK cluster.
```bash
uv run -m reddit_streaming.main --bootstrap-servers <MSK_BOOTSTRAP_SERVER>
```

### 6. Consume data from MSK
Run the Kafka CLI to consume data from the MSK cluster.
```bash
kafka-console-consumer.sh --bootstrap-server <MSK_BOOTSTRAP_SERVER> --topic <TOPIC_NAME> --from-beginning --consumer.config client.properties 
```

